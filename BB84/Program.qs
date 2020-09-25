namespace BB84Example {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;

    @EntryPoint()
    operation Start() : Unit {
        
        let result1 = RunBB84Protocol(256, 0.5);
        let result2 = RunBB84Protocol(256, 0.10);
        let result3 = RunBB84Protocol(256, 0.0);

        Message("Running the protocol for 256bit key with eavesdropping probability 1 resulted in " + (result1 ? "succcess" | "failure"));
        Message("Running the protocol for 256bit key with eavesdropping probability 0.25 resulted in " + (result2 ? "succcess" | "failure"));
        Message("Running the protocol for 256bit key with eavesdropping probability 0.0 resulted in " + (result3 ? "succcess" | "failure"));
    }

    operation RunBB84Protocol(expectedKeyLength : Int, eavesdropperProbability : Double) : Bool {
        let chunk = 16;

        // we want to transfer (4 + 𝛿)n required bits
        // n = expectedKeyLength
        // chunk = amount of qubits to allocate and send in a single roundtrip
        // 𝛿 = extra bits in case the low sample size causes us to end up with less than required bits
        // at the end of the protocl execution. In our case we assume 𝛿 = 2 * chunk (32)
        let roundtrips = (4 * expectedKeyLength + 2 * chunk) / chunk;

        mutable aliceValues = new Bool[0];
        mutable aliceBases = new Bool[0];
        mutable bobResults = new Bool[0];
        mutable bobBases = new Bool[0];

        for (roundtrip in 0..roundtrips-1) {
            using (qubits = Qubit[chunk]) {
                
                // prepare Alice's qubits
                for (qubit in qubits) {
                    // Alice chooses random bit
                    let valueSelected = DrawRandomBool(0.5);
                    if (valueSelected) { X(qubit); }
                    set aliceValues += [valueSelected];

                    // Alice chooses random basis by drawing a random bit
                    // 0 will represent |0> and |1> computational (PauliZ) basis
                    // 1 will represent |-> and |+> Hadamard (PauliX) basis
                    let aliceBasisSelected = DrawRandomBool(0.5);
                    if (aliceBasisSelected) { H(qubit); }
                    set aliceBases += [aliceBasisSelected];
                }

                //eavesdropper!!!
                for (qubit in qubits) {
                    let shouldEavesdrop = DrawRandomBool(eavesdropperProbability);
                    if (shouldEavesdrop) {
                        let eveBasisSelected = DrawRandomBool(0.5);
                        let eveResult = Measure([eveBasisSelected ? PauliX | PauliZ], [qubit]);
                    }
                }

                // measure Bob's qubits
                for (qubit in qubits) {
                    // Bob chooses random basis by drawing a random bit
                    // 0 will represent PauliZ basis
                    // 1 will represent PauliX basis
                    let bobBasisSelected = DrawRandomBool(0.5);
                    set bobBases += [bobBasisSelected];
                    let bobResult = Measure([bobBasisSelected ? PauliX | PauliZ], [qubit]);
                    set bobResults += [ResultAsBool(bobResult)];
                    Reset(qubit);
                }   
            }
        }
        
        Message("***********");
        Message("");

        Message("Comparing bases....");
        mutable aliceValuesAfterBasisComparison = new Bool[0];
        mutable bobValuesAfterBasisComparison = new Bool[0];

        // compare bases and pick shared results
        for (i in 0..Length(aliceValues)-1) {
            // if Alice and Bob used the same basis
            // they can use the corresponding bit
            if (aliceBases[i] == bobBases[i]) {
                set aliceValuesAfterBasisComparison += [aliceValues[i]];
                set bobValuesAfterBasisComparison += [bobResults[i]];
            }
        }
        Message("Bases compared.");
        Message("");

        Message("Performing eavesdropping check....");
        // select a random bit of every 2 bits for eavesdropping check
        mutable eavesdropppingIndices = new Int[0];
        let chunkedValues = Chunks(2, RangeAsIntArray(IndexRange(aliceValuesAfterBasisComparison)));
        for (i in IndexRange(chunkedValues)) {
            if (Length(chunkedValues[i]) == 1) {
                set eavesdropppingIndices += [chunkedValues[i][0]];
            } else {
                set eavesdropppingIndices += [DrawRandomBool(0.5) ? chunkedValues[i][0] | chunkedValues[i][1]];
            }
        }

        // compare results on eavesdropping check indices
        mutable differences = 0;
        for (i in eavesdropppingIndices) {
            // if Alice and Bob get different result, but used same basis
            // it means that there must have been an eavesdropper (assuming perfect communication)
            if (aliceValuesAfterBasisComparison[i] != bobValuesAfterBasisComparison[i]) {
                set differences += 1;
            }
        }
        let errorRate = IntAsDouble(differences)/IntAsDouble(Length(eavesdropppingIndices));
        Message($"Error rate: {errorRate*IntAsDouble(100)}%");
        if (errorRate > 0.0) {
            Message($"Eavesdropper detected! Aborting the protocol");
            return false;
        } else {
            Message($"No eavesdropper detected.");
        }

        // remove values used for eavesdropping check from comparison
        let aliceKey = Exclude(eavesdropppingIndices, aliceValuesAfterBasisComparison);
        let bobKey = Exclude(eavesdropppingIndices, bobValuesAfterBasisComparison);

        Message("");
        Message($"Alice's key: {BoolArrayToString(aliceKey)} | key length: {IntAsString(Length(aliceKey))}");
        Message($"Bob's key:   {BoolArrayToString(bobKey)} | key length: {IntAsString(Length(bobKey))}");
        Message("");

        let keysEqual = EqualA(EqualB, aliceKey, bobKey);
        Message($"Keys are equal? {keysEqual}");
        if (not keysEqual) {
            Message("Keys are not equal, aborting the protocol");
            return false;
        }

        if (Length(aliceKey) < expectedKeyLength) {
            Message("Key is too short, aborting the protocol");
            return false;
        }

        Message("");
        let trimmedKey = aliceKey[0..expectedKeyLength-1];
        Message($"Final trimmed {expectedKeyLength}bit key: {BoolArrayToString(trimmedKey)}");

        return true;
    }

    function BoolArrayToString(array : Bool[]) : String {
        mutable stringResult = "";

        for (item in array) {
            set stringResult += item ? "1" | "0";
        }

        return stringResult;
    }
}
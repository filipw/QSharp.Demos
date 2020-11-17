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
        
        let result1 = RunB92Protocol(256, 1.0);
        let result2 = RunB92Protocol(256, 0.5);
        let result3 = RunB92Protocol(256, 0.0);

        Message("Running the protocol for 256 bit key with eavesdropping probability 1 resulted in " + (result1 ? "succcess" | "failure"));
        Message("Running the protocol for 256 bit key with eavesdropping probability 0.5 resulted in " + (result2 ? "succcess" | "failure"));
        Message("Running the protocol for 256 bit key with eavesdropping probability 0.0 resulted in " + (result3 ? "succcess" | "failure"));
    }

    operation RunB92Protocol(expectedKeyLength : Int, eavesdropperProbability : Double) : Bool {
        let chunk = 16;

        // we want to transfer 8n + 𝛿 required bits
        // n = expectedKeyLength
        // chunk = amount of qubits to allocate and send in a single roundtrip
        // 𝛿 = extra bits in case the low sample size causes us to end up with less than required bits
        // at the end of the protocl execution. In our case we assume 𝛿 = 4 * chunk (32)
        let roundtrips = (8 * expectedKeyLength + 4 * chunk) / chunk;

        Message("***********");
        Message($"Running the B92 protocol for expected key length: {expectedKeyLength}");

        mutable aliceValues = new Bool[0];
        mutable bobResults = new Bool[0];
        mutable bobValues = new Bool[0];

        for (roundtrip in 0..roundtrips-1) {
            using (qubits = Qubit[chunk]) {
                
                // prepare Alice's qubits
                for (qubit in qubits) {
                    // Alice chooses random bit
                    let valueSelected = DrawRandomBool(0.5);
                    if (valueSelected) { H(qubit); }
                    set aliceValues += [valueSelected];
                }

                // eavesdropper!!!
                for (qubit in qubits) {
                    let shouldEavesdrop = DrawRandomBool(eavesdropperProbability);
                    if (shouldEavesdrop) {
                        let eveBasisSelected = DrawRandomBool(0.5);
                        let eveResult = Measure([eveBasisSelected ? PauliX | PauliZ], [qubit]);
                    }
                }

                // measure Bob's qubits
                for (qubit in qubits) {
                    let bobValue = DrawRandomBool(0.5);
                    set bobValues += [bobValue];
                    let bobResult = Measure([bobValue ? PauliX | PauliZ], [qubit]);
                    // |0> or |+>  maps to a classical 0 
                    // |1> or |->  maps to a classical 1
                    set bobResults += [ResultAsBool(bobResult)];
                    Reset(qubit);
                }   
            }
        }
        
        Message("");

        Message("Sharing Bob's results....");
        mutable aliceValuesAfterBobResultsCheck = new Bool[0];
        mutable bobValuesAfterBobResultsCheck = new Bool[0];

        for (i in 0..Length(bobResults)-1) {
            if (bobResults[i] == true) {
                // Alice's valsue is a
                set aliceValuesAfterBobResultsCheck += [aliceValues[i]];
                // Bob's value (1 - a)
                set bobValuesAfterBobResultsCheck += [not bobValues[i]];
            }
        }
        Message("");

        Message("Performing eavesdropping check....");
        // select a random bit of every 2 bits for eavesdropping check
        mutable eavesdropppingIndices = new Int[0];
        let chunkedValues = Chunks(2, RangeAsIntArray(IndexRange(aliceValuesAfterBobResultsCheck)));
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
            if (aliceValuesAfterBobResultsCheck[i] != bobValuesAfterBobResultsCheck[i]) {
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
        let aliceKey = Exclude(eavesdropppingIndices, aliceValuesAfterBobResultsCheck);
        let bobKey = Exclude(eavesdropppingIndices, bobValuesAfterBobResultsCheck);

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
        Message($"Final trimmed {expectedKeyLength} bit key: {BoolArrayToString(trimmedKey)}");

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
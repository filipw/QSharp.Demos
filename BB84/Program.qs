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

        let expectedKeyLength = 256;
        let chunk = 16;

        mutable aliceValues = new Bool[0];
        mutable aliceBases = new Bool[0];
        mutable bobResults = new Bool[0];
        mutable bobBases = new Bool[0];
        mutable offset = 0;

        repeat {
            Message("***********");
            Message($"Iteration {(offset/chunk) + 1}");
            using (qubits = Qubit[chunk]) {
                
                // prepare Alice's qubits
                for (i in 0..chunk-1) {

                    // Alice chooses random bit
                    let valueSelected = DrawRandomBool(0.5);
                    if (valueSelected) { X(qubits[i]); }
                    set aliceValues += [valueSelected];

                    // Alice chooses random basis by drawing a random bit
                    // 0 will represent |0> and |1> computational (PauliZ) basis
                    // 1 will represent |-> and |+> Hadamard (PauliX) basis
                    let aliceBasisSelected = DrawRandomBool(0.5);
                    if (aliceBasisSelected) { H(qubits[i]); }
                    set aliceBases += [aliceBasisSelected];
                }

                //eavesdropper!!!
                for (i in 0..chunk-1) {
                    let shouldEavesdrop = DrawRandomBool(1.0);
                    if (shouldEavesdrop) {
                        let eveBasisSelected = DrawRandomBool(0.5);
                        let eveResult = Measure([eveBasisSelected ? PauliX | PauliZ], [qubits[i]]);
                    }
                }

                // measure Bob's qubits
                for (i in 0..chunk-1) {

                    // Bob chooses random basis by drawing a random bit
                    // 0 will represent PauliZ basis
                    // 1 will represent PauliX basis
                    let bobBasisSelected = DrawRandomBool(0.5);
                    set bobBases += [bobBasisSelected];
                    let bobResult = Measure([bobBasisSelected ? PauliX | PauliZ], [qubits[i]]);
                    set bobResults += [ResultAsBool(bobResult)];
                    Reset(qubits[i]);
                }   
            }

            Message("Alice's sent values:   " + BoolArrayToString(aliceValues[offset..offset+chunk-1]));
            Message("Bob's measured values: " + BoolArrayToString(bobResults[offset..offset+chunk-1]));

            set offset += chunk-1;
            Message("");

        } until (offset+1 > expectedKeyLength * 4);
        
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

        // compare results on eavesdropping checck indices
        mutable differences = 0;
        for (i in eavesdropppingIndices) {
            // if Alice and Bob used the same basis
            // they can use the corresponding bit
            if (aliceValuesAfterBasisComparison[i] != bobValuesAfterBasisComparison[i]) {
                set differences += 1;
            }
        }
        let errorRate = IntAsDouble(differences)/IntAsDouble(Length(eavesdropppingIndices));
        Message($"Error rate: {errorRate*IntAsDouble(100)}%");
        if (errorRate > 0.0) {
            Message($"Eavesdropper detected! Aborting the protocol");
            return ();
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
            return ();
        }

        if (Length(aliceKey) < expectedKeyLength) {
            Message("Key is too short, aborting the protocol");
            return ();
        }

        Message("");
        let trimmedKey = aliceKey[0..expectedKeyLength-1];
        Message($"Final trimmed {expectedKeyLength}bit key: {BoolArrayToString(trimmedKey)}");
    }

    function BoolArrayToString(array : Bool[]) : String {
        mutable stringResult = "";

        for (item in array) {
            set stringResult += item ? "1" | "0";
        }

        return stringResult;
    }

    function IntArrayToString(array : Int[]) : String {
        mutable stringResult = "";

        for (item in array) {
            set stringResult += IntAsString(item) + " ";
        }

        return stringResult;
    }
}
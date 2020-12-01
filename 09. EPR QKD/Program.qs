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
        let result1 = RunEPRQKDProtocol(256, 1.0);
        Message("Running the protocol for 256 bit key with eavesdropping probability 1 resulted in " + (result1 ? "succcess" | "failure"));

        let result2 = RunEPRQKDProtocol(256, 0.5);
        Message("Running the protocol for 256 bit key with eavesdropping probability 0.5 resulted in " + (result2 ? "succcess" | "failure"));

        let result3 = RunEPRQKDProtocol(256, 0.0);
        Message("Running the protocol for 256 bit key with eavesdropping probability 0.0 resulted in " + (result3 ? "succcess" | "failure"));
    }

    operation RunEPRQKDProtocol(expectedKeyLength : Int, eavesdropperProbability : Double) : Bool {
        Message($"Running the EPR QKD protocol for expected key length: {expectedKeyLength}");

        mutable aliceResults = new Bool[0];
        mutable bobResults = new Bool[0];
        mutable aliceBases = new Bool[0];
        mutable bobBases = new Bool[0];

        for (roundtrip in 0..(5 * expectedKeyLength)) {
            using ((aliceQubit, bobQubit) = (Qubit(), Qubit())) {
                // create entanglement between aliceQubit and bobQubit
                H(aliceQubit);
                CNOT(aliceQubit, bobQubit);

                // Alice and Bob choose a random basis by drawing a random bit
                // 0 will represent |0> and |1> computational (PauliZ) basis
                // 1 will represent |-> and |+> Hadamard (PauliX) basis
                let aliceBasisSelected = DrawRandomBool(0.5);
                set aliceBases += [aliceBasisSelected];
                let aliceResult = Measure([aliceBasisSelected ? PauliX | PauliZ], [aliceQubit]);
                set aliceResults += [ResultAsBool(aliceResult)];
                Reset(aliceQubit);

                let shouldEavesdrop = DrawRandomBool(eavesdropperProbability);
                if (shouldEavesdrop) {
                    let eveBasisSelected = DrawRandomBool(0.5);
                    let eveResult = Measure([eveBasisSelected ? PauliX | PauliZ], [bobQubit]);
                }

                let bobBasisSelected = DrawRandomBool(0.5);
                set bobBases += [bobBasisSelected];
                let bobResult = Measure([bobBasisSelected ? PauliX | PauliZ], [bobQubit]);
                set bobResults += [ResultAsBool(bobResult)];
                Reset(bobQubit);
            }
        }

        Message("***********");
        Message("Comparing bases....");
        mutable aliceResultsAfterBasisComparison = new Bool[0];
        mutable bobResultsAfterBasisComparison = new Bool[0];

        // compare bases and pick shared results
        for (i in 0..Length(aliceResults)-1) {
            // if Alice and Bob used the same basis
            // they can use the corresponding bit
            if (aliceBases[i] == bobBases[i]) {
                set aliceResultsAfterBasisComparison += [aliceResults[i]];
                set bobResultsAfterBasisComparison += [bobResults[i]];
            }
        }
        Message("Bases compared.");
        Message("");

        //Message($"Final Alice bit key: {BoolArrayToString(aliceResultsAfterBasisComparison)}");
        //Message($"Final Bob bit key  : {BoolArrayToString(bobResultsAfterBasisComparison)}");

        Message("Performing eavesdropping check....");
        // select a random bit of every 2 bits for eavesdropping check
        mutable eavesdropppingIndices = new Int[0];
        let chunkedValues = Chunks(2, RangeAsIntArray(IndexRange(aliceResultsAfterBasisComparison)));
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
            if (aliceResultsAfterBasisComparison[i] != bobResultsAfterBasisComparison[i]) {
                set differences += 1;
            }
        }
        let errorRate = IntAsDouble(differences)/IntAsDouble(Length(eavesdropppingIndices));
        Message($"Error rate: {errorRate*IntAsDouble(100)}%");
        if (errorRate > 0.0) {
            Message($"Eavesdropper detected! Aborting the protocol");
            Message("");
            return false;
        } else {
            Message($"No eavesdropper detected.");
        }

        // remove values used for eavesdropping check from comparison
        let aliceKey = Exclude(eavesdropppingIndices, aliceResultsAfterBasisComparison);
        let bobKey = Exclude(eavesdropppingIndices, bobResultsAfterBasisComparison);

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
        Message($"Final trimmed {expectedKeyLength} bit shared key: {BoolArrayToString(trimmedKey)}");

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
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

        mutable aliceValues = new Bool[16];
        mutable aliceBases = new Bool[16];
        mutable bobResults = new Bool[16];
        mutable bobBases = new Bool[16];

        using (qubits = Qubit[16]) {
            
            // prepare Alice's qubits
            for (i in 0..15) {
                let valueSelected = DrawRandomBool(0.5);
                if (valueSelected) { X(qubits[i]); }
                set aliceValues w/= i <- valueSelected;

                // 0 will represent |0> and |1>  computational basis
                // 1 will represent |-> and |+>  computational basis
                let aliceBaseSelected = DrawRandomBool(0.5);
                if (aliceBaseSelected) { H(qubits[i]); }
                set aliceBases w/= i <- aliceBaseSelected;
            }

            // measure Bob's qubits
            for (i in 0..15) {
                let bobBaseSelected = DrawRandomBool(0.5);
                set bobBases w/= i <- bobBaseSelected;
                let bobBase = bobBaseSelected ? PauliX | PauliZ;
                let bobResult = Measure([bobBase], [qubits[i]]);
                set bobResults w/= i <- ResultAsBool(bobResult);
                Reset(qubits[i]);
            }   

            Message("Alice's original values: " + BoolArrayToString(aliceValues));
            Message("Bob's measured values:   " + BoolArrayToString(bobResults));

            mutable aliceKey = new Bool[0];
            mutable bobKey = new Bool[0];
            // compare bases and pick shared key results
            for (i in 0..15) {
                if (aliceBases[i] == bobBases[i]) {
                    set aliceKey += [aliceValues[i]];
                    set bobKey += [bobResults[i]];
                }
            }
            
            Message("Alice's key: " + BoolArrayToString(aliceKey));
            Message("Bob's key:   " + BoolArrayToString(bobKey));

            let keysEqual = EqualA(EqualB, aliceKey, bobKey);
            Message("Keys are equal? " + BoolAsString(keysEqual));
        }
    }

    function BoolArrayToString(array : Bool[]) : String {
        mutable stringResult = "";

        for (item in array) {
            set stringResult += item ? "1" | "0";
        }

        return stringResult;
    }
}
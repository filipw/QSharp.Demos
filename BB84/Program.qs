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

        mutable aliceKey = new Bool[0];
        mutable bobKey = new Bool[0];
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

            // compare bases and pick shared key results
            for (i in 0..chunk-1) {
                // if Alice and Bob used the same basis
                // they can use the corresponding bit
                if (aliceBases[offset+i] == bobBases[offset+i]) {
                    set aliceKey += [aliceValues[offset+i]];
                    set bobKey += [bobResults[offset+i]];
                }
            }

            set offset += chunk-1;
            Message("");

        } until (Length(aliceKey) > expectedKeyLength);
        
        Message("***********");
        Message("");

        Message("Alice's key: " + BoolArrayToString(aliceKey) + " | key length: " + IntAsString(Length(aliceKey)));
        Message("Bob's key:   " + BoolArrayToString(bobKey) + " | key length: " + IntAsString(Length(bobKey)));

        let keysEqual = EqualA(EqualB, aliceKey, bobKey);
        Message($"Keys are equal? {keysEqual}");
        Message("");

        let trimmedKey = aliceKey[0..expectedKeyLength-1];
        Message($"Final trimmed key of length {expectedKeyLength}: {BoolArrayToString(trimmedKey)}");
    }

    function BoolArrayToString(array : Bool[]) : String {
        mutable stringResult = "";

        for (item in array) {
            set stringResult += item ? "1" | "0";
        }

        return stringResult;
    }
}
namespace Grover {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;

    @EntryPoint()
    operation Main() : Unit {
        let result = Grover(10, 4, 3);
        Message($"Measured Grover example: {result}");

        let resultImproved = GroverVersion2(10, 4, 3);
        Message($"Measured Grover improved example: {resultImproved}");
    }

    operation Grover(markIndex : Int, numberOfQubits : Int, iterations : Int) : Int {
        use qubits = Qubit[numberOfQubits];

        // apply W
        ApplyToEachA(H, qubits);

        // Grover iterations
        for x in 1..iterations {

            // mark the solution
            MarkSolution(markIndex, numberOfQubits, qubits);

            // amplitude amplification
            ApplyToEachA(H, qubits);
            ApplyToEachA(X, qubits);
            Controlled Z(Most(qubits), Tail(qubits));
            ApplyToEachA(X, qubits);
            ApplyToEachA(H, qubits);
            DumpMachine();
            Message($"This was iteration {x}");
        }

        let register = LittleEndian(qubits);
        let number = MeasureInteger(register);
        ResetAll(qubits);

        return number;
    }

    operation GroverVersion2(markIndex : Int, numberOfQubits : Int, iterations : Int) : Int {
        use qubits = Qubit[numberOfQubits];
        let register = LittleEndian(qubits);

        // superposition
        ApplyToEachA(H, qubits);

        for x in 1..iterations {
            // mark the required number
            ReflectAboutInteger(markIndex, register);

            // amplitude amplification
            AmplifyAmplitude(qubits);
            DumpMachine();
            Message($"This was iteration {x}");
        }

        let number = MeasureInteger(register);
        ResetAll(qubits);

        return number;
    }

    operation AmplifyAmplitude(qubits : Qubit[]) : Unit is Adj {
        within {
            ApplyToEachA(H, qubits);
            ApplyToEachA(X, qubits);
        } apply {
            Controlled Z(Most(qubits), Tail(qubits));
        }
    }

    operation MarkSolution(markIndex : Int, numberOfQubits : Int, qubits : Qubit[]) : Unit is Adj {
        within {
            let markerBits = IntAsBoolArray(markIndex, numberOfQubits);
            for i in 0..numberOfQubits-1
            {
                if not markerBits[i] {
                    X(qubits[i]);
                }
            }
        } apply {
            Controlled Z(Most(qubits), Tail(qubits));
        }
    }
}
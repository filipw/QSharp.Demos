namespace QFT {

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
        ManualThreeQubitQFT();
        LibraryThreeQubitQFT();
    }

    operation ManualThreeQubitQFT() : Unit {
        use qubits = Qubit[3];
        X(qubits[0]);

        H(qubits[0]);
        Controlled Rz([qubits[1]], (PI()/2.0, qubits[0]));
        Controlled Rz([qubits[2]], (PI()/4.0, qubits[0]));

        H(qubits[1]);
        Controlled Rz([qubits[2]], (PI()/2.0, qubits[1]));

        H(qubits[2]);
        SWAP(qubits[2], qubits[0]);

        DumpMachine();
        ResetAll(qubits);
    }

    operation LibraryThreeQubitQFT() : Unit {
        use qubits = Qubit[3];
        X(qubits[0]);

        let register = BigEndian(qubits);
        QFT(register);

        DumpMachine();
        ResetAll(qubits);
    }
}
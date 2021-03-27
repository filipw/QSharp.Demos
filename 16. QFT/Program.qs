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
        use qubits = Qubit[4];
        ManualFourQubitQFT1(qubits);
        ManualFourQubitQFT2(qubits);
        LibraryFourQubitQFT(qubits);
    }

    operation ManualFourQubitQFT1(qubits : Qubit[]) : Unit {
        X(qubits[0]);

        H(qubits[0]);
        Controlled S([qubits[1]], qubits[0]);
        Controlled T([qubits[2]], qubits[0]);
        Controlled Rz([qubits[3]], (PI()/8.0, qubits[0]));

        H(qubits[1]);
        Controlled S([qubits[2]], qubits[1]);
        Controlled T([qubits[3]], qubits[1]);

        H(qubits[2]);
        Controlled S([qubits[3]], qubits[1]);

        H(qubits[3]);
        SWAP(qubits[3], qubits[0]);
        SWAP(qubits[2], qubits[1]);

        DumpMachine();
        ResetAll(qubits);
    }

    operation ManualFourQubitQFT2(qubits : Qubit[]) : Unit {
        X(qubits[0]);

        H(qubits[0]);
        Controlled Rz([qubits[1]], (PI()/2.0, qubits[0]));
        Controlled Rz([qubits[2]], (PI()/4.0, qubits[0]));
        Controlled Rz([qubits[3]], (PI()/8.0, qubits[0]));

        H(qubits[1]);
        Controlled Rz([qubits[2]], (PI()/2.0, qubits[1]));
        Controlled Rz([qubits[3]], (PI()/4.0, qubits[1]));

        H(qubits[2]);
        Controlled Rz([qubits[3]], (PI()/2.0, qubits[1]));

        H(qubits[3]);
        SWAP(qubits[3], qubits[0]);
        SWAP(qubits[2], qubits[1]);

        DumpMachine();
        ResetAll(qubits);
    }

    operation LibraryFourQubitQFT(qubits : Qubit[]) : Unit {
        X(qubits[0]);

        let register = BigEndian(qubits);
        QFT(register);

        DumpMachine();
        ResetAll(qubits);
    }
}
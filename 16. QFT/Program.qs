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
        FourQubitQFTBE();
        LibraryFourQubitQFTBE();

        FourQubitQFTLE();
        LibraryFourQubitQFTLE();
    }

    // Nielsen and Chuang use Big Endian
    operation FourQubitQFTBE() : Unit {
        use qubits = Qubit[4];
        let register = BigEndian(qubits);
        X(qubits[0]);

        H(qubits[0]);
        Controlled S([qubits[1]], qubits[0]);
        Controlled T([qubits[2]], qubits[0]);
        Controlled Rz([qubits[3]], (PI()/8.0, qubits[0]));

        H(qubits[1]);
        Controlled S([qubits[2]], qubits[1]);
        Controlled T([qubits[3]], qubits[1]);

        H(qubits[2]);
        Controlled S([qubits[3]], qubits[2]);

        H(qubits[3]);
        SWAP(qubits[2], qubits[1]);
        SWAP(qubits[3], qubits[0]);
        DumpMachine();
        ResetAll(qubits);
    }

    operation LibraryFourQubitQFTBE() : Unit {
        use qubits = Qubit[4];

        let register = BigEndian(qubits);
        X(qubits[0]);
        QFT(register);

        DumpMachine();
        ResetAll(qubits);
    }

    operation FourQubitQFTLE() : Unit {
        use qubits = Qubit[4];
        let register = LittleEndian(qubits);
        ApplyXorInPlace(8, register);

        H(qubits[3]);
        Controlled S([qubits[2]], qubits[3]);
        Controlled T([qubits[1]], qubits[3]);
        Controlled Rz([qubits[0]], (PI()/8.0, qubits[3]));

        H(qubits[2]);
        Controlled S([qubits[1]], qubits[2]);
        Controlled T([qubits[0]], qubits[2]);

        H(qubits[1]);
        Controlled S([qubits[0]], qubits[1]);

        H(qubits[0]);
        SWAP(qubits[1], qubits[2]);
        SWAP(qubits[0], qubits[3]);

        DumpMachine();
        ResetAll(qubits);
    }

    operation LibraryFourQubitQFTLE() : Unit {
        use qubits = Qubit[4];

        let register = LittleEndian(qubits);
        ApplyXorInPlace(8, register);
        QFTLE(register);

        DumpMachine();
        ResetAll(qubits);
    }
}
namespace GroverBasic {

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
        let result = TwoQubitFixedSearch();
        Message($"Expected to find a fixed: 2, found: {result}");

        for i in 0..3 {
            let found = TwoQubitGenericSearch(i);
            Message($"Expected to find: {i}, found: {found}");
        }
    }

    // 2 is marked
    operation TwoQubitFixedSearch() : Int {
        use (q1, q2) = (Qubit(), Qubit());

        // superposition
        H(q1);
        H(q2);
        DumpMachine();

        // CPHASE or CR(π), only flips the phase of |11>
        CZ(q1, q2);
        DumpMachine();

        // swap phase change to state -|10>
        X(q1);
        DumpMachine();

        // invert about the mean
        H(q1);
        H(q2);
        DumpMachine();

        X(q1);
        X(q2);
        DumpMachine();

        CZ(q1, q2);
        DumpMachine();

        X(q1);
        X(q2);
        DumpMachine();

        H(q1);
        H(q2);

        DumpMachine();

        let register = LittleEndian([q1, q2]);
        let number = MeasureInteger(register);
        return number;
    }    

    operation TwoQubitGenericSearch(markIndex : Int) : Int {
        use qubits = Qubit[2];

        // superposition
        ApplyToEachA(H, qubits);

        // CPHASE or CR(π), only flips the phase of |11>
        CZ(qubits[0], qubits[1]);

        // swap phase change to desired state
        if (markIndex == 1 or markIndex == 0) {
            X(qubits[1]);
        }
        if (markIndex == 2 or markIndex == 0) {
            X(qubits[0]);
        }

        // invert about the mean
        ApplyToEachA(H, qubits);
        ApplyToEachA(X, qubits);
        CZ(qubits[0], qubits[1]);
        ApplyToEachA(X, qubits);
        ApplyToEachA(H, qubits);

        let register = LittleEndian(qubits);
        let number = MeasureInteger(register);
        return number;
    }
}
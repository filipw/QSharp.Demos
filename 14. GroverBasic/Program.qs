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
        // 2 is marked
        let result = Simple();
        Message($"Measured simple: {result}");

        // marked input and amount of qubits is configurable
        let complex = Complex(10, 4);
        Message($"Measured complex: {complex}");
    }

    operation Simple() : Int {
        use (q1, q2) = (Qubit(), Qubit());

        // superposition
        H(q1);
        H(q2);
        DumpMachine();

        // CPHASE or CR(π), only flips the phase of |11>
        CZ(q1, q2);
        DumpMachine();

        // swap phase change to state -|01>
        X(q1);
        DumpMachine();

        // amplitude amplification
        X(q1);
        X(q2);
        H(q1);
        H(q2);
        CZ(q1, q2);
        H(q1);
        H(q2);

        DumpMachine();

        let register = LittleEndian([q1, q2]);
        let number = MeasureInteger(register);
        Reset(q1);
        Reset(q2);

        return number;
    }

    operation Complex(markedNumber : Int, numberOfQubits : Int) : Int {
        use qubits = Qubit[numberOfQubits];

        // superposition
        ApplyToEachA(H, qubits);
        DumpMachine();

        // CPHASE or CR(π), only flips the phase of |11..1>
        Controlled Z(Most(qubits), Tail(qubits));
        DumpMachine();

        // swap phase change onto the marked output
        let markerBits = IntAsBoolArray(markedNumber, numberOfQubits);
        for i in 0..numberOfQubits-1
        {
            if not markerBits[i] {
                X(qubits[i]);
            }
        }
        DumpMachine();

        // amplitude amplification
        ApplyToEachA(H, qubits);
        ApplyToEachA(X, qubits);
        Controlled Z(Most(qubits), Tail(qubits));
        ApplyToEachA(X, qubits);
        ApplyToEachA(H, qubits);
        DumpMachine();

        let register = LittleEndian(qubits);
        let number = MeasureInteger(register);
        ResetAll(qubits);

        return number;
    }
}
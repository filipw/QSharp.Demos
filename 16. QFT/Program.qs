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
        ApplyToEach(H, qubits);
        Z(qubits[0]);
        DumpMachine();
        let register = LittleEndian(qubits);
        ApplyQuantumFourierTransform(register);
        DumpMachine();
        ResetAll(qubits);
    }
}
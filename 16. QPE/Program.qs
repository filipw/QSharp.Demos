namespace QPE {

    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Oracles;
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
        use eigenstate = Qubit();

        // *********************
        Message("Z gate");
        Message("");

        Message("Expected result: 0 degrees");
        PreparePauliEigenstate(PauliZ, eigenstate);
        RunLibraryEstimation(eigenstate, UForPauliZ, 3);

        PreparePauliEigenstate(PauliZ, eigenstate);
        RunManualEstimation(eigenstate, UForPauliZ, 3);

        Message("");

        Message("Expected result: 180 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, UForPauliZ, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, UForPauliZ, 3);
        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("T gate");
        Message("");

        Message("Expected result: 0 degrees");
        I(eigenstate);
        RunLibraryEstimation(eigenstate, UForT, 3);

        I(eigenstate);
        RunManualEstimation(eigenstate, UForT, 3);

        Message("");

        Message("Expected result: 45 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, UForT, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, UForT, 3);
        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("S gate");
        Message("");

        Message("Expected result: 0 degrees");
        I(eigenstate);
        RunLibraryEstimation(eigenstate, UForS, 3);

        I(eigenstate);
        RunManualEstimation(eigenstate, UForS, 3);

        Message("");

        Message("Expected result: 90 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, UForS, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, UForS, 3);

        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("H gate");
        Message("");

        Message("Expected result: 180 degrees");
        Ry(-0.75 * PI(), eigenstate);
        RunLibraryEstimation(eigenstate, UForH, 3);

        Ry(-0.75 * PI(), eigenstate);
        RunManualEstimation(eigenstate, UForH, 3);

        Message("");

        Message("Expected result: 0 degrees");
        Ry(0.25 * PI(), eigenstate);
        RunLibraryEstimation(eigenstate, UForH, 3);

        Ry(0.25 * PI(), eigenstate);
        RunManualEstimation(eigenstate, UForH, 3);
    }

    operation RunLibraryEstimation(eigenstate : Qubit, U : ((Int, Qubit[]) => Unit is Adj + Ctl), precision : Int) : Unit {
        use qubits = Qubit[precision];
        QuantumPhaseEstimation(DiscreteOracle(U), [eigenstate], BigEndian(qubits));

        let phase = IntAsDouble(MeasureInteger(LittleEndian(Reversed(qubits)))) * 360.0 / IntAsDouble(2^precision);
        Message($"Library estimation result with precision {precision}: {phase} degrees");
        ResetAll(qubits);
        Reset(eigenstate);
    }

    operation RunManualEstimation(eigenstate : Qubit, U : ((Int, Qubit[]) => Unit is Adj + Ctl), precision : Int) : Unit {
        use qubits = Qubit[precision];
        let register = LittleEndian(qubits);
            
        ApplyToEachA(H, qubits);

        for i in 0 .. precision - 1 {
            Controlled U([qubits[i]], (2^i, [eigenstate]));
        }

        Adjoint QFTLE(register);

        let phase = IntAsDouble(MeasureInteger(register)) * 360.0 / IntAsDouble(2^precision);
        Message($"Manual estimation result with precision {precision}: {phase} degrees");
        ResetAll(qubits);
        Reset(eigenstate);
    }

    operation UForH(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            H(qubits[0]);
        }
    }

    operation UForPauliZ(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            Z(qubits[0]);
        }
    }

    operation UForT(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            T(qubits[0]);
        }
    }

    operation UForS(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            S(qubits[0]);
        }
    }
}
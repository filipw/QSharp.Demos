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
        RunLibraryEstimation(eigenstate, UZ, 3);

        PreparePauliEigenstate(PauliZ, eigenstate);
        RunManualEstimation(eigenstate, UZ, 3);

        Message("");

        Message("Expected result: 180 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, UZ, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, UZ, 3);
        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("T gate");
        Message("");

        Message("Expected result: 0 degrees");
        I(eigenstate);
        RunLibraryEstimation(eigenstate, UT, 3);

        I(eigenstate);
        RunManualEstimation(eigenstate, UT, 3);

        Message("");

        Message("Expected result: 45 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, UT, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, UT, 3);
        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("S gate");
        Message("");

        Message("Expected result: 0 degrees");
        I(eigenstate);
        RunLibraryEstimation(eigenstate, US, 3);

        I(eigenstate);
        RunManualEstimation(eigenstate, US, 3);

        Message("");

        Message("Expected result: 90 degrees");
        X(eigenstate);
        RunLibraryEstimation(eigenstate, US, 3);

        X(eigenstate);
        RunManualEstimation(eigenstate, US, 3);

        Message("");
        Message("");
        // *********************

        // *********************
        Message("**********************");
        Message("H gate");
        Message("");

        Message("Expected result: 180 degrees");
        Ry(-0.75 * PI(), eigenstate);
        RunLibraryEstimation(eigenstate, UH, 3);

        Ry(-0.75 * PI(), eigenstate);
        RunManualEstimation(eigenstate, UH, 3);

        Message("");

        Message("Expected result: 0 degrees");
        Ry(0.25 * PI(), eigenstate);
        RunLibraryEstimation(eigenstate, UH, 3);

        Ry(0.25 * PI(), eigenstate);
        RunManualEstimation(eigenstate, UH, 3);
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

    operation UH(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            H(qubits[0]);
        }
    }

    operation UZ(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            Z(qubits[0]);
        }
    }

    operation UT(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            T(qubits[0]);
        }
    }

    operation US(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
        for _ in 1 .. power {
            S(qubits[0]);
        }
    }
}
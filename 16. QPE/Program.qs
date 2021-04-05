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
        
        let z_oracle = DiscreteOracle(UForPauliZ);
        PreparePauliEigenstate(PauliZ, eigenstate);
        Message("Expected result: 0 degrees");
        RunLibraryEstimation(eigenstate, z_oracle, 3);
        Reset(eigenstate);

        X(eigenstate);
        Message("Expected result: 180 degrees");
        RunLibraryEstimation(eigenstate, z_oracle, 3);
        Reset(eigenstate);


        let t_oracle = DiscreteOracle(UForT);
        I(eigenstate);
        Message("Expected result: 0 degrees");
        RunLibraryEstimation(eigenstate, t_oracle, 3);
        Reset(eigenstate);

        X(eigenstate);
        Message("Expected result: 45 degrees");
        RunLibraryEstimation(eigenstate, t_oracle, 3);
        Reset(eigenstate);

        let s_oracle = DiscreteOracle(UForS);
        I(eigenstate);
        Message("Expected result: 0 degrees");
        RunLibraryEstimation(eigenstate, s_oracle, 3);
        Reset(eigenstate);

        X(eigenstate);
        Message("Expected result: 90 degrees");
        RunLibraryEstimation(eigenstate, s_oracle, 3);
        Reset(eigenstate);


        let h_oracle = DiscreteOracle(UForHadamard);
        Ry(-0.75 * PI(), eigenstate);
        Message("Expected result: 180 degrees");
        RunLibraryEstimation(eigenstate, h_oracle, 3);
        Reset(eigenstate);

        Ry(0.25 * PI(), eigenstate);
        Message("Expected result: 0 degrees");
        RunLibraryEstimation(eigenstate, h_oracle, 3);
        Reset(eigenstate);
    }

    operation RunLibraryEstimation(state : Qubit, oracle : DiscreteOracle, precision : Int) : Unit {
        use qubits = Qubit[precision];
            
        QuantumPhaseEstimation(oracle, [state], BigEndian(qubits));

        let phase = IntAsDouble(MeasureInteger(LittleEndian(Reversed(qubits)))) * 360.0 / IntAsDouble(2^precision);
        Message($"Estimation result with precision {precision}: {phase} degrees");
        ResetAll(qubits);
    }

    operation UForHadamard(power : Int, qubits : Qubit[]) : Unit is Adj + Ctl {
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
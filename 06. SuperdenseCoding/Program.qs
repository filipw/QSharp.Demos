namespace SuperdenseCoding {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    

    @EntryPoint()
    operation Start() : Unit {
        TestDenseCoding(false, false); // encode 00
        TestDenseCoding(false, true); // encode 01
        TestDenseCoding(true, false); // encode 10
        TestDenseCoding(true, true); // encode 11
    }

    operation TestDenseCoding(val0 : Bool, val1 : Bool) : Unit {
        using ((q0, q1) = (Qubit(), Qubit())) {
                // prepare the maximally entangled state |Φ⁺⟩ between qubits
                PrepareEntangledState([q0], [q1]);
                Encode(val0, val1, q0);
                Decode(q0, q1);
        }
        Message("***************");
    }

    operation Encode(val0 : Bool, val1 : Bool, qubit : Qubit) : Unit {
        mutable encoded = "";
        // if we encode 00, use Pauli I to keep |Φ⁺⟩
        if (not val0 and not val1) {
            I(qubit);
            set encoded = "00";
        }

        // if we encode 01, use Pauli X to create |Ψ⁺⟩
        if (not val0 and val1) {
            X(qubit);
            set encoded = "01";
        }

        // if we encode 10, use Pauli Z to create |Φ⁻⟩
        if (val0 and not val1) {
            Z(qubit);
            set encoded = "10";
        }

        // if we encode 11, use Pauli Y to create |Ψ⁻⟩
        if (val0 and val1) {
            Y(qubit);
            set encoded = "11";
        }
        Message("Encoded: " + encoded);
    }

    operation Decode(q0 : Qubit, q1 : Qubit) : Unit {
        // apply reverse Bell circuit
        CNOT(q0, q1);
        H(q0);

        // measure both
        let result0 = MResetZ(q0);
        let result1 = MResetZ(q1);
        Message("Decoded: " + (result0 == One ? "1" | "0") + (result1 == One ? "1" | "0"));
    }
}
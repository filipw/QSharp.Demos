﻿namespace QubitExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    

    @EntryPoint()
    operation Start() : Unit {

        // measurement in Z basis should produce 0 result 100% of time 
        MeasureQubits(100, PauliZ);

        // measurement in X basis should produce 0 result 50% of time
        // and 1 result the other 50% of time
        MeasureQubits(100, PauliX);
    }

    operation MeasureQubits(count : Int, measurementBasis : Pauli) : Unit {

        mutable resultsTotal = 0;
        Message("Running qubit measurement " + IntAsString(count) + " times");

        using (qubit = Qubit()) {

            for (idx in 0..count) {
                let result = Measure([measurementBasis], [qubit]);
                set resultsTotal += result == One ? 1 | 0;
                Reset(qubit);
            }

            Message($"Received " + IntAsString(resultsTotal) + " ones.");
            Message($"Received " + IntAsString(count - resultsTotal) + " zeros.");
        }
    }
}
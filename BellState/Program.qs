﻿namespace BellStateExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    

    @EntryPoint()
    operation Start() : Unit {

        Message("Measuring control qubit in PauliZ and target qubit in PauliZ");
        BellState(false, false, PauliZ, PauliZ); // |00>
        BellState(false, true, PauliZ, PauliZ); // |01> 
        BellState(true, false, PauliZ, PauliZ); // |10> 
        BellState(true, true, PauliZ, PauliZ); // |11> 

        Message("");
        Message("***********");
        Message("Measuring control qubit in PauliZ and target qubit in PauliX");
        BellState(false, false, PauliZ, PauliX); // |00> 
        BellState(false, true, PauliZ, PauliX); // |01> 
        BellState(true, false, PauliZ, PauliX); // |10> 
        BellState(true, true, PauliZ, PauliX); // |11> 

        Message("");
        Message("***********");
        Message("Measuring control qubit in PauliX and target qubit in PauliX");
        BellState(false, false, PauliX, PauliX); // |00> 
        BellState(false, true, PauliX, PauliX); // |01> 
        BellState(true, false, PauliX, PauliX); // |10> 
        BellState(true, true, PauliX, PauliX); // |11> 
    }

    operation BellState(controlInitialState : Bool, targetInitialState : Bool, controlMeasurementBasis : Pauli, targetMeasureMeasurementBasis : Pauli) : Unit {
        mutable matchingMeasurement = 0;
        mutable zeroZero = 0;
        mutable zeroOne = 0;
        mutable oneZero = 0;
        mutable oneOne = 0;

        for (run in 0..999) {
            using ((control, target) = (Qubit(), Qubit())) {
                    PrepareQubitState(control, controlInitialState);
                    PrepareQubitState(target, targetInitialState);

                    // these are interchangeable
                    PrepareEntangledState([control], [target]);
                    // H(control);
                    // CNOT(control, target);
                    
                    let resultControl = Measure([controlMeasurementBasis], [control]);
                    let resultTarget = Measure([targetMeasureMeasurementBasis], [target]);
                    ResetAll([control, target]);

                    set zeroZero += resultControl == Zero and resultTarget == Zero ? 1 | 0;
                    set zeroOne += resultControl == Zero and resultTarget == One ? 1 | 0;
                    set oneZero += resultControl == One and resultTarget == Zero ? 1 | 0;
                    set oneOne += resultControl == One and resultTarget == One ? 1 | 0;
                    set matchingMeasurement += resultControl == resultTarget ? 1 | 0;
            }
        }
        
        Message("Initial system state: |" + (controlInitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +">");
        Message("|00>: " + IntAsString(zeroZero));
        Message("|01>: " + IntAsString(zeroOne));
        Message("|10>: " + IntAsString(oneZero));
        Message("|11>: " + IntAsString(oneOne));
        Message("Measurements of two qubits matched: " + IntAsString(matchingMeasurement));
    }

    operation PrepareQubitState(qubit : Qubit, initialState : Bool) : Unit is Adj
    {
        if (initialState) {
            X(qubit);
        }       
    }
}


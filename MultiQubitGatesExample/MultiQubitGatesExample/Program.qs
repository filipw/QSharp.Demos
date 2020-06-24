namespace MultiQubitGatesExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    

    @EntryPoint()
    operation HelloQ() : Unit {
        
        Message("CNOT");
        ControlledNotSample(false, false); // |00> 
        ControlledNotSample(false, true); // |01> 
        ControlledNotSample(true, false); // |10> 
        ControlledNotSample(true, true); // |11> 
        
        Message("***********");
        
        Message("CNOT via functor");
        ControlledNotSampleFunctor(false, false); // |00> 
        ControlledNotSampleFunctor(false, true); // |01> 
        ControlledNotSampleFunctor(true, false); // |10> 
        ControlledNotSampleFunctor(true, true); // |11> 

        Message("***********");
        
        Message("SWAP");
        SwapSample(false, false); // |00> 
        SwapSample(false, true); // |01> 
        SwapSample(true, false); // |10> 
        SwapSample(true, true); // |11> 

        Message("***********");

        Message("SWAP with CNOTs");
        SwapSampleWithCnots(false, false); // |00> 
        SwapSampleWithCnots(false, true); // |01> 
        SwapSampleWithCnots(true, false); // |10> 
        SwapSampleWithCnots(true, true); // |11> 

        Message("***********");

        Message("Toffoli");
        ToffoliSample(false, false, false); // |000> 
        ToffoliSample(false, false, true); // |001> 
        ToffoliSample(false, true, false); // |010> 
        ToffoliSample(true, false, false); // |100> 
        ToffoliSample(false, true, true); // |011> 
        ToffoliSample(true, false, true); // |101> 
        ToffoliSample(true, true, false); // |110> 
        ToffoliSample(true, true, true); // |111> 
    }

    operation ControlledNotSample(controlInitialState : Bool, targetInitialState : Bool) : Unit {
        using ((control, target) = (Qubit(), Qubit())) {
                PrepareQubitState(control, controlInitialState);
                PrepareQubitState(target, targetInitialState);

                CNOT(control, target);
                let resultControl = MResetZ(control);
                let resultTarget = MResetZ(target);
                Message("|" + (controlInitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +"> ==> |" + (resultControl == One ? "1" | "0") + (resultTarget == One ? "1" | "0") +">");
        }
    }

    operation ControlledNotSampleFunctor(controlInitialState : Bool, targetInitialState : Bool) : Unit {
        using ((control, target) = (Qubit(), Qubit())) {
                PrepareQubitState(control, controlInitialState);
                PrepareQubitState(target, targetInitialState);

                Controlled X([control], target);
                let resultControl = MResetZ(control);
                let resultTarget = MResetZ(target);
                Message("|" + (controlInitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +"> ==> |" + (resultControl == One ? "1" | "0") + (resultTarget == One ? "1" | "0") +">");
        }
    }

    operation SwapSample(firstState : Bool, secondState : Bool) : Unit {
        using ((first, second) = (Qubit(), Qubit())) {
                PrepareQubitState(first, firstState);
                PrepareQubitState(second, secondState);

                SWAP(first, second);
                let resultFirst = MResetZ(first);
                let resultSecond = MResetZ(second);
                Message("|" + (firstState ? "1" | "0") + (secondState ? "1" | "0") +"> ==> |" + (resultFirst == One ? "1" | "0") + (resultSecond == One ? "1" | "0") +">");
        }
    }

    operation SwapSampleWithCnots(firstState : Bool, secondState : Bool) : Unit {
        using ((first, second) = (Qubit(), Qubit())) {
                PrepareQubitState(first, firstState);
                PrepareQubitState(second, secondState);

                CNOT(first, second);
                CNOT(second, first);
                CNOT(first, second);
                let resultFirst = MResetZ(first);
                let resultSecond = MResetZ(second);
                Message("|" + (firstState ? "1" | "0") + (secondState ? "1" | "0") +"> ==> |" + (resultFirst == One ? "1" | "0") + (resultSecond == One ? "1" | "0") +">");
        }
    }

    operation ToffoliSample(control1InitialState : Bool, control2InitialState : Bool, targetInitialState : Bool) : Unit {
        using ((control1, control2, target) = (Qubit(), Qubit(), Qubit())) {
                PrepareQubitState(control1, control1InitialState);
                PrepareQubitState(control2, control2InitialState);
                PrepareQubitState(target, targetInitialState);

                CCNOT(control1, control2, target);
                let resultControl1 = MResetZ(control1);
                let resultControl2 = MResetZ(control2);
                let resultTarget = MResetZ(target);
                Message("|" + (control1InitialState ? "1" | "0") + (control2InitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +"> ==> |" + (resultControl1 == One ? "1" | "0") + (resultControl2 == One ? "1" | "0") + (resultTarget == One ? "1" | "0") +">");
        }
    }

    operation PrepareQubitState(qubit : Qubit, initialState : Bool) : Unit is Adj
    {
        if (initialState) {
            X(qubit);
        }
    }
}


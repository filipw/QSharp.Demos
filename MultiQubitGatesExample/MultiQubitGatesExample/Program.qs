namespace MultiQubitGatesExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    

    @EntryPoint()
    operation HelloQ() : Unit {
        Message("ControlledNotExample");
        ControlledNotExample(false, false);
        ControlledNotExample(false, true);
        ControlledNotExample(true, false);
        ControlledNotExample(true, true);
        Message("***********");
        Message("ControlledNotExampleAlternative");
        ControlledNotExampleAlternative(false, false);
        ControlledNotExampleAlternative(false, true);
        ControlledNotExampleAlternative(true, false);
        ControlledNotExampleAlternative(true, true);
    }

    operation ControlledNotExample(controlInitialState : Bool, targetInitialState : Bool) : Unit {
        using ((control, target) = (Qubit(), Qubit())) {
                if (controlInitialState) {
                    X(control);
                }

                if (targetInitialState) {
                    X(target);
                }

                CNOT(control, target);
                let resultControl = MResetZ(control);
                let resultTarget = MResetZ(target);
                Message("|" + (controlInitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +"> ==> |" + (resultControl == One ? "1" | "0") + (resultTarget == One ? "1" | "0") +">");
        }
    }

        operation ControlledNotExampleAlternative(controlInitialState : Bool, targetInitialState : Bool) : Unit {
            using ((control, target) = (Qubit(), Qubit())) {
                if (controlInitialState) {
                    X(control);
                }

                if (targetInitialState) {
                    X(target);
                }

                Controlled X([control], target);
                let resultControl = MResetZ(control);
                let resultTarget = MResetZ(target);
                Message("|" + (controlInitialState ? "1" | "0") + (targetInitialState ? "1" | "0") +"> ==> |" + (resultControl == One ? "1" | "0") + (resultTarget == One ? "1" | "0") +">");
        }
    }
}


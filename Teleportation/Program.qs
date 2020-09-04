namespace TeleportationExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Preparation;
    

    @EntryPoint()
    operation Start() : Unit {
            for (idx in 0..3) {
                Message("Teleporting |->");
                Teleport(false); // send |->
            }

            Message("***********");

            for (idx in 0..3) {
                Message("Teleporting |+>");
                Teleport(true); // send |+>
            }
    }

    operation Teleport (signToSend : Bool) : Unit {
         // message represents the quantum state to teleport
         // resource represents the qubit that will be used as teleportation resource
         // target represents the qubit onto which the message will be teleported
         using ((message, resource, target) = (Qubit(), Qubit(), Qubit())) {

            // prepare |-> or |+>
            if (signToSend == false) { X(message); }
            H(message);

            // create entanglement between resource and target
            H(resource);
            CNOT(resource, target);

            // reverse Bell circuit on message and resource
            CNOT(message, resource);
            H(message);

            // mesaure message and resource
            // to complete the Bell measurement
            let messageResult = MResetZ(message);
            let resourceResult = MResetZ(resource);

            // if we got |00>, there is nothing to do on the target
            if (messageResult == Zero and resourceResult == Zero) { 
                Message("Measured |00>, applying I");
                I(target); 
            } 

            // if we got |01>, we need to apply X on the target
            if (messageResult == Zero and resourceResult == One) { 
                Message("Measured |01>, applying X");
                X(target); 
            } 

            // if we got |10>, we need to apply Z on the target
            if (messageResult == One and resourceResult == Zero) { 
                Message("Measured |10>, applying Z");
                Z(target); 
            } 

            // if we got |11>, we need to apply XZ on the target
            if (messageResult == One and resourceResult == One) { 
                Message("Measured |11>, applying XZ");
                X(target); 
                Z(target); 
            } 
            
            let teleportedResult = Measure([PauliX], [target]);
            Message("Teleported state was measured to be: " + (teleportedResult == Zero ? "|+>" | "|->"));
            Reset(target);
        }
    }
}
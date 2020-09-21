namespace SuperposttionExample {

    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    
    @EntryPoint()
    operation Start() : Unit {

        MeasureQubits(1000);
        Message("***********");

        let randomBits = RandomNumberGenerator();
        Message("Generated random uint32: " + IntAsString(BoolArrayAsInt(randomBits)));
    }


    operation MeasureQubits(count : Int) : Unit {

        mutable resultsTotal = 0;

        using (qubit = Qubit()) {
            for (idx in 0..count) {
                H(qubit);                
                let result = MResetZ(qubit);
                set resultsTotal += result == One ? 1 | 0;
            }
        }

        Message($"Received " + IntAsString(resultsTotal) + " ones.");
        Message($"Received " + IntAsString(count - resultsTotal) + " zeros.");
    }

    operation RandomNumberGenerator() : Bool[] {

        mutable randomBits = new Bool[32];
        
        for (idx in 0..31) {
            using(qubit = Qubit())  {   
                H(qubit);                
                let result = MResetZ(qubit);
                set randomBits w/= idx <- result == One;
            }
        }
        
        return randomBits;
    }   
}
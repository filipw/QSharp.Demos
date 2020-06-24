namespace QubitExample {

    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    

    operation MeasureQubits(count : Int) : Int {

        mutable resultsTotal = 0;

        using (qubit = Qubit()) {
            for (idx in 0..count) {
                H(qubit);                
                let result = MResetZ(qubit);
                set resultsTotal += result == One ? 1 | 0;
            }

            return resultsTotal;
        }
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
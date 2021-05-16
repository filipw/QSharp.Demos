namespace SuperposttionExample {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    
    @EntryPoint()
    operation Start() : Unit {

        MeasureQubits(4096);
        Message("***********");

        let randomBits = RandomNumberGenerator();
        Message($"Generated random uint16: {BoolArrayAsInt(randomBits)}");

        let randomBits2 = RandomNumberGenerator();
        Message($"Generated random uint16 v2: {BoolArrayAsInt(randomBits2)}");
    }


    operation MeasureQubits(count : Int) : Unit {

        mutable resultsTotal = 0;

        use qubit = Qubit();
        for idx in 0..count {
            H(qubit);                
            let result = MResetZ(qubit);
            set resultsTotal += result == One ? 1 | 0;
        }

        Message($"Received " + IntAsString(resultsTotal) + " ones.");
        Message($"Received " + IntAsString(count - resultsTotal) + " zeros.");
    }

    operation RandomNumberGenerator() : Bool[] {

        mutable randomBits = new Bool[16];
        
        for idx in 0..15 {
            use qubit = Qubit();   
            H(qubit);                
            let result = MResetZ(qubit);
            set randomBits w/= idx <- result == One;
        }
        
        return randomBits;
    }   

    operation RandomNumberGeneratorV2() : Int {
        use qubits = Qubit[16];
        ApplyToEach(H, qubits);

        // create a QPU register
        let register = LittleEndian(qubits);

        // measure the entire register to retrieve the integer
        let randomNumber = MeasureInteger(register);
        
        return randomNumber;
    }  
}
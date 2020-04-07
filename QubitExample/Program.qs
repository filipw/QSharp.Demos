namespace QubitExample {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    

    operation MeasureQubits(count : Int) : Int {

        mutable resultsTotal = 0;

        using (qubit = Qubit()) {

            for (idx in 0..count) {
                
                //let result = MResetZ(qubit);

                let result = Measure([PauliX], [qubit]);
                set resultsTotal += result == One ? 1 | 0;
                Reset(qubit);
            }

            return resultsTotal;
        }
    }
}
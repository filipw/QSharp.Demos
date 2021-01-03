namespace CHSH {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;

    @EntryPoint()
    operation Main() : Unit {
        let runs = 4096;
        mutable classicalWins = 0;
        mutable quantumWins = 0;
        for (i in 0..runs) {
            let aliceBit = DrawRandomBool(0.5);
            let bobBit = DrawRandomBool(0.5);

            let classicalChosenBits = RunClassicalStrategy(aliceBit, bobBit);
            if ((aliceBit and bobBit) == Xor(classicalChosenBits))
            {
                set classicalWins += 1;
            }

            let quantumChosenBits = RunQuantumStrategy(aliceBit, bobBit);
            if ((aliceBit and bobBit) == Xor(quantumChosenBits))
            {
                set quantumWins += 1;
            }
        }

        let classicalWinRate = IntAsDouble(classicalWins) / IntAsDouble(runs);
        let quantumWinRate = IntAsDouble(quantumWins) / IntAsDouble(runs);
        Message($"Classical win probability: {DoubleAsString(classicalWinRate * 100.0)}");
        Message($"Quantum win probability: {DoubleAsString(quantumWinRate * 100.0)}");
    }
 
    function RunClassicalStrategy(aliceBit : Bool, bobBit : Bool) : (Bool, Bool) {
        // return (1,1) irrespective of input bits
        return (true, true);
    }

    operation RunQuantumStrategy(aliceBit : Bool, bobBit : Bool) : (Bool, Bool) {
        using ((aliceQubit, bobQubit) = (Qubit(), Qubit())) {
            InitBellState(aliceQubit, bobQubit);

            let shouldAliceMeasureFirst = DrawRandomBool(0.5);
            if (shouldAliceMeasureFirst) {
                return (AliceMeasurement(aliceBit, aliceQubit), not BobMeasurement(bobBit, bobQubit));
            } 
            else 
            {
                let bobResult = not BobMeasurement(bobBit, bobQubit);
                let aliceResult = AliceMeasurement(aliceBit, aliceQubit);
                return (aliceResult, bobResult);
            }
        }
    }

    operation InitBellState(q1 : Qubit, q2: Qubit) : Unit is Adj {
        X(q1);
        X(q2);
        H(q1);
        CNOT(q1, q2);
    }

    operation AliceMeasurement(bit : Bool, q : Qubit) : Bool {
        let result = Measure([bit ? PauliX | PauliZ], [q]) == One;
        Reset(q);
        return result;

        // different way of expressing the same
        // X basis is the coputational basis rotated by -π/4
        // let rotationAngle = bit ? (-2.0 * PI() / 4.0) | 0.0;
        // Ry(rotationAngle, q);
        // return MResetZ(q) == One;
    }

    operation BobMeasurement(bit : Bool, q : Qubit) : Bool {
        // if bit = 0, measure in computational basis rotated by -π/8
        // if bit = 1, measure in computational basis rotated by π/8
        // this ensures win probability equal to cos²(π/8)
        let rotationAngle = bit ? (2.0 * PI() / 8.0) | (-2.0 * PI() / 8.0);
        Ry(rotationAngle, q);
        return MResetZ(q) == One;  
    }
}
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
        for (i in 0..runs) {
            let aliceBit = DrawRandomBool(0.5);
            let bobBit = DrawRandomBool(0.5);

            let classicalChosenBits = RunClassicalStrategy();
            if ((aliceBit and bobBit) == Xor(classicalChosenBits))
            {
                set classicalWins += 1;
            }
        }

        let classicalWinRate = IntAsDouble(classicalWins) / IntAsDouble(runs);
        Message($"Classical win probability: {DoubleAsString(classicalWinRate * 100.0)}");
    }
 
    function RunClassicalStrategy() : (Bool, Bool) {
        return (true, true);
    }
}
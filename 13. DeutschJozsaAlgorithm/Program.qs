namespace DeutschJozsaAlgorithm {

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
         Message($"f0 is {RunDeutschAlogirthm(5, OracleF0) ? "constant" | "balanced"}.");
         Message($"f1 is {RunDeutschAlogirthm(5, OracleF1) ? "constant" | "balanced"}.");
         Message($"f2 is {RunDeutschAlogirthm(5, OracleF2) ? "constant" | "balanced"}.");
         Message($"f3 is {RunDeutschAlogirthm(5, OracleF3) ? "constant" | "balanced"}.");
    }

    operation RunDeutschAlogirthm(n : Int, oracle : ((Qubit[], Qubit) => Unit)) : Bool {
        mutable isFunctionConstant = true;
        using ((qn, q2) = (Qubit[n], Qubit())) {
            X(q2);
            ApplyToEachA(H, qn);                                
            H(q2);

            oracle(qn, q2);                       

            ApplyToEachA(H, qn);                                

            // |0...0> means the functions is constant
            if (MeasureAllZ(qn) != Zero) {
                set isFunctionConstant = false;
            }

            ResetAll(qn);       
            Reset(q2);       
        }
        return isFunctionConstant;
    }

    operation OracleF0(qn : Qubit[], q2 : Qubit) : Unit is Adj {
        // constant 0
        // f(n...m) = 0
    }

    operation OracleF1(qn : Qubit[], q2 : Qubit) : Unit is Adj  {
        // constant 1
        // f(n..m) = 1
        X(q2);
    }

    operation OracleF2(qn : Qubit[], q2 : Qubit) : Unit is Adj  {
        // balanced
        // f(n..m) = 0 when n ⊕ ... ⊕ m = 0
        // f(n..m) = 1 when n ⊕ ... ⊕ m = 1
        for (q in qn) {
            CNOT(q, q2);
        }
    }

    operation OracleF3(qn : Qubit[], q2 : Qubit) : Unit is Adj {
        // balanced opposite
        // f(n..m) = 1 when n ⊕ ... ⊕ m = 0
        // f(n..m) = 0 when n ⊕ ... ⊕ m = 1
        for (q in qn) {
            CNOT(q, q2);
        }
        X(q2);
    }
}
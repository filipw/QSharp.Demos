namespace DeutschAlgorithm {

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
        Message($"f0 is {IsConstant(OracleF0) ? "" | "not"} constant.");
        Message($"f1 is {IsConstant(OracleF1) ? "" | "not"} constant.");
        Message($"f2 is {IsConstant(OracleF2) ? "" | "not"} constant.");
        Message($"f3 is {IsConstant(OracleF3) ? "" | "not"} constant.");
    }

    operation IsConstant(oracle : ((Qubit, Qubit) => Unit)) : Bool {
        mutable isConstantFunction = true;
        using ((q1, q2) = (Qubit(), Qubit())) {
            H(q1);                                    
            X(q2);
            H(q2);

            oracle(q1, q2);                       

            H(q1);                                     

            set isConstantFunction = MResetZ(q1) == Zero;         
            Reset(q2);       
        }
        return isConstantFunction;
    }

    operation OracleF0(q1 : Qubit, q2 : Qubit) : Unit is Adj {
        // constant 0
        // f(0) = f(1) = 0
    }

    operation OracleF1(q1 : Qubit, q2 : Qubit) : Unit is Adj  {
        // constant 1
        // f(0) = f(1) = 1
        X(q2);
    }

    operation OracleF2(q1 : Qubit, q2 : Qubit) : Unit is Adj  {
        // balanced same
        // f(0) = 0, f(1) = 1
        CNOT(q1, q2);
    }

    operation OracleF3(q1 : Qubit, q2 : Qubit) : Unit is Adj {
        // balanced opposite
        // f(0) = 1, f(1) = 0
        CNOT(q1, q2);
        X(q1);
    }
}
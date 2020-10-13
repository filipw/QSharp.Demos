using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace SingleQubitGatesExample
{
    class Driver
    {
        static async Task Main(string[] args)
        {
            await Run((qsim, iterations) => Identity.Run(qsim, iterations));
            await Run((qsim, iterations) => Bitflip.Run(qsim, iterations));
            await Run((qsim, iterations) => HZH.Run(qsim, iterations));
            await Run((qsim, iterations) => Rx45.Run(qsim, iterations));
        }

        static async Task Run(Func<IOperationFactory, int, Task<long>> operation)
        {
            using var qsim = new QuantumSimulator();
            var iterations = 1000;

            Console.WriteLine($"Running qubit measurement {iterations} times.");
            var results = await operation(qsim, iterations);
            Console.WriteLine($"Received {results} ones.");
            Console.WriteLine($"Received {iterations - results} zeros.");
            Console.WriteLine();
        }
    }
}
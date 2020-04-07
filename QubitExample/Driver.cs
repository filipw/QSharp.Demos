using System;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace QubitExample
{
    class Driver
    {
        static async Task Main(string[] args)
        {
            using var qsim = new QuantumSimulator();
            var repeats = 100;
            Console.WriteLine($"Running qubit measurement {repeats} times.");

            var results = await MeasureQubits.Run(qsim, repeats);
            Console.WriteLine($"Received {results} ones.");
            Console.WriteLine($"Received {repeats - results} zeros.");
        }
    }
}
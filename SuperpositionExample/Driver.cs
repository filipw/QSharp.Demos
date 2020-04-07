using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
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
            var repeats = 1000;
            Console.WriteLine($"Running qubit measurement {repeats} times.");

            var results = await MeasureQubits.Run(qsim, repeats);
            Console.WriteLine($"Received {results} ones.");
            Console.WriteLine($"Received {repeats - results} zeros.");

            var randomBits = await RandomNumberGenerator.Run(qsim);
            var bitString = string.Join("", randomBits.Select(x => x ? 1 : 0));
            Console.WriteLine($"Generated random bit string: {bitString}");
            Console.WriteLine($"Generated random uint32: {Convert.ToUInt32(bitString, 2)}");
        }
    }
}
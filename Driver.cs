using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

using System;
using System.Numerics;

namespace QArith
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var sim = new QuantumSimulator())
            {
                var thetas1 = new double[4];
                var phis1 = new double[4];
                var thetas2 = new double[4];
                var phis2 = new double[4];
                var randGen = new Random();

                for(int i = 0; i < 4; i++) {
                    thetas1[i] = randGen.NextDouble() * Math.PI;
                    phis1[i] = randGen.NextDouble() * 2 * Math.PI;
                    thetas2[i] = randGen.NextDouble() * Math.PI;
                    phis2[i] = randGen.NextDouble() * 2 * Math.PI;
                }

                var res = AddTest.Run(sim, new QArray<double>(thetas1), new QArray<double>(phis1), new QArray<double>(thetas2), new QArray<double>(phis2)).Result;
                var (sum,op2) = res;
                var op1 = (sum - op2 + 16) % 16;

                System.Console.WriteLine("QInt #1:");
                for(int i = 0; i < 4; i++) {
                    var (x,y) = FromBlochSphere(thetas1[i], phis1[i]);
                    System.Console.WriteLine(
                        $"\t{x,4:N2}|0> + ({y.Real,5:N2} + {y.Imaginary,5:N2}i)|1>"
                    );
                }
                System.Console.WriteLine();
                System.Console.WriteLine("P(bit == 1):");
                System.Console.Write("\t");
                for(int i = 0; i < 4; i++) {
                    var (x,y) = FromBlochSphere(thetas1[i], phis1[i]);
                    System.Console.Write(
                        $"{y.Magnitude:N2} "
                    );
                }
                System.Console.WriteLine();
                System.Console.WriteLine();
                System.Console.WriteLine("QInt #2:");
                for(int i = 0; i < 4; i++) {
                    var (x,y) = FromBlochSphere(thetas2[i], phis2[i]);
                    System.Console.WriteLine(
                        $"\t{x,4:N2}|0> + ({y.Real,5:N2} + {y.Imaginary,5:N2}i)|1>"
                    );
                }
                System.Console.WriteLine();
                System.Console.WriteLine("P(bit == 1):");
                System.Console.Write("\t");
                for(int i = 0; i < 4; i++) {
                    var (x,y) = FromBlochSphere(thetas2[i], phis2[i]);
                    System.Console.Write(
                        $"{y.Magnitude:N2} "
                    );
                }
                System.Console.WriteLine();
                System.Console.WriteLine();
                System.Console.WriteLine(
                    $"Measured sum: {sum,3}.  Measured op2: {op2,3}.  Inferred op1: {op1,3}."
                );
            }
            System.Console.WriteLine("Press any key to continue...");
            System.Console.ReadKey();
        }

        static (Double, Complex) FromBlochSphere(double theta, double phi) {
            var xcomp = Math.Cos(theta/2);
            var ycomp = Complex.Exp(phi * Complex.ImaginaryOne) * Math.Sin(theta/2);

            // Normalize the result just in case
            var normFactor = Math.Sqrt(xcomp * xcomp + ycomp.Magnitude);

            xcomp /= normFactor;
            ycomp /= normFactor;
            
            return (xcomp, ycomp);
        }
    }
}
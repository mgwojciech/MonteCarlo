namespace Quantum.MonteCarloIntegral {
    import Std.Math.Complex;
    import Std.Math.PowC;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;

    operation QuantumRandomNumber() : Double {
        let randomGenerationBitSize = 32;
        mutable result = 0;
        for i in 0..(randomGenerationBitSize - 1) {
            use q = Qubit();
            H(q);
            let measurement = M(q);
            Reset(q);
            set result += if measurement == One { 1 <<< i } else { 0 };
        }
        return IntAsDouble(result) / IntAsDouble(1 <<< randomGenerationBitSize);
    }

    operation MonteCarloIntegral(range : (Double, Double), f : (Double -> Double), samples : Int) : Double {
        mutable sum = 0.0;
        let (a, b) = range;
        for _ in 1..samples {
            let x = a + ((b - a) * QuantumRandomNumber());
            set sum += f(x);
        }
        return (b - a) * (sum / IntAsDouble(samples));
    }

    function XSquare(x : Double) : Double {
        return x * x;
    }
    function Gaussian(x : Double) : Double {
        let mean = 0.0;
        let stddev = 1.0;
        let exponent = -((x - mean)^2.0) / (2.0 * stddev^2.0);
        let pow = PowC(Complex(E(),0.0),Complex(exponent,0.0));
        return pow.Real / (stddev * Sqrt(2.0 * PI()));
    }

    @EntryPoint()
    operation Main() : Unit {
        let range = (-100.0, 0.0);
        let samples = 10000;
        let result = MonteCarloIntegral(range, Gaussian, samples);
        Message($"Estimated integral: {result}");
    }
}

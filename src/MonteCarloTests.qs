namespace Quantum.MonteCarloTests {
    import Std.Math.Complex;
    import Std.Math.PowC;
    import Std.Arrays.Sorted;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Quantum.MonteCarloIntegral;

    @Test()
    operation ShouldGenerateRandomNumber() : Unit {
        let randomNumber = QuantumRandomNumberInRage(0.0, 2.0);
        Std.Diagnostics.Fact(randomNumber >= 0.0 and randomNumber <= 2.0, "Generated number should be in valid range")
    }
    @Test()
    operation ShouldGenerateRandomNumberWithNegative() : Unit {
        let randomNumber = QuantumRandomNumberInRage(-2.0, 2.0);
        Std.Diagnostics.Fact(randomNumber >= -2.0 and randomNumber <= 2.0, "Generated number should be in valid range")
    }
    @Test()
    function ShouldCorrectlyCalculateGaussian() : Unit {
        let x = 0.0;
        let fx = Gaussian(x);

        Std.Diagnostics.Fact(Std.Math.AbsD(fx - 0.4) <= 0.01, "Gaussian value should be 0.4")
    }
    @Test()
    operation MonteCarloShouldCorrectlySum() : Unit {
        let range = (-1.0, 1.5);
        let samples = 100;
        let resultSum = MonteCarloIntegral_SUM(range, Gaussian, samples);
        Std.Diagnostics.Fact(Std.Math.AbsD(resultSum - 0.775) <= 0.005, "MonteCarloSUM should correctly sum")
    }
    @Test()
    operation MonteCarloShouldCorrectlySum2() : Unit {
        let range = (-1.0, 1.0);
        let samples = 100;
        let resultSum = MonteCarloIntegral_SUM(range, Gaussian, samples);
        Std.Diagnostics.Fact(Std.Math.AbsD(resultSum - 0.684) <= 0.005, "MonteCarloSUM should correctly sum")
    }
}
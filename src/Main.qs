namespace Quantum.MonteCarloIntegral {
    import Std.Math.Complex;
    import Std.Math.PowC;
    import Std.Arrays.Sorted;
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

    operation QuantumRandomNumberInRage(start : Double, end : Double) : Double {
        return start + ((end - start) * QuantumRandomNumber());
    }

    operation MonteCarloIntegral(range : (Double, Double), f : (Double -> Double), samples : Int) : Double {
        mutable sum = 0.0;
        let (a, b) = range;
        for _ in 1..samples {
            let x = QuantumRandomNumberInRage(a, b);
            set sum += f(x);
        }
        sum += f(a);
        sum += f(b);
        return (b - a) * (sum / (IntAsDouble(samples) + 2.0));
    }

    function LessThanOrEqualI(number1 : Double, number2 : Double) : Bool {
        return number1 <= number2;
    }

    operation MonteCarloIntegral_SUM(range : (Double, Double), f : (Double -> Double), samples : Int) : Double {
        mutable sum = 0.0;
        let (a, b) = range;
        mutable points : Double[] = [];
        for _ in 1..samples {
            let x = QuantumRandomNumberInRage(a, b);
            set points += [x];
        }
        let sortedPoints = Sorted(LessThanOrEqualI, points);
        for point in sortedPoints {
            mutable startPoint : Double = a;
            mutable endPoint : Double = point;
            let startPointIndex = IndexOf(p -> p == point, sortedPoints);
            if (startPointIndex > 0) {
                startPoint = sortedPoints[startPointIndex - 1];
            }
            let startValue = f(startPoint);
            let midValue = f(endPoint);

            let avgValue = ((startValue + midValue) / 2.0);
            let fxDxValue = (endPoint - startPoint) * avgValue;
            // Message($"Points & Value: {startPoint} {point} {endPoint} {avgValue} {fxDxValue}");
            sum += fxDxValue;
        }
        let lastPoint = sortedPoints[Length(sortedPoints) - 1];
        let endPointValue = f(lastPoint);
        let endRangeValue = f(b);

        let avgValue = ((endPointValue + endRangeValue) / 2.0);
        let fxDxValue = (b - lastPoint) * avgValue;
        sum += fxDxValue;
        return sum;
    }

    function XSquare(x : Double) : Double {
        return x * x;
    }
    function Gaussian(x : Double) : Double {
        let mean = 0.0;
        let stddev = 1.0;
        let exponent = -((x - mean)^2.0) / (2.0 * stddev^2.0);
        let pow = PowC(Complex(E(), 0.0), Complex(exponent, 0.0));
        return pow.Real / (stddev * Sqrt(2.0 * PI()));
    }

    @EntryPoint()
    operation Main() : Double {
        let range = (-1.0, 1.5);
        let samples = 1000;
        let result = MonteCarloIntegral(range, Gaussian, samples);
        let resultSum = MonteCarloIntegral_SUM(range, Gaussian, samples);
        Message($"Estimated integral: {result}");
        Message($"Estimated integral (fx dx sum): {resultSum}");
        let estimationDifference = result - resultSum;
        Message($"Estimation difference: {estimationDifference}");
        return resultSum;
    }
}

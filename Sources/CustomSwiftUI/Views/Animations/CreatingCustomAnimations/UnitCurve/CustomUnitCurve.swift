import SwiftUI

/// A  function defined by a two-dimensional curve that maps an input
/// progress in the range [0,1] to an output progress that is also in the
/// range [0,1]. By changing the shape of the curve, the effective speed
/// of an animation or other interpolation can be changed.
///
/// The horizontal (x) axis defines the input progress: a single input
/// progress value in the range [0,1] must be provided when evaluating a
/// curve.
///
/// The vertical (y) axis maps to the output progress: when a curve is
/// evaluated, the y component of the point that intersects the input progress
/// is returned.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomUnitCurve {

    let function: Function

    enum Function: Hashable {
        case linear
        case bezier(startControlPoint: UnitPoint, endControlPoint: UnitPoint)
        case circularEaseIn
        case circularEaseOut
        case circularEaseInOut
    }

    /// Creates a new curve using bezier control points.
    ///
    /// The x components of the control points are clamped to the range [0,1] when
    /// the curve is evaluated.
    ///
    /// - Parameters:
    ///   - startControlPoint: The cubic Bézier control point associated with
    ///     the curve's start point at (0, 0). The tangent vector from the
    ///     start point to its control point defines the initial velocity of
    ///     the timing function.
    ///   - endControlPoint: The cubic Bézier control point associated with the
    ///     curve's end point at (1, 1). The tangent vector from the end point
    ///     to its control point defines the final velocity of the timing
    ///     function.
    static func bezier(startControlPoint: UnitPoint, endControlPoint: UnitPoint) -> CustomUnitCurve {
        CustomUnitCurve(function: .bezier(startControlPoint: startControlPoint, endControlPoint: endControlPoint))
    }

    /// Returns the output value (y component) of the curve at the given time.
    ///
    /// - Parameters:
    ///   - time: The input progress (x component). The provided value is
    ///     clamped to the range [0,1].
    ///
    /// - Returns: The output value (y component) of the curve at the given
    ///   progress.
    public func value(at progress: Double) -> Double {
        switch function {
        case .linear:
            return progress
        case .bezier(let startControlPoint, let endControlPoint):
            return UnitBezier(p1x: startControlPoint.x, p1y: startControlPoint.y, p2x: endControlPoint.x, p2y: endControlPoint.y)
                .solve(x: progress, epsilon: 1e-8)
        case .circularEaseIn:
            return 1 - sqrt(1 - pow(progress, 2))
        case .circularEaseOut:
            return sqrt(1 - pow((1 - progress), 2))
        case .circularEaseInOut:
            if progress < 0.5 {
                return 0.5 - sqrt(0.25 - pow(progress, 2))
            } else {
                return 0.5 + sqrt(0.25 - pow(progress - 1, 2))
            }
        }
    }

    /// Returns the rate of change (first derivative) of the output value of
    /// the curve at the given time.
    ///
    /// - Parameters:
    ///   - progress: The input progress (x component). The provided value is
    ///     clamped to the range [0,1].
    ///
    /// - Returns: The velocity of the output value (y component) of the curve
    ///   at the given time.
    public func velocity(at progress: Double) -> Double {
        switch function {
        case .linear:
            return 1
        case .bezier(let startControlPoint, let endControlPoint):
            return UnitBezier(p1x: startControlPoint.x, p1y: startControlPoint.y, p2x: endControlPoint.x, p2y: endControlPoint.y)
                .derivative(x: progress, epsilon: 1e-6)
        case .circularEaseIn:
            return progress / sqrt(1 - pow(progress, 2))
        case .circularEaseOut:
            return (1 - progress) / sqrt((2 * progress) - pow(progress, 2))
        case .circularEaseInOut:
            if progress < 0.5 {
                return progress / sqrt(0.25 - pow(progress, 2))
            } else {
                return (1 - progress) / sqrt(-0.75 + (2 * progress) - pow(progress, 2))
            }
        }
    }

    /// Returns a copy of the curve with its x and y components swapped.
    ///
    /// The inverse can be used to solve a curve in reverse: given a
    /// known output (y) value, the corresponding input (x) value can be found
    /// by using `inverse`:
    ///
    ///     let curve = UnitCurve.easeInOut
    ///
    ///     /// The input time for which an easeInOut curve returns 0.6.
    ///     let inputTime = curve.inverse.evaluate(at: 0.6)
    ///
    public var inverse: CustomUnitCurve {
        switch function {
        case .linear:
            return .linear
        case .bezier(var startControlPoint, var endControlPoint):
            swap(&startControlPoint.x, &startControlPoint.y)
            swap(&endControlPoint.x, &endControlPoint.y)
            return .bezier(startControlPoint: startControlPoint, endControlPoint: endControlPoint)
        case .circularEaseIn:
            return .circularEaseOut
        case .circularEaseOut:
            return .circularEaseIn
        case .circularEaseInOut:
            return .circularEaseInOut
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomUnitCurve: Sendable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomUnitCurve: Hashable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomUnitCurve {

    /// A bezier curve that starts out slowly, speeds up over the middle, then
    /// slows down again as it approaches the end.
    ///
    /// The start and end control points are located at (x: 0.42, y: 0) and
    /// (x: 0.58, y: 1).
    public static let easeInOut: CustomUnitCurve = .bezier(startControlPoint: UnitPoint(x: 0.42, y: 0), endControlPoint: UnitPoint(x: 0.58, y: 1))

    /// A bezier curve that starts out slowly, then speeds up as it finishes.
    ///
    /// The start and end control points are located at (x: 0.42, y: 0) and
    /// (x: 1, y: 1).
    public static let easeIn: CustomUnitCurve = .bezier(startControlPoint: UnitPoint(x: 0.42, y: 0), endControlPoint: UnitPoint(x: 1, y: 1))

    /// A bezier curve that starts out quickly, then slows down as it
    /// approaches the end.
    ///
    /// The start and end control points are located at (x: 0, y: 0) and
    /// (x: 0.58, y: 1).
    public static let easeOut: CustomUnitCurve = .bezier(startControlPoint: UnitPoint(x: 0, y: 0), endControlPoint: UnitPoint(x: 0.58, y: 1))

    /// A curve that starts out slowly, then speeds up as it finishes.
    ///
    /// The shape of the curve is equal to the fourth (bottom right) quadrant
    /// of a unit circle.
    public static let circularEaseInOut = CustomUnitCurve(function: .circularEaseInOut)

    /// A circular curve that starts out quickly, then slows down as it
    /// approaches the end.
    ///
    /// The shape of the curve is equal to the second (top left) quadrant of
    /// a unit circle.
    public static let circularEaseIn = CustomUnitCurve(function: .circularEaseIn)

    /// A circular curve that starts out slowly, speeds up over the middle,
    /// then slows down again as it approaches the end.
    ///
    /// The shape of the curve is defined by a piecewise combination of
    /// `circularEaseIn` and `circularEaseOut`.
    public static let circularEaseOut = CustomUnitCurve(function: .circularEaseOut)

    /// A linear curve.
    ///
    /// As the linear curve is a straight line from (0, 0) to (1, 1),
    /// the output progress is always equal to the input progress, and
    /// the velocity is always equal to 1.0.
    public static let linear = CustomUnitCurve(function: .linear)
}

private struct UnitBezier {

    let ax: Double
    let bx: Double
    let cx: Double
    let ay: Double
    let by: Double
    let cy: Double

    let p1x: Double
    let p1y: Double
    let p2x: Double
    let p2y: Double

    init(p1x: Double, p1y: Double, p2x: Double, p2y: Double) {
        self.p1x = p1x
        self.p1y = p1y
        self.p2x = p2x
        self.p2y = p2y
        // Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).
        cx = 3.0 * p1x
        bx = 3.0 * (p2x - p1x) - cx
        ax = 1.0 - cx - bx

        cy = 3.0 * p1y
        by = 3.0 * (p2y - p1y) - cy
        ay = 1.0 - cy - by
    }

    func sampleCurveX(t: Double) -> Double {
        // `ax t^3 + bx t^2 + cx t` expanded using Horner's rule.
        return ((ax * t + bx) * t + cx) * t
    }

    func sampleCurveY(t: Double) -> Double {
        return ((ay * t + by) * t + cy) * t
    }

    func sampleCurveDerivativeX(t: Double) -> Double {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }

    // Given an x value, find a parametric value it came from.
    func solveCurveX(x: Double, epsilon: Double) -> Double {
        var t0: Double
        var t1: Double
        var t2: Double
        var x2: Double
        var d2: Double

        t2 = x
        // First try a few iterations of Newton's method -- normally very fast.
        for _ in 0..<8 {
            x2 = sampleCurveX(t: t2) - x
            if fabs(x2) < epsilon {
                return t2
            }
            d2 = sampleCurveDerivativeX(t: t2)
            if fabs(d2) < 1e-6 {
                break
            }
            t2 = t2 - x2 / d2
        }

        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x

        if t2 < t0 {
            return t0
        }
        if t2 > t1 {
            return t1
        }

        while t0 < t1 {
            x2 = sampleCurveX(t: t2)
            if fabs(x2 - x) < epsilon {
                return t2
            }
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1 - t0) * 0.5 + t0
        }

        // Failure.
        return t2
    }

    func solve(x: Double, epsilon: Double) -> Double {
        if x > 10 * epsilon, x < 1 - 10 * epsilon {
            return sampleCurveY(t: solveCurveX(x: x, epsilon: epsilon))
        } else {
            let h1: (x: Double, y: Double)
            let h2: (x: Double, y: Double)
            if x < 0.5 {
                h1 = (0, 0)
                h2 = (p1x, p1y)
            } else {
                h1 = (p2x, p2y)
                h2 = (1, 1)
            }
            guard h1.x != h2.x else {
                return x
            }
            let m = (h2.y - h1.y) / (h2.x - h1.x)
            let q = ((h2.x * h1.y) - (h1.x * h2.y)) / (h2.x - h1.x)
            return (m * x) + q
        }
    }

    func derivative(x: CGFloat, epsilon: CGFloat) -> CGFloat {
        let h: CGFloat = 10 * epsilon // piccola variazione di x per calcolare l'incremento

        let x1 = solve(x: x - h, epsilon: epsilon)
        let x2 = solve(x: x + h, epsilon: epsilon)

        // Calcola la derivata prima (velocità) utilizzando la formula (f(x + h) - f(x - h)) / (2 * h)
        return (x2 - x1) / (2 * h)
    }
}

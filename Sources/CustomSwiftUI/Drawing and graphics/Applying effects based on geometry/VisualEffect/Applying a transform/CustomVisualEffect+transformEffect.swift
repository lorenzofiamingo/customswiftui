import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    /// Applies a projection transformation to the view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// <doc://com.apple.documentation/documentation/SwiftUI/ProjectionTransform>.
    ///
    /// - Parameter transform: A
    /// <doc://com.apple.documentation/documentation/SwiftUI/ProjectionTransform> to
    /// apply to the view.
    ///
    /// - Returns: An effect that applies a projection transformation to the
    ///   view's rendered output.
    public func transformEffect(_ transform: ProjectionTransform) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomGeometryVisualEffect(base: CustomTransformEffect(transform: transform)))
    }

    /// Applies an affine transformation to the view's rendered output.
    ///
    /// Use `transformEffect(_:)` to rotate, scale, translate, or skew the
    /// output of the view according to the provided
    /// <doc://com.apple.documentation/documentation/CoreFoundation/CGAffineTransform>.
    ///
    /// - Parameter transform: A
    /// <doc://com.apple.documentation/documentation/CoreFoundation/CGAffineTransform> to
    /// apply to the view.
    ///
    /// - Returns: An effect that applies an affine transformation to the
    ///   view's rendered output.
    public func transformEffect(_ transform: CGAffineTransform) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomGeometryVisualEffect(base: CustomTransformEffect(transform: ProjectionTransform(transform))))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomTransformEffect: CustomVisualEffect {

    private var transformM11: CGFloat
    private var transformM12: CGFloat
    private var transformM13: CGFloat
    private var transformM21: CGFloat
    private var transformM22: CGFloat
    private var transformM23: CGFloat
    private var transformM31: CGFloat
    private var transformM32: CGFloat
    private var transformM33: CGFloat

    var transform: ProjectionTransform {
        var transform = ProjectionTransform()
        transform.m11 = transformM11
        transform.m12 = transformM12
        transform.m13 = transformM13
        transform.m21 = transformM21
        transform.m22 = transformM22
        transform.m23 = transformM23
        transform.m31 = transformM31
        transform.m32 = transformM32
        transform.m33 = transformM33
        return transform
    }

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>>>>>> {
        get {
            AnimatablePair(
                transformM11,
                AnimatablePair(
                    transformM12,
                    AnimatablePair(
                        transformM13,
                        AnimatablePair(
                            transformM21,
                            AnimatablePair(
                                transformM22,
                                AnimatablePair(
                                    transformM23,
                                    AnimatablePair(
                                        transformM31,
                                        AnimatablePair(
                                            transformM32,
                                            transformM33
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        } set {
            transformM11 = newValue.first
            transformM12 = newValue.second.first
            transformM13 = newValue.second.second.first
            transformM21 = newValue.second.second.second.first
            transformM22 = newValue.second.second.second.second.first
            transformM23 = newValue.second.second.second.second.second.first
            transformM31 = newValue.second.second.second.second.second.second.first
            transformM32 = newValue.second.second.second.second.second.second.second.first
            transformM33 = newValue.second.second.second.second.second.second.second.second
        }
    }

    init(transform: ProjectionTransform) {
        self.transformM11 = transform.m11
        self.transformM12 = transform.m12
        self.transformM13 = transform.m13
        self.transformM21 = transform.m21
        self.transformM22 = transform.m22
        self.transformM23 = transform.m23
        self.transformM31 = transform.m31
        self.transformM32 = transform.m32
        self.transformM33 = transform.m33
    }

    static func _makeModifier(effect: CustomTransformEffect?) -> some ViewModifier {
        Modifier(transform: effect?.transform ?? ProjectionTransform(.identity))
    }

    private struct Modifier: ViewModifier {

        var transform: ProjectionTransform

        func body(content: Content) -> some View {
            content.projectionEffect(transform)
        }
    }
}

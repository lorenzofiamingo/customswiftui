import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {

    /// Renders content as if it's rotated in three dimensions around
    /// the specified axis.
    ///
    /// Use this method to create the effect of rotating a two dimensional view
    /// in three dimensions around a specified axis of rotation. The effect
    /// projects the rotated content onto the original content's plane. Use the
    /// `perspective` input to control the renderer's vanishing point.
    /// The following example creates the appearance of rotating
    /// text 45˚ about the y-axis:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .customVisualEffect { content, geometryProxy in
    ///             content
    ///                 .rotation3DEffect(
    ///                     .degrees(45),
    ///                     axis: (x: 0.0, y: 1.0, z: 0.0),
    ///                     anchor: .center,
    ///                     anchorZ: 0,
    ///                     perspective: 1)
    ///             }
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text in a grey box. The text says Rotation by passing an angle in degrees. The text is rendered in a way that makes it appear farther from the viewer on the right side and closer on the left, as if the text is angled to face someone sitting on the viewer's right.](SwiftUI-View-rotation3DEffect)
    ///
    /// > Important: In visionOS, create this effect with
    ///   ``perspectiveRotationEffect(_:axis:anchor:perspective:)``
    ///   instead. To truly rotate a view in three dimensions,
    ///   use a 3D rotation effect without a perspective input like
    ///   ``rotation3DEffect(_:axis:anchor:)-6lbql``.
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the content.
    ///   - axis: The axis of rotation, specified as a tuple with named
    ///     elements for each of the three spatial dimensions.
    ///   - anchor: A two dimensional unit point within the content about which
    ///     to perform the rotation. The default value is ``UnitPoint/center``.
    ///   - anchorZ: The location on the z-axis around which to rotate the
    ///     content. The default is `0`.
    ///   - perspective: The relative vanishing point for the rotation. The
    ///     default is `1`.
    /// - Returns: A rotation effect.
    public func rotation3DEffect(
        _ angle: Angle,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat),
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(
            first: self,
            second: CustomGeometryVisualEffect(
                base: CustomRotation3DEffect(
                    angle: angle,
                    axisX: axis.x,
                    axisY: axis.y,
                    axisZ: axis.z,
                    anchor: anchor,
                    anchorZ: anchorZ,
                    perspective: perspective
                )
            )
        )
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomRotation3DEffect: CustomVisualEffect {

    private var angle: Angle

    private var axisX: CGFloat

    private var axisY: CGFloat

    private var axisZ: CGFloat

    private var anchor: UnitPoint

    private var anchorZ: CGFloat

    private var perspective: CGFloat

    init(angle: Angle, axisX: CGFloat, axisY: CGFloat, axisZ: CGFloat, anchor: UnitPoint, anchorZ: CGFloat, perspective: CGFloat) {
        self.angle = angle
        self.axisX = axisX
        self.axisY = axisY
        self.axisZ = axisZ
        self.anchor = anchor
        self.anchorZ = anchorZ
        self.perspective = perspective
    }

    var animatableData: AnimatablePair<Angle.AnimatableData, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<UnitPoint.AnimatableData, AnimatablePair<CGFloat, CGFloat>>>>>> {
        get {
            AnimatablePair(
                angle.animatableData,
                AnimatablePair(
                    axisX,
                    AnimatablePair(
                        axisY,
                        AnimatablePair(
                            axisZ,
                            AnimatablePair(
                                anchor.animatableData,
                                AnimatablePair(
                                    anchorZ,
                                    perspective
                                )
                            )
                        )
                    )
                )
            )
        } set {
            angle.animatableData = newValue.first
            axisX = newValue.second.first
            axisY = newValue.second.second.first
            axisZ = newValue.second.second.second.first
            anchor.animatableData = newValue.second.second.second.second.first
            anchorZ = newValue.second.second.second.second.second.first
            perspective = newValue.second.second.second.second.second.second
        }
    }

    static func _makeModifier(effect: CustomRotation3DEffect?) -> some ViewModifier {
        Modifier(
            angle: effect?.angle ?? .zero,
            axisX: effect?.axisX ?? 0,
            axisY: effect?.axisY ?? 0,
            axisZ: effect?.axisZ ?? 0,
            anchor: effect?.anchor ?? .center,
            anchorZ: effect?.anchorZ ?? 0,
            perspective: effect?.perspective ?? 1
        )
    }

    private struct Modifier: ViewModifier {

        var angle: Angle

        var axisX: CGFloat

        var axisY: CGFloat

        var axisZ: CGFloat

        var anchor: UnitPoint

        var anchorZ: CGFloat

        var perspective: CGFloat

        func body(content: Content) -> some View {
            content
                .rotation3DEffect(angle, axis: (x: axisX, y: axisY, z: axisZ), anchor: anchor, anchorZ: anchorZ, perspective: perspective)
        }
    }
}

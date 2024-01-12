import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Rotates content in two dimensions around the specified point.
    ///
    /// This effect rotates the content around the axis that points
    /// out of the xy-plane. It has no effect on the content's frame.
    /// The following code rotates text by 22˚ and then draws a border around
    /// the modified view to show that the frame remains unchanged by the
    /// rotation:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .visualEffect { content, geometryProxy in
    ///             content
    ///                 .rotationEffect(.degrees(22))
    ///         }
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text and a wide grey box. The text says Rotation by passing an angle in degrees. The baseline of the text is rotated clockwise by 22 degrees relative to the box. The center of the box and the center of the text are aligned.](SwiftUI-View-rotationEffect)
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the content.
    ///   - anchor: A unit point within the content about which to
    ///     perform the rotation. The default value is ``UnitPoint/center``.
    /// - Returns: A rotation effect.
    public func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomGeometryVisualEffect(base: CustomRotationEffect(angle: angle, anchor: anchor)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomRotationEffect: CustomVisualEffect {

    private var angle: Angle

    private var anchor: UnitPoint

    var animatableData: AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData> {
        get {
            AnimatablePair(angle.animatableData, anchor.animatableData)
        } set {
            angle.animatableData = newValue.first
            anchor.animatableData = newValue.second
        }
    }

    init(angle: Angle, anchor: UnitPoint) {
        self.angle = angle
        self.anchor = anchor
    }

    static func _makeModifier(effect: CustomRotationEffect?) -> some ViewModifier {
        Modifier(angle: effect?.angle ?? .zero, anchor: effect?.anchor ?? .center)
    }

    private struct Modifier: ViewModifier {

        var angle: Angle

        var anchor: UnitPoint

        func body(content: Content) -> some View {
            content
                .rotationEffect(angle, anchor: anchor)
        }
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Applies a hue rotation effect to the view.
    ///
    /// Use hue rotation effect to shift all of the colors in a view according
    /// to the angle you specify.
    ///
    /// - Parameter angle: The hue rotation angle to apply to the colors in the
    ///   view.
    ///
    /// - Returns: An effect that shifts all of the colors in the view.
    public func hueRotation(_ angle: Angle) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomHueRotationEffect(angle: angle)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomHueRotationEffect: CustomVisualEffect {
    
    var angle: Angle

    var animatableData: Angle {
        get {
            angle
        } set {
            angle = newValue
        }
    }

    static func _makeModifier(effect: CustomHueRotationEffect?) -> some ViewModifier {
        Modifier(angle: effect?.angle ?? .zero)
    }

    private struct Modifier: ViewModifier {

        let angle: Angle

        func body(content: Content) -> some View {
            content.hueRotation(angle)
        }
    }
}

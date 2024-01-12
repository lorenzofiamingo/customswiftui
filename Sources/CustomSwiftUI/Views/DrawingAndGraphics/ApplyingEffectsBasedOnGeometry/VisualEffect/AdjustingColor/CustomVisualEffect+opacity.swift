import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Sets the transparency of the view.
    ///
    /// When applying the `opacity(_:)` effect to a view that has already had
    /// its opacity transformed, the effect of the underlying opacity
    /// transformation is multiplied.
    ///
    /// - Parameter opacity: A value between 0 (fully transparent) and 1 (fully
    ///   opaque).
    ///
    /// - Returns: An effect that sets the transparency of the view.
    public func opacity(_ opacity: Double) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomOpacityEffect(opacity: opacity)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomOpacityEffect: CustomVisualEffect {

    var opacity: Double

    var animatableData: CGFloat {
        get {
            opacity
        } set {
            opacity = newValue
        }
    }

    var modifier: some ViewModifier {
        Modifier(opacity: opacity)
    }

    static func _makeModifier(effect: CustomOpacityEffect?) -> some ViewModifier {
        Modifier(opacity: effect?.opacity ?? 0)
    }


    private struct Modifier: ViewModifier {

        var opacity: Double

        func body(content: Content) -> some View {
            content.opacity(opacity)
        }
    }
}

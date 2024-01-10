import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {

    /// Sets the contrast and separation between similar colors in the view.
    ///
    /// Apply contrast to a view to increase or decrease the separation between
    /// similar colors in the view.
    ///
    /// - Parameter amount: The intensity of color contrast to apply. negative
    ///   values invert colors in addition to applying contrast.
    ///
    /// - Returns: An effect that applies color contrast to the view.
    public func contrast(_ amount: Double) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomContrastEffect(amount: amount)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomContrastEffect: CustomVisualEffect {
    var amount: Double

    var animatableData: CGFloat {
        get {
            amount
        } set {
            amount = newValue
        }
    }

    static func _makeModifier(effect: CustomContrastEffect?) -> some ViewModifier {
        Modifier(amount: effect?.amount ?? 1)
    }

    private struct Modifier: ViewModifier {

        let amount: Double

        func body(content: Content) -> some View {
            content.contrast(amount)
        }
    }
}

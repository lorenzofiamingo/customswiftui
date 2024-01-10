import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {

    
    /// Brightens the view by the specified amount.
    ///
    /// - Parameter amount: A value between 0 (no effect) and 1 (full white
    ///   brightening) that represents the intensity of the brightness effect.
    ///
    /// - Returns: An effect that brightens the view by the specified amount.
    public func brightness(_ amount: Double) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomBrightnessEffect(amount: amount)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomBrightnessEffect: CustomVisualEffect {
    
    var amount: Double

    var animatableData: CGFloat {
        get {
            amount
        } set {
            amount = newValue
        }
    }

    static func _makeModifier(effect: CustomBrightnessEffect?) -> some ViewModifier {
        Modifier(amount: effect?.amount ?? 1)
    }

    private struct Modifier: ViewModifier {

        let amount: Double

        func body(content: Content) -> some View {
            content.brightness(amount)
        }
    }
}

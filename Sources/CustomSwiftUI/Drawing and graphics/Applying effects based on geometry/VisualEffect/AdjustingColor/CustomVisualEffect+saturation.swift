import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Adjusts the color saturation of the view.
    ///
    /// Use color saturation to increase or decrease the intensity of colors in
    /// a view.
    ///
    /// - SeeAlso: `contrast(_:)`
    /// - Parameter amount: The amount of saturation to apply to the view.
    ///
    /// - Returns: An effect that adjusts the saturation of the view.
    public func saturation(_ amount: Double) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomSaturationEffect(amount: amount)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomSaturationEffect: CustomVisualEffect {
    
    var amount: Double

    var animatableData: CGFloat {
        get {
            amount
        } set {
            amount = newValue
        }
    }

    static func _makeModifier(effect: CustomSaturationEffect?) -> some ViewModifier {
        Modifier(amount: effect?.amount ?? 1)
    }

    private struct Modifier: ViewModifier {

        let amount: Double

        func body(content: Content) -> some View {
            content.saturation(amount)
        }
    }
}

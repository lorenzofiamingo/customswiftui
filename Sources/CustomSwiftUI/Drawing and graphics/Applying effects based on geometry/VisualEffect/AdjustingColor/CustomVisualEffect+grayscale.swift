import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Adds a grayscale effect to the view.
    ///
    /// A grayscale effect reduces the intensity of colors in the view.
    ///
    /// - Parameter amount: The intensity of grayscale to apply from 0.0 to less
    ///   than 1.0. Values closer to 0.0 are more colorful, and values closer to
    ///   1.0 are less colorful.
    ///
    /// - Returns: An effect that reduces the intensity of colors in the view.
    public func grayscale(_ amount: Double) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomGrayscaleEffect(amount: amount)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomGrayscaleEffect: CustomVisualEffect {
    
    var amount: Double

    var animatableData: CGFloat {
        get {
            amount
        } set {
            amount = newValue
        }
    }

    static func _makeModifier(effect: CustomGrayscaleEffect?) -> some ViewModifier {
        Modifier(amount: effect?.amount ?? 1)
    }

    private struct Modifier: ViewModifier {

        let amount: Double

        func body(content: Content) -> some View {
            content.grayscale(amount)
        }
    }
}

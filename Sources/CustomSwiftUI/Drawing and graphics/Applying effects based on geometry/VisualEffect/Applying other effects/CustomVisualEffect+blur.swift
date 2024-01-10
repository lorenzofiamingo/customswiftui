import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {

    /// Applies a Gaussian blur to the view.
    ///
    /// Use `blur(radius:opaque:)` to apply a gaussian blur effect to the
    /// rendering of the view.
    ///
    /// - Parameters:
    ///   - radius: The radial size of the blur. A blur is more diffuse when its
    ///     radius is large.
    ///   - opaque: A Boolean value that indicates whether the blur renderer
    ///     permits transparency in the blur output. Set to `true` to create an
    ///     opaque blur, or set to `false` to permit transparency.
    ///
    /// - Returns: An effect that blurs the view.
    public func blur(radius: CGFloat, opaque: Bool = false) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomBlurEffect(radius: radius, isOpaque: opaque)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomBlurEffect: CustomVisualEffect {

    var radius: CGFloat

    var isOpaque: Bool

    var animatableData: CGFloat {
        get {
            radius
        } set {
            radius = newValue
        }
    }

    static func _makeModifier(effect: CustomBlurEffect?) -> some ViewModifier {
        Modifier(radius: effect?.radius ?? 0, isOpaque: effect?.isOpaque ?? false)
    }

    private struct Modifier: ViewModifier {

        var radius: CGFloat

        var isOpaque: Bool

        func body(content: Content) -> some View {
            content.blur(radius: radius, opaque: isOpaque)
        }
    }
}

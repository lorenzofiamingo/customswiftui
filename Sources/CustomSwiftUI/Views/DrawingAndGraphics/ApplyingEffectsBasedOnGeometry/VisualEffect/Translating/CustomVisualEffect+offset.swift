import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {
    
    /// Offsets the view by the horizontal and vertical amount specified in the
    /// offset parameter.
    ///
    /// - Parameter offset: The distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `offset`.
    public func offset(_ offset: CGSize) -> some CustomVisualEffect {
        self.offset(x: offset.width, y: offset.height)
    }

    /// Offsets the view by the specified horizontal and vertical distances.
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset the view.
    ///   - y: The vertical distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `x` and `y`.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomGeometryVisualEffect(base: CustomOffsetEffect(offsetWidth: x, offsetHeigth: y)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomOffsetEffect: CustomVisualEffect {

    var offsetWidth: CGFloat

    var offsetHeigth: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatableData(offsetWidth, offsetHeigth)
        } set {
            offsetWidth = newValue.first
            offsetHeigth = newValue.second
        }
    }

    static func _makeModifier(effect: CustomOffsetEffect?) -> some ViewModifier {
        Modifier(offsetWidth: effect?.offsetWidth ?? 0, offsetHeigth: effect?.offsetHeigth ?? 0)
    }

    private struct Modifier: ViewModifier {

        var offsetWidth: CGFloat

        var offsetHeigth: CGFloat

        func body(content: Content) -> some View {
            content.offset(x: offsetWidth, y: offsetHeigth)
        }
    }
}

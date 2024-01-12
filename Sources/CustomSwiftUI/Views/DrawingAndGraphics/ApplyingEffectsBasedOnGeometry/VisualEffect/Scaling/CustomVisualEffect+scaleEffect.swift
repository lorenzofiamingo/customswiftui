import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomVisualEffect {

    /// Scales the view's rendered output by the given vertical and horizontal
    /// size amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - scale: A <doc://com.apple.documentation/documentation/CoreFoundation/CGSize> that
    ///     represents the horizontal and vertical amount to scale the view.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGSize, anchor: UnitPoint = .center) -> some CustomVisualEffect {
        scaleEffect(x: scale.width, y: scale.height, anchor: anchor)
    }

    /// Scales the view's rendered output by the given amount in both the
    /// horizontal and vertical directions, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - s: The amount to scale the view in the view in both the horizontal
    ///     and vertical directions.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(_ scale: CGFloat, anchor: UnitPoint = .center) -> some CustomVisualEffect {
        scaleEffect(x: scale, y: scale, anchor: anchor)
    }

    /// Scales the view's rendered output by the given horizontal and vertical
    /// amounts, relative to an anchor point.
    ///
    /// - Parameters:
    ///   - x: An amount that represents the horizontal amount to scale the
    ///     view. The default value is `1.0`.
    ///   - y: An amount that represents the vertical amount to scale the view.
    ///     The default value is `1.0`.
    ///   - anchor: The point with a default of ``UnitPoint/center`` that
    ///     defines the location within the view from which to apply the
    ///     transformation.
    ///
    /// - Returns: An effect that scales the view's rendered output.
    public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint = .center) -> some CustomVisualEffect {
        CustomCombinedVisualEffect(first: self, second: CustomRendererVisualEffect(base: CustomScaleEffect(scaleWidth: x, scaleHeight: y, anchor: anchor)))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomScaleEffect: CustomVisualEffect {

    var scaleWidth: CGFloat

    var scaleHeight: CGFloat

    var anchor: UnitPoint

    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, UnitPoint.AnimatableData> {
        get {
            AnimatablePair(AnimatablePair(scaleWidth, scaleHeight), anchor.animatableData)
        } set {
            scaleWidth = newValue.first.first
            scaleHeight = newValue.first.second
            anchor.animatableData = newValue.second
        }
    }

    static func _makeModifier(effect: CustomScaleEffect?) -> some ViewModifier {
        Modifier(scaleWidth: effect?.scaleWidth ?? 0, scaleHeight: effect?.scaleHeight ?? 0, anchor: effect?.anchor ?? .center)
    }

    private struct Modifier: ViewModifier {

        var scaleWidth: CGFloat

        var scaleHeight: CGFloat

        var anchor: UnitPoint

        func body(content: Content) -> some View {
            content
                .scaleEffect(x: scaleWidth, y: scaleHeight, anchor: anchor)
        }
    }
}

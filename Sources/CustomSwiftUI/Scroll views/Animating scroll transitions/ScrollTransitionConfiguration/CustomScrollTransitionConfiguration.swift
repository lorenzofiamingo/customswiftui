import SwiftUI

/// The configuration of a scroll transition that controls how a transition
/// is applied as a view is scrolled through the visible region of a containing
/// scroll view or other container.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomScrollTransitionConfiguration {

    let threshold: Threshold

    let mode: Mode
    
    var axis: Axis?

    var animation: Animation? {
        switch mode {
        case .identity:
            return nil
        case .interactive(timingCurve: _, animation: let animation):
            return animation
        case .animated(let animation):
            return animation
        }
    }

    /// Creates a new configuration that discretely animates the transition
    /// when the view becomes visible.
    ///
    /// Unlike the interactive configuration, the transition isn't
    /// interpolated as the scroll view is scrolled. Instead, the transition
    /// phase only changes once the threshold has been reached, at which
    /// time the given animation is used to animate to the new phase.
    ///
    /// - Parameters:
    ///   - animation: The animation to use when transitioning between states.
    ///
    /// - Returns: A configuration that discretely animates between
    ///   transition phases.
    public static func animated(_ animation: Animation = .default) -> CustomScrollTransitionConfiguration {
        CustomScrollTransitionConfiguration(threshold: .visible(0.5), mode: .animated(animation: animation))
    }

    /// Creates a new configuration that discretely animates the transition
    /// when the view becomes visible.
    public static let animated = CustomScrollTransitionConfiguration.animated()

    /// Creates a new configuration that interactively interpolates the
    /// transition's effect as the view is scrolled into the visible region
    /// of the container.
    ///
    /// - Parameters:
    ///   - timingCurve: The curve that adjusts the pace at which the effect
    ///     is interpolated between phases of the transition. For example, an
    ///     `.easeIn` curve causes interpolation to begin slowly as the view
    ///     reaches the edge of the scroll view, then speed up as it reaches
    ///     the visible threshold. The curve is applied 'forward' while the
    ///     view is appearing, meaning that time zero corresponds to the
    ///     view being just hidden, and time 1.0 corresponds to the pont at
    ///     which the view reaches the configuration threshold. This also means
    ///     that the timing curve is applied in reversed while the view
    ///     is moving away from the center of the scroll view.
    ///
    /// - Returns: A configuration that interactively interpolates between
    ///   transition phases based on the current scroll position.
    public static func interactive(timingCurve: CustomUnitCurve = .easeInOut) -> CustomScrollTransitionConfiguration {
        CustomScrollTransitionConfiguration(threshold: .visible, mode: .interactive(timingCurve: timingCurve, animation: nil))
    }

    /// Creates a new configuration that interactively interpolates the
    /// transition's effect as the view is scrolled into the visible region
    /// of the container.
    public static let interactive = CustomScrollTransitionConfiguration.interactive()

    /// Creates a new configuration that does not change the appearance of the view.
    public static let identity = CustomScrollTransitionConfiguration(threshold: .visible, mode: .identity)

    /// Sets the animation with which the transition will be applied.
    ///
    /// If the transition is interactive, the given animation will be used
    /// to animate the effect toward the current interpolated value, causing
    /// the effect to lag behind the current scroll position.
    ///
    /// - Parameter animation: An animation that will be used to apply the
    ///   transition to the view.
    ///
    /// - Returns: A copy of this configuration with the animation set to the
    ///   given value.
    public func animation(_ animation: Animation) -> CustomScrollTransitionConfiguration {
        switch mode {
        case .identity:
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .identity)
        case .interactive(timingCurve: let timingCurve, animation: _):
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .interactive(timingCurve: timingCurve, animation: animation))
        case .animated:
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .animated(animation: animation))
        }
    }

    /// Sets the threshold at which the view will be considered fully visible.
    ///
    /// - Parameters:
    ///   - threshold: The threshold specifying how much of the view must
    ///     intersect with the container before it is treated as visible.
    ///
    /// - Returns: A copy of this configuration with the threshold set to the
    ///   given value.
    public func threshold(_ threshold: Threshold) -> CustomScrollTransitionConfiguration {
        switch mode {
        case .identity:
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .identity)
        case .interactive(timingCurve: let timingCurve, animation: let animation):
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .interactive(timingCurve: timingCurve, animation: animation))
        case .animated(let animation):
            return CustomScrollTransitionConfiguration(threshold: threshold, mode: .animated(animation: animation))
        }
    }

    enum Mode {
        case identity
        case interactive(timingCurve: CustomUnitCurve, animation: Animation?)
        case animated(animation: Animation)
    }

}

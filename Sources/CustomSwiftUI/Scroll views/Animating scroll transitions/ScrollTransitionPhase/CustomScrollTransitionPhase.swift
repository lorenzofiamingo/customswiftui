import SwiftUI

/// The phases that a view transitions between when it scrolls among other views.
///
/// When a view with a scroll transition modifier applied is approaching
/// the visible region of the containing scroll view or other container,
/// the effect  will first be applied with the `topLeading` or `bottomTrailing`
/// phase (depending on which edge the view is approaching), then will be
/// moved to the `identity` phase as the view moves into the visible area. The
/// timing and behavior that determines when a view is visible within the
/// container is controlled by the configuration that is provided to the
/// `scrollTransition` modifier.
///
/// In the `identity` phase, scroll transitions should generally not make any
/// visual change to the view they are applied to, since the transition's view
/// modifications in the `identity` phase will be applied to the view as long
/// as it is visible. In the `topLeading` and `bottomTrailing` phases,
/// transitions should apply a change that will be animated to create the
/// transition.
public enum CustomScrollTransitionPhase: Hashable {

    /// The scroll transition is being applied to a view that is about to
    /// move into the visible area at the top edge of a vertical scroll view,
    /// or the leading edge of a horizont scroll view.
    case topLeading

    /// The scroll transition is being applied to a view that is in the
    /// visible area.
    ///
    /// In this phase, a transition should show its steady state appearance,
    /// which will generally not make any visual change to the view.
    case identity
    
    /// The scroll transition is being applied to a view that is about to
    /// move into the visible area at the bottom edge of a vertical scroll
    /// view, or the trailing edge of a horizontal scroll view.
    case bottomTrailing

    public var isIdentity: Bool {
        self == .identity
    }

    /// A phase-derived value that can be used to scale or otherwise modify
    /// effects.
    ///
    /// Returns -1.0 when in the topLeading phase, zero when in the identity
    /// phase, and 1.0 when in the bottomTrailing phase.
    public var value: Double {
        switch self {
        case .topLeading:
            return -1
        case .identity:
            return 0
        case .bottomTrailing:
            return 1
        }
    }
}

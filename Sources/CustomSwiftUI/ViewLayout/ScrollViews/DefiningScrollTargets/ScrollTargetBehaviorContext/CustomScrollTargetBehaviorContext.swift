import SwiftUI

/// The context in which a scroll target behavior updates its scroll target.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@dynamicMemberLookup public struct CustomScrollTargetBehaviorContext {

    /// The original target when the scroll gesture began.
    public var originalTarget: CustomScrollTarget

    /// The original target when the dragging gesture ended.
    var draggingEndTarget: CustomScrollTarget?

    /// The current velocity of the scrollable view's scroll gesture.
    public var velocity: CGVector

    /// The size of the content of the scrollable view.
    public var contentSize: CGSize

    /// The size of the container of the scrollable view.
    ///
    /// This is the size of the bounds of the scroll view subtracting any
    /// insets applied to the scroll view (like the safe area).
    public var containerSize: CGSize

    /// The axes in which the scrollable view is scrollable.
    public var axes: Axis.Set

    var environment: EnvironmentValues

    public subscript<T>(dynamicMember keyPath: KeyPath<EnvironmentValues, T>) -> T  {
        environment[keyPath: keyPath]
    }

    init(originalTarget: CustomScrollTarget, draggingEndTarget: CustomScrollTarget?, velocity: CGVector, contentSize: CGSize, containerSize: CGSize, axes: Axis.Set, environment: EnvironmentValues) {
        self.originalTarget = originalTarget
        self.draggingEndTarget = draggingEndTarget
        self.velocity = velocity
        self.contentSize = contentSize
        self.containerSize = containerSize
        self.axes = axes
        self.environment = environment
    }
}

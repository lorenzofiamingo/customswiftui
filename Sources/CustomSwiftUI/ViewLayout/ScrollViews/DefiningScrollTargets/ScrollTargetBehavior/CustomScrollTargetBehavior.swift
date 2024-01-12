/// A type that defines the scroll behavior of a scrollable view.
///
/// A scrollable view calculates where scroll gestures should end using its
/// deceleration rate and the state of its scroll gesture by default. A scroll
/// behavior allows for customizing this logic.
///
/// You define a scroll behavior using the
/// ``ScrollTargetBehavior/updateTarget(_:context:)`` method.
///
/// Using this method, you can control where someone can scroll in a scrollable
/// view. For example, you can create a custom scroll behavior
/// that aligns to every 10 points by doing the following:
///
///     struct BasicScrollTargetBehavior: ScrollTargetBehavior {
///         func updateTarget(_ target: inout Target, context: TargetContext) {
///             // Align to every 1/10 the size of the scroll view.
///             target.rect.x.round(
///                 toMultipleOf: round(context.containerSize.width / 10.0))
///         }
///     }
///
/// ### Paging Behavior
///
/// SwiftUI offers built in scroll behaviors. One such behavior
/// is the ``PagingScrollTargetBehavior`` which uses the geometry of the scroll
/// view to decide where to allow scrolls to end.
///
/// In the following example, every view in the lazy stack is flexible
/// in both directions and the scroll view will settle to container aligned
/// boundaries.
///
///     ScrollView {
///         LazyVStack(spacing: 0.0) {
///             ForEach(items) { item in
///                 FullScreenItem(item)
///             }
///         }
///     }
///     .scrollTargetBehavior(.paging)
///
/// ### View Aligned Behavior
///
/// SwiftUI also offers a ``ViewAlignedScrollTargetBehavior`` scroll behavior
/// that will always settle on the geometry of individual views.
///
///     ScrollView(.horizontal) {
///         LazyHStack(spacing: 10.0) {
///             ForEach(items) { item in
///                 ItemView(item)
///             }
///         }
///         .scrollTargetLayout()
///     }
///     .scrollTargetBehavior(.viewAligned)
///     .safeAreaPadding(.horizontal, 20.0)
///
/// You configure which views should be used for settling using the
/// ``View/scrollTargetLayout(isEnabled:)`` modifier. Apply this modifier to a
/// layout container like ``LazyVStack`` or ``HStack`` and each individual
/// view in that layout will be considered for alignment.
///
/// Use types conforming to this protocol with the
/// ``View/scrollTargetBehavior(_:)`` modifier.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol CustomScrollTargetBehavior {

    /// Updates the proposed target that a scrollable view should scroll to.
    ///
    /// The system calls this method in two main cases:
    /// - When a scroll gesture ends, it calculates where it would naturally
    ///   scroll to using its deceleration rate. The system
    ///   provides this calculated value as the target of this method.
    /// - When a scrollable view's size changes, it calculates where it should
    ///   be scrolled given the new size and provides this calculates value
    ///   as the target of this method.
    ///
    /// You can implement this method to override the calculated target
    /// which will have the scrollable view scroll to a different position
    /// than it would otherwise.
    func updateTarget(_ target: inout CustomScrollTarget, context: TargetContext)

    /// The context in which a scroll behavior updates the scroll target.
    typealias TargetContext = CustomScrollTargetBehaviorContext
}

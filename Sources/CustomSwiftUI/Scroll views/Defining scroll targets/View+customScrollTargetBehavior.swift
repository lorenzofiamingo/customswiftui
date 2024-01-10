import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets the scroll behavior of views scrollable in the provided axes.
    ///
    /// A scrollable view calculates where scroll gestures should end using its
    /// deceleration rate and the state of its scroll gesture by default. A
    /// scroll behavior allows for customizing this logic. You can provide
    /// your own ``ScrollTargetBehavior`` or use one of the built in behaviors
    /// provided by SwiftUI.
    ///
    /// ### Paging Behavior
    ///
    /// SwiftUI offers a ``PagingScrollTargetBehavior`` behavior which uses the
    /// geometry of the scroll view to decide where to allow scrolls to end.
    ///
    /// In the following example, every view in the lazy stack is flexible
    /// in both directions and the scroll view will settle to container aligned
    /// boundaries.
    ///
    ///     CustomScrollView {
    ///         LazyVStack(spacing: 0.0) {
    ///             ForEach(items) { item in
    ///                 FullScreenItem(item)
    ///             }
    ///         }
    ///     }
    ///     .customScrollTargetBehavior(.paging)
    ///
    /// ### View Aligned Behavior
    ///
    /// SwiftUI offers a ``ViewAlignedScrollTargetBehavior`` scroll behavior
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
    /// ``View/scrollTargetLayout(isEnabled:)`` modifier. Apply this modifier to
    /// a layout container like ``LazyVStack`` or ``HStack`` and each individual
    /// view in that layout will be considered for alignment.
    public func customScrollTargetBehavior(_ behavior: some CustomScrollTargetBehavior) -> some View {
        environment(\.customScrollTargetBehavior, behavior)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollTargetBehaviourKey: EnvironmentKey {

    static var defaultValue: any CustomScrollTargetBehavior = CustomDefaultScrollTargetBehavior()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    var customScrollTargetBehavior: any CustomScrollTargetBehavior {
        get { self[ScrollTargetBehaviourKey.self] }
        set { self[ScrollTargetBehaviourKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomDefaultScrollTargetBehavior: CustomScrollTargetBehavior {

    func updateTarget(_ target: inout CustomScrollTarget, context: TargetContext) {}
}

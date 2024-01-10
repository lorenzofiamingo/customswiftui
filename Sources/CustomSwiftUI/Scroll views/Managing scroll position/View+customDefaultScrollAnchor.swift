import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Associates an anchor to control which part of the scroll view's
    /// content should be rendered by default.
    ///
    /// Use this modifier to specify an anchor to control both which part of
    /// the scroll view's content should be visible initially and how
    /// the scroll view handles content size changes.
    ///
    /// Provide a value of `UnitPoint/center`` to have the scroll
    /// view start in the center of its content when a scroll view
    /// is scrollable in both axes.
    ///
    ///     ScrollView([.horizontal, .vertical]) {
    ///         // initially centered content
    ///     }
    ///     .defaultScrollAnchor(.center)
    ///
    /// Provide a value of `UnitPoint/bottom` to have the scroll view
    /// start at the bottom of its content when scrollable in the
    /// vertical axis.
    ///
    ///     @Binding var items: [Item]
    ///     @Binding var scrolledID: Item.ID?
    ///
    ///     ScrollView {
    ///         LazyVStack {
    ///             ForEach(items) { item in
    ///                 ItemView(item)
    ///             }
    ///         }
    ///     }
    ///     .defaultScrollAnchor(.bottom)
    ///
    /// The user may scroll away from the initial defined scroll position.
    /// When the content size of the scroll view changes, it may consult
    /// the anchor to know how to reposition the content.
    ///
    public func customDefaultScrollAnchor(_ anchor: UnitPoint) -> some View {
        transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
            scrollEnvironmentProperties.defaultAnchor = anchor
        }
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Configures the bounce behavior of scrollable views along the specified
    /// axis.
    ///
    /// Use this modifier to indicate whether scrollable views bounce when
    /// people scroll to the end of the view's content, taking into account the
    /// relative sizes of the view and its content. For example, the following
    /// ``ScrollView`` only enables bounce behavior if its content is large
    /// enough to require scrolling:
    ///
    ///     ScrollView {
    ///         Text("Small")
    ///         Text("Content")
    ///     }
    ///     .customScrollBounceBehavior(.basedOnSize)
    ///
    /// The modifier passes the scroll bounce mode through the ``Environment``,
    /// which means that the mode affects any scrollable views in the modified
    /// view hierarchy. Provide an axis to the modifier to constrain the kinds
    /// of scrollable views that the mode affects. For example, all the scroll
    /// views in the following example can access the mode value, but
    /// only the two nested scroll views are affected, because only they use
    /// horizontal scrolling:
    ///
    ///     CustomScrollView { // Defaults to vertical scrolling.
    ///         CustomScrollView(.horizontal) {
    ///             ShelfContent()
    ///         }
    ///         CustomScrollView(.horizontal) {
    ///             ShelfContent()
    ///         }
    ///     }
    ///     .customScrollBounceBehavior(.basedOnSize, axes: .horizontal)
    ///
    /// You can use this modifier to configure any kind of scrollable view,
    /// including ``ScrollView``, ``List``, ``Table``, and ``TextEditor``:
    ///
    ///     CustomScrollView {
    ///         Text("Hello")
    ///         Text("World")
    ///     }
    ///     .customScrollBounceBehavior(.basedOnSize)
    ///
    /// - Parameters:
    ///   - behavior: The bounce behavior to apply to any scrollable views
    ///     within the configured view. Use one of the ``CustomScrollBounceBehavior``
    ///     values.
    ///   - axes: The set of axes to apply `behavior` to. The default is
    ///     ``Axis/vertical``.
    ///
    /// - Returns: A view that's configured with the specified scroll bounce
    ///   behavior.
    public func customScrollBounceBehavior(_ behavior: CustomScrollBounceBehavior, axes: Axis.Set = [.vertical, .horizontal]) -> some View {
        transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
            if axes.contains(.horizontal) {
                scrollEnvironmentProperties.horizontal.bounceBehavior = behavior
            }
            if axes.contains(.vertical) {
                scrollEnvironmentProperties.vertical.bounceBehavior = behavior
            }
        }
    }
}

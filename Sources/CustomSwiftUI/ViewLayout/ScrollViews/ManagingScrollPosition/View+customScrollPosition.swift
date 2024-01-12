import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Associates a binding to be updated when a scroll view within this
    /// view scrolls.
    ///
    /// Use this modifier along with the ``View/scrollTargetLayout()``
    /// modifier to know the identity of the view that is actively scrolled.
    /// As the scroll view scrolls, the binding will be updated with the
    /// identity of the leading-most / top-most view.
    ///
    /// Use the ``View/scrollTargetLayout()`` modifier to configure
    /// which the layout that contains your scroll targets. In the following
    /// example, the top-most ItemView will update with the scrolledID
    /// binding as the scroll view scrolls.
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
    ///         .scrollTargetLayout()
    ///     }
    ///     .scrollPosition(id: $scrolledID)
    ///
    /// You can write to the binding to scroll to the view with
    /// the provided identity.
    ///
    ///     @Binding var items: [Item]
    ///     @Binding var scrolledID: Item.ID?
    ///
    ///     ScrollView {
    ///         // ...
    ///     }
    ///     .scrollPosition(id: $scrolledID)
    ///     .toolbar {
    ///         Button("Scroll to Top") {
    ///             scrolledID = items.first
    ///         }
    ///     }
    ///
    /// SwiftUI will attempt to keep the view with the identity specified
    /// in the provided binding when events occur that might cause it
    /// to be scrolled out of view by the system. Some examples of these
    /// include:
    ///   - The data backing the content of a scroll view is re-ordered.
    ///   - The size of the scroll view changes, like when a window is resized
    ///     on macOS or during a rotation on iOS.
    ///   - The scroll view initially lays out it content defaulting to
    ///     the top most view, but the binding has a different view's identity.
    ///
    /// You can provide an anchor to this modifier to both:
    ///   - Influence which view the system chooses as the view whose
    ///     identity value will update the providing binding as the scroll
    ///     view scrolls.
    ///   - Control the alignment of the view when scrolling to a view
    ///     when writing a new binding value.
    ///
    /// For example, providing a value of ``UnitPoint/bottom`` will prefer
    /// to have the bottom-most view chosen and prefer to scroll to views
    /// aligned to the bottom.
    public func customScrollPosition(id: Binding<(some Hashable)?>, anchor: UnitPoint? = nil) -> some View {
        modifier(ScrollValueBindingModifier(binding: id, anchor: anchor))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct ScrollValueBindingModifier<ID: Hashable>: ViewModifier {

    @State private var targetCoordinator = CustomTargetCoordinator()

    var binding: Binding<ID?>

    var anchor: UnitPoint?

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.customScrollEnvironmentProperties) { properties in
                properties.targetCoordinator = targetCoordinator
            }
            .onAppear {
                targetCoordinator.positionIDObjectIdentifier = ObjectIdentifier(ID.self)
                targetCoordinator.onPositionIDFromScroll = { id in
                    self.binding.wrappedValue = id.flatMap { $0 as? ID }
                }
            }
            .customOnChange(of: anchor, initial: true) {
                targetCoordinator.anchor = anchor
            }
            .onUpdate(of: binding.wrappedValue) { _, transaction in
                if AnyHashable(binding.wrappedValue) != targetCoordinator.positionID {
                    targetCoordinator.positionID = binding.wrappedValue
                    targetCoordinator.onPositionIDFromValue?(binding.wrappedValue, transaction)
                }
            }
    }
}

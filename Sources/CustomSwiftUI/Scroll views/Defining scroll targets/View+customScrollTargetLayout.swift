import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Configures the outermost layout as a scroll target layout.
    ///
    /// This modifier works together with the
    /// ``ViewAlignedScrollTargetBehavior`` to ensure that scroll views align
    /// to view based content.
    ///
    /// Apply this modifier to layout containers like ``LazyHStack`` or
    /// ``VStack`` within a ``ScrollView`` that contain the main repeating
    /// content of your ``ScrollView``.
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
    ///
    /// Scroll target layouts act as a convenience for applying a
    /// ``View/scrollTarget(isEnabled:)`` modifier to each views in
    /// the layout.
    ///
    /// A scroll target layout will ensure that any target layout
    /// nested within the primary one will not also become a scroll
    /// target layout.
    ///
    ///     LazyHStack { // a scroll target layout
    ///         VStack { ... } // not a scroll target layout
    ///         LazyHStack { ... } // also not a scroll target layout
    ///     }
    ///     .scrollTargetLayout()
    ///
    public func customScrollTargetLayout(isEnabled: Bool = true) -> some View {
        modifier(CustomScrollTargetModifier(role: isEnabled ? .container : .none))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomScrollTargetModifier: ViewModifier {

    var role: CustomScrollTargetRole.Role?

    func body(content: Content) -> some View {
        content
            .environment(\.customScrollTargetRole, role)
    }
}

struct CustomScrollTargetRole {

    enum Role {
        case container
        case target
    }
}

struct CustomScrollTargetRoleKey: EnvironmentKey {
    static var defaultValue: CustomScrollTargetRole.Role? {
        .none
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    
    var customScrollTargetRole: CustomScrollTargetRole.Role? {
        get { self[CustomScrollTargetRoleKey.self] }
        set { self[CustomScrollTargetRoleKey.self] = newValue }
    }
}

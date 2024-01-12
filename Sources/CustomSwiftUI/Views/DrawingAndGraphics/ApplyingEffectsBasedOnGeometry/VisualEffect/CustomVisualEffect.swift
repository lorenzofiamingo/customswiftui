import SwiftUI

/// Visual Effects change the visual appearance of a view without changing its
/// ancestors or descendents.
///
/// Because effects do not impact layout, they are safe to use in situations
/// where layout modification is not allowed. For example, effects may be
/// applied as a function of position, accessed through a geometry proxy:
///
/// ```swift
/// var body: some View {
///     ContentRow()
///         .visualEffect { content, geometryProxy in
///             content.offset(x: geometryProxy.frame(in: .global).origin.y)
///         }
/// }
/// ```
///
/// You don't conform to this protocol yourself. Instead, visual effects are
/// created by calling modifier functions (such as `.offset(x:y:)` on other
/// effects, as seen in the example above.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol CustomVisualEffect: Sendable, Animatable {

    associatedtype _Modifier: ViewModifier
    static func _makeModifier(effect: Self?) -> _Modifier
}

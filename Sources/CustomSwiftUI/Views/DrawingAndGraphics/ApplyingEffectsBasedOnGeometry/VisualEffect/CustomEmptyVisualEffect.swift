import SwiftUI

/// The base visual effect that you apply additional effect to.
///
/// `CustomEmptyVisualEffect` does not change the appearance of the
/// view that it is applied to.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomEmptyVisualEffect: CustomVisualEffect {

    /// Creates a new empty custom visual effect.
    public init() {}

    public static func _makeModifier(effect: CustomEmptyVisualEffect?) -> some ViewModifier {
        Modifier()
    }

    private struct Modifier: ViewModifier {

        func body(content: Content) -> some View {
            content
        }
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Configures the content margin for a provided placement.
    ///
    /// Use this modifier to customize the content margins of different
    /// kinds of views. For example, you can use this modifier to customize
    /// the margins of scrollable views like ``ScrollView``. In the
    /// following example, the scroll view will automatically inset
    /// its content by the safe area plus an additional 20 points
    /// on the leading and trailing edge.
    ///
    ///     ScrollView(.horizontal) {
    ///         // ...
    ///     }
    ///     .contentMargins(.horizontal, 20.0)
    ///
    /// You can provide a ``ContentMarginPlacement`` to target specific
    /// parts of a view to customize. For example, provide a
    /// ``ContentMargingPlacement/scrollContent`` placement to
    /// inset the content of a ``TextEditor`` without affecting the
    /// insets of its scroll indicators.
    ///
    ///     TextEditor(text: $text)
    ///         .contentMargins(.horizontal, 20.0, for: .scrollContent)
    ///
    /// Similarly, you can customize the insets of scroll indicators
    /// separately from scroll content. Consider doing this when applying
    /// a custom clip shape that may clip the indicators.
    ///
    ///     ScrollView {
    ///         // ...
    ///     }
    ///     .clipShape(.rect(cornerRadius: 20.0))
    ///     .contentMargins(10.0, for: .scrollIndicators)
    ///
    /// When applying multiple contentMargins modifiers, modifiers with
    /// the same placement will override modifiers higher up in the view
    /// hierarchy.
    ///
    /// - Parameters:
    ///   - edges: The edges to add the margins to.
    ///   - insets: The amount of margins to add.
    ///   - placement: Where the margins should be added.
    public func customContentMargins(_ edges: Edge.Set = .all, _ insets: EdgeInsets, for placement: CustomContentMarginPlacement = .automatic) -> some View {
        modifier(CustomContentMarginModifier(edges: edges, insets: OptionalEdgeInsets(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing), placement: placement))
    }

    /// Configures the content margin for a provided placement.
    ///
    /// Use this modifier to customize the content margins of different
    /// kinds of views. For example, you can use this modifier to customize
    /// the margins of scrollable views like ``ScrollView``. In the
    /// following example, the scroll view will automatically inset
    /// its content by the safe area plus an additional 20 points
    /// on the leading and trailing edge.
    ///
    ///     ScrollView(.horizontal) {
    ///         // ...
    ///     }
    ///     .contentMargins(.horizontal, 20.0)
    ///
    /// You can provide a ``ContentMarginPlacement`` to target specific
    /// parts of a view to customize. For example, provide a
    /// ``ContentMargingPlacement/scrollContent`` placement to
    /// inset the content of a ``TextEditor`` without affecting the
    /// insets of its scroll indicators.
    ///
    ///     TextEditor(text: $text)
    ///         .contentMargins(.horizontal, 20.0, for: .scrollContent)
    ///
    /// Similarly, you can customize the insets of scroll indicators
    /// separately from scroll content. Consider doing this when applying
    /// a custom clip shape that may clip the indicators.
    ///
    ///     ScrollView {
    ///         // ...
    ///     }
    ///     .clipShape(.rect(cornerRadius: 20.0))
    ///     .contentMargins(10.0, for: .scrollIndicators)
    ///
    /// When applying multiple contentMargins modifiers, modifiers with
    /// the same placement will override modifiers higher up in the view
    /// hierarchy.
    ///
    /// - Parameters:
    ///   - edges: The edges to add the margins to.
    ///   - length: The amount of margins to add.
    ///   - placement: Where the margins should be added.
    public func customContentMargins(_ edges: Edge.Set = .all, _ length: CGFloat?, for placement: CustomContentMarginPlacement = .automatic) -> some View {
        modifier(CustomContentMarginModifier(edges: edges, insets: OptionalEdgeInsets(top: length, leading: length, bottom: length, trailing: length), placement: placement))
    }

    /// Configures the content margin for a provided placement.
    ///
    /// Use this modifier to customize the content margins of different
    /// kinds of views. For example, you can use this modifier to customize
    /// the margins of scrollable views like ``ScrollView``. In the
    /// following example, the scroll view will automatically inset
    /// its content by the safe area plus an additional 20 points
    /// on the leading and trailing edge.
    ///
    ///     ScrollView(.horizontal) {
    ///         // ...
    ///     }
    ///     .contentMargins(.horizontal, 20.0)
    ///
    /// You can provide a ``ContentMarginPlacement`` to target specific
    /// parts of a view to customize. For example, provide a
    /// ``ContentMargingPlacement/scrollContent`` placement to
    /// inset the content of a ``TextEditor`` without affecting the
    /// insets of its scroll indicators.
    ///
    ///     TextEditor(text: $text)
    ///         .contentMargins(.horizontal, 20.0, for: .scrollContent)
    ///
    /// Similarly, you can customize the insets of scroll indicators
    /// separately from scroll content. Consider doing this when applying
    /// a custom clip shape that may clip the indicators.
    ///
    ///     ScrollView {
    ///         // ...
    ///     }
    ///     .clipShape(.rect(cornerRadius: 20.0))
    ///     .contentMargins(10.0, for: .scrollIndicators)
    ///
    /// When applying multiple contentMargins modifiers, modifiers with
    /// the same placement will override modifiers higher up in the view
    /// hierarchy.
    ///
    /// - Parameters:
    ///   - length: The amount of margins to add on all edges.
    ///   - placement: Where the margins should be added.
    public func customContentMargins(_ length: CGFloat, for placement: CustomContentMarginPlacement = .automatic) -> some View {
        modifier(CustomContentMarginModifier(edges: .all, insets: OptionalEdgeInsets(top: length, leading: length, bottom: length, trailing: length), placement: placement))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomContentMarginModifier: ViewModifier {

    let edges: Edge.Set

    let insets: OptionalEdgeInsets

    let placement: CustomContentMarginPlacement

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.customScrollEnvironmentProperties) { environmentProperties in
                switch placement.role {
                case .automatic:
                    updateMargins(&environmentProperties.contentMargins)
                    updateMargins(&environmentProperties.indicatorsMargins)
                case .scrollContent:
                    updateMargins(&environmentProperties.contentMargins)
                case .scrollIndicators:
                    updateMargins(&environmentProperties.indicatorsMargins)
                }
            }
    }

    private func updateMargins(_ margins: inout EdgeInsets) {
        if edges.contains(.top) {
            margins.top = insets.top ?? 0
        }
        if edges.contains(.bottom) {
            margins.bottom = insets.bottom ?? 0
        }
        if edges.contains(.leading) {
            margins.leading = insets.leading ?? 0
        }
        if edges.contains(.trailing) {
            margins.trailing = insets.trailing ?? 0
        }
    }
}

private struct OptionalEdgeInsets {

    var top: CGFloat?

    var leading: CGFloat?

    var bottom: CGFloat?

    var trailing: CGFloat?
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private extension EdgeInsets {

    init(_ optionalEdgeInsets: OptionalEdgeInsets) {
        self.init(
            top: optionalEdgeInsets.top ?? 0,
            leading: optionalEdgeInsets.leading ?? 0,
            bottom: optionalEdgeInsets.bottom ?? 0,
            trailing: optionalEdgeInsets.trailing ?? 0
        )
    }
}

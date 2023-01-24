import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    /// Sets the unique custom tag value of this view.
    ///
    /// Use this modifier to differentiate among certain selectable views,
    /// like the possible values of a ``CustomPicker``.
    /// Custom tag values can be of any type that conforms to the
    /// <doc://com.apple.documentation/documentation/Swift/Hashable> protocol.
    ///
    /// In the example below, the ``ForEach`` loop in the ``CustomPicker``
    /// view builder iterates over the `Flavor` enumeration. It extracts the string
    /// value of each enumeration element for use in constructing the row
    /// label, and uses the enumeration value, cast as an optional, as input
    /// to the `customTag(_:)` modifier. The ``Picker`` requires the tags to
    /// have a type that exactly matches the selection type, which in this case is an
    /// optional `Flavor`.
    ///
    ///     struct FlavorPicker: View {
    ///         enum Flavor: String, CaseIterable, Identifiable {
    ///             case chocolate, vanilla, strawberry
    ///             var id: Self { self }
    ///         }
    ///
    ///         @State private var selectedFlavor: Flavor? = nil
    ///
    ///         var body: some View {
    ///             CustomPicker("Flavor", selection: $selectedFlavor) {
    ///                 ForEach(Flavor.allCases) { flavor in
    ///                     Text(flavor.rawValue).customTag(Optional(flavor))
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// If you change `selectedFlavor` to be non-optional, you need to
    /// remove the <doc://com.apple.documentation/documentation/Swift/Optional>
    /// cast from the custom tag input to match.
    ///
    /// A ``CustomForEach`` automatically applies a default custom tag to each enumerated
    /// view using the `id` parameter of the corresponding element. If
    /// the element's `id` parameter and the picker's `selection` input
    /// have exactly the same type, you can omit the explicit custom tag modifier.
    /// To see examples that don't require an explicit tag, see ``CustomPicker``.
    ///
    /// - Parameter tag: A <doc://com.apple.documentation/documentation/Swift/Hashable>
    ///   value to use as the view's custom tag.
    ///
    /// - Returns: A view with the specified custom tag set.
    public func customTag<V: Hashable>(_ tag: V) -> some View {
        customTrait(key: CustomTagValueKey<V>.self, value: .tagged(tag))
    }
}

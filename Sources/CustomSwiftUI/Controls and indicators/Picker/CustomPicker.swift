import SwiftUI

/// A control for selecting from a set of mutually exclusive values.
///
/// You create a picker by providing a selection binding, a label, and the
/// content for the picker to display. Set the `selection` parameter to a bound
/// property that provides the value to display as the current selection. Set
/// the label to a view that visually describes the purpose of selecting content
/// in the picker, and then provide the content for the picker to display.
///
/// For example, consider an enumeration of ice cream flavors and a ``State``
/// variable to hold the selected flavor:
///
///     enum Flavor: String, CaseIterable, Identifiable {
///         case chocolate, vanilla, strawberry
///         var id: Self { self }
///     }
///
///     @State private var selectedFlavor: Flavor = .chocolate
///
/// You can create a picker to select among the values by providing a label, a
/// binding to the current selection, and a collection of views for the picker's
/// content. Append a tag to each of these content views using the
/// ``View/customTag(_:)`` view modifier so that the type of each selection
/// matches the type of the bound state variable:
///
///     List {
///         Picker("Flavor", selection: $selectedFlavor) {
///             Text("Chocolate").tag(Flavor.chocolate)
///             Text("Vanilla").tag(Flavor.vanilla)
///             Text("Strawberry").tag(Flavor.strawberry)
///         }
///     }
///
/// If you provide a string label for the picker, as the example above does,
/// the picker uses it to initialize a ``Text`` view as a
/// label. Alternatively, you can use the ``init(selection:content:label:)``
/// initializer to compose the label from other views. The exact appearance
/// of the picker depends on the context. If you use a picker in a ``List``
/// in iOS, it appears in a row with the label and selected value, and a
/// chevron to indicate that you can tap the row to select a new value:
///
/// ![A screenshot of a list row that has the string Flavor on the left side,
/// and the string Chocolate on the right. The word Chocolate appears in a less
/// prominent color than the word Flavor. A right facing chevron appears to the
/// right of the word Chocolate.](Picker-1-iOS)
///
/// ### Iterating over a picker’s options
///
/// To provide selection values for the `Picker` without explicitly listing
/// each option, you can create the picker with a ``ForEach`` or ``CustomForEach``:
///
///     CustomPicker("Flavor", selection: $selectedFlavor) {
///         CustomForEach(Flavor.allCases) { flavor in
///             Text(flavor.rawValue.capitalized)
///         }
///     }
///
/// ``CustomForEach`` automatically assigns a tag to the selection views using
/// each option's `id`. This is possible because `Flavor` conforms to the
/// <doc://com.apple.documentation/documentation/Swift/Identifiable>
/// protocol.
///
/// The example above relies on the fact that `Flavor` defines the type of its
/// `id` parameter to exactly match the selection type. If that's not the case,
/// you need to override the tag. For example, consider a `Topping` type
/// and a suggested topping for each flavor:
///
///     enum Topping: String, CaseIterable, Identifiable {
///         case nuts, cookies, blueberries
///         var id: Self { self }
///     }
///
///     extension Flavor {
///         var suggestedTopping: Topping {
///             switch self {
///             case .chocolate: return .nuts
///             case .vanilla: return .cookies
///             case .strawberry: return .blueberries
///             }
///         }
///     }
///
///     @State private var suggestedTopping: Topping = .nuts
///
/// The following example shows a picker that's bound to a `Topping` type,
/// while the options are all `Flavor` instances. Each option uses the tag
/// modifier to associate the suggested topping with the flavor it displays:
///
///     List {
///         CustomPicker("Flavor", selection: $suggestedTopping) {
///             ForEach(Flavor.allCases) { flavor in
///                 Text(flavor.rawValue.capitalized)
///                     .customTag(flavor.suggestedTopping)
///             }
///         }
///         HStack {
///             Text("Suggested Topping")
///             Spacer()
///             Text(suggestedTopping.rawValue.capitalized)
///                 .foregroundStyle(.secondary)
///         }
///     }
///
/// When the user selects chocolate, the picker sets `suggestedTopping`
/// to the value in the associated tag:
///
/// ![A screenshot of two list rows. The first has the string Flavor on the left
/// side, and the string Chocolate on the right. A right facing chevron appears
/// to the right of the word Chocolate. The second row has the string Suggested
/// Topping on the left, and the string Nuts on the right. Both words on the
/// right use a less prominent color than those on the left.](Picker-2-iOS)
///
/// Other examples of when the views in a picker's ``ForEach`` need an explicit
/// tag modifier include when you:
/// * Select over the cases of an enumeration that conforms to the
///   <doc://com.apple.documentation/documentation/Swift/Identifiable> protocol
///   by using anything besides `Self` as the `id` parameter type. For example,
///   a string enumeration might use the case's `rawValue` string as the `id`.
///   That identifier type doesn't match the selection type, which is the type
///   of the enumeration itself.
/// * Use an optional value for the `selection` input parameter. For that to
///   work, you need to explicitly cast the tag modifier's input as
///   <doc://com.apple.documentation/documentation/Swift/Optional> to match.
///   For an example of this, see ``View/customTag(_:)``.
///
/// ### Styling pickers
///
/// You can customize the appearance and interaction of pickers using
/// styles that conform to the ``CustomPickerStyle`` protocol.
/// You can also apply styles that conform to the ``PickerStyle`` protocol, like
/// ``PickerStyle/segmented`` or ``PickerStyle/menu``. To set a specific style
/// for all picker instances within a view, use the ``View/customPickerStyle(_:)``
/// modifier. The following example applies the ``PickerStyle/segmented``
/// style to two pickers that independently select a flavor and a topping:
///
///     VStack {
///         CustomPicker("Flavor", selection: $selectedFlavor) {
///             CustomForEach(Flavor.allCases) { flavor in
///                 Text(flavor.rawValue.capitalized)
///             }
///         }
///         CustomPicker("Topping", selection: $selectedTopping) {
///             CustomForEach(Topping.allCases) { topping in
///                 Text(topping.rawValue.capitalized)
///             }
///         }
///     }
///     .customPickerStyle(.segmented)
///
/// ![A screenshot of two segmented controls. The first has segments labeled
/// Chocolate, Vanilla, and Strawberry, with the first of these selected.
/// The second control has segments labeled Nuts, Cookies, and Blueberries,
/// with the second of these selected.](Picker-3-iOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomPicker<Label, SelectionValue, Content>: View where Label: View, SelectionValue: Hashable, Content: CustomView {
    
    private let selection: [Binding<SelectionValue>]
    
    private let label: Label
    
    private let content: Content
    
    @Environment(\.customPickerStyle) private var style
    
    @ContentParser private var parse
    
    private var configuration: CustomPickerStyleConfiguration {
        CustomPickerStyleConfiguration(
            label: CustomPickerStyleConfiguration.Label(label),
            options: parse(content).map {
                CustomPickerOption(
                    parsedInformation: $0,
                    selection: selection
                )
            },
            selection: selection
        )
    }
    
    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    public var body: some View {
        AnyView(style.makePicker(configuration: configuration))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomPicker {
    
    /// Creates a custom picker that displays a custom label.
    ///
    /// If the wrapped values of the collection passed to `sources` are not all
    /// the same, some styles render the selection in a mixed state. The
    /// specific presentation depends on the style.  For example, a custom picker
    /// with a menu style uses dashes instead of checkmarks to indicate the
    /// selected values.
    ///
    /// In the following example, a custom picker in a document inspector controls the
    /// thickness of borders for the currently-selected shapes, which can be of
    /// any number.
    ///
    ///     enum Thickness: String, CaseIterable, Identifiable {
    ///         case thin
    ///         case regular
    ///         case thick
    ///
    ///         var id: String { rawValue }
    ///     }
    ///
    ///     struct Border {
    ///         var color: Color
    ///         var thickness: Thickness
    ///     }
    ///
    ///     @State private var selectedObjectBorders = [
    ///         Border(color: .black, thickness: .thin),
    ///         Border(color: .red, thickness: .thick)
    ///     ]
    ///
    ///     CustomPicker(
    ///         sources: $selectedObjectBorders,
    ///         selection: \.thickness
    ///     ) {
    ///         ForEach(Thickness.allCases) { thickness in
    ///             Text(thickness.rawValue)
    ///         }
    ///     } label: {
    ///         Text("Border Thickness")
    ///     }
    ///
    /// - Parameters:
    ///     - sources: A collection of values used as the source for displaying
    ///       the custom picker's selection.
    ///     - selection: The key path of the values that determines the
    ///       currently-selected options. When a user selects an option from the
    ///       custom picker, the values at the key path of all items in the `sources`
    ///       collection are updated with the selected option.
    ///     - content: A view that contains the set of options.
    ///     - label: A view that describes the purpose of selecting an option.
    public init<C>(sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @CustomViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) where C : RandomAccessCollection {
        self.selection = sources.map { $0[keyPath: selection] }
        self.label = label()
        self.content = content()
    }
    
    /// Creates a custom picker that displays a custom label.
    ///
    /// - Parameters:
    ///     - selection: A binding to a property that determines the
    ///       currently-selected option.
    ///     - content: A view that contains the set of options.
    ///     - label: A view that describes the purpose of selecting an option.
    public init(selection: Binding<SelectionValue>, @CustomViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.init(sources: [selection], selection: \.self, content: content, label: label)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomPicker where Label == Text {
    
    /// Creates a custom picker that generates its label from a localized string key.
    ///
    /// - Parameters:
    ///     - titleKey: A localized string key that describes the purpose of
    ///       selecting an option.
    ///     - selection: A binding to a property that determines the
    ///       currently-selected option.
    ///     - content: A view that contains the set of options.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// To initialize a picker with a string variable, use
    /// ``init(_:selection:content:)`` instead.
    public init(_ titleKey: LocalizedStringKey, selection: Binding<SelectionValue>, @CustomViewBuilder content: () -> Content) {
        self.init(selection: selection, content: content) {
            Text(titleKey)
        }
    }
    
    /// Creates a custom picker that generates its label from a localized string key.
    ///
    /// If the wrapped values of the collection passed to `sources` are not all
    /// the same, some styles render the selection in a mixed state. The
    /// specific presentation depends on the style.  For example, a custom picker
    /// with a menu style uses dashes instead of checkmarks to indicate the
    /// selected values.
    ///
    /// In the following example, a custom picker in a document inspector controls the
    /// thickness of borders for the currently-selected shapes, which can be of
    /// any number.
    ///
    ///     enum Thickness: String, CaseIterable, Identifiable {
    ///         case thin
    ///         case regular
    ///         case thick
    ///
    ///         var id: String { rawValue }
    ///     }
    ///
    ///     struct Border {
    ///         var color: Color
    ///         var thickness: Thickness
    ///     }
    ///
    ///     @State private var selectedObjectBorders = [
    ///         Border(color: .black, thickness: .thin),
    ///         Border(color: .red, thickness: .thick)
    ///     ]
    ///
    ///     CustomPicker(
    ///         "Border Thickness",
    ///         sources: $selectedObjectBorders,
    ///         selection: \.thickness
    ///     ) {
    ///         CustomForEach(Thickness.allCases) { thickness in
    ///             Text(thickness.rawValue)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///     - titleKey: A localized string key that describes the purpose of
    ///       selecting an option.
    ///     - sources: A collection of values used as the source for displaying
    ///       the custom picker's selection.
    ///     - selection: The key path of the values that determines the
    ///       currently-selected options. When a user selects an option from the
    ///       picker, the values at the key path of all items in the `sources`
    ///       collection are updated with the selected option.
    ///     - content: A view that contains the set of options.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    public init<C>(_ titleKey: LocalizedStringKey, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @CustomViewBuilder content: () -> Content) where C : RandomAccessCollection {
        self.init(sources: sources, selection: selection, content: content) {
            Text(titleKey)
        }
    }
    
    /// Creates a custom picker that generates its label from a string.
    ///
    /// - Parameters:
    ///     - title: A string that describes the purpose of selecting an option.
    ///     - selection: A binding to a property that determines the
    ///       currently-selected option.
    ///     - content: A view that contains the set of options.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// To initialize a custom picker with a localized string key, use
    /// ``init(_:selection:content:)`` instead.
    public init<S>(_ title: S, selection: Binding<SelectionValue>, @CustomViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(selection: selection, content: content) {
            Text(title)
        }
    }
    
    /// Creates a custom picker bound to a collection of bindings that generates
    /// its label from a string.
    ///
    /// If the wrapped values of the collection passed to `sources` are not all
    /// the same, some styles render the selection in a mixed state. The
    /// specific presentation depends on the style.  For example, a custom picker
    /// with a menu style uses dashes instead of checkmarks to indicate the
    /// selected values.
    ///
    /// In the following example, a cusotm picker in a document inspector controls the
    /// thickness of borders for the currently-selected shapes, which can be of
    /// any number.
    ///
    ///     enum Thickness: String, CaseIterable, Identifiable {
    ///         case thin
    ///         case regular
    ///         case thick
    ///
    ///         var id: String { rawValue }
    ///     }
    ///
    ///     struct Border {
    ///         var color: Color
    ///         var thickness: Thickness
    ///     }
    ///
    ///     @State private var selectedObjectBorders = [
    ///         Border(color: .black, thickness: .thin),
    ///         Border(color: .red, thickness: .thick)
    ///     ]
    ///
    ///     CustomPicker(
    ///         "Border Thickness",
    ///         sources: $selectedObjectBorders,
    ///         selection: \.thickness
    ///     ) {
    ///         CustomForEach(Thickness.allCases) { thickness in
    ///             Text(thickness.rawValue)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///     - title: A string that describes the purpose of selecting an option.
    ///     - sources: A collection of values used as the source for displaying
    ///       the custom picker's selection.
    ///     - selection: The key path of the values that determines the
    ///       currently-selected options. When a user selects an option from the
    ///       custom picker, the values at the key path of all items in the `sources`
    ///       collection are updated with the selected option.
    ///     - content: A view that contains the set of options.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// To initialize a picker with a localized string key, use
    /// ``init(_:sources:selection:content:)`` instead.
    public init<C, S>(_ title: S, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @CustomViewBuilder content: () -> Content) where C : RandomAccessCollection, S : StringProtocol {
        self.init(sources: sources, selection: selection, content: content) {
            Text(title)
        }
    }
}

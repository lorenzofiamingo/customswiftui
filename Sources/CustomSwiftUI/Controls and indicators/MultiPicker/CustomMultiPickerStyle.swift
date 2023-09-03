import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets the style for custom multi pickers within this view.
    public func customMultiPickerStyle(_ customMultiPickerStyle: some CustomMultiPickerStyle) -> some View {
        environment(\.customMultiPickerStyle, customMultiPickerStyle)
    }
}

/// A type that specifies the appearance and interaction of all custom multi pickers within a view hierarchy.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol CustomMultiPickerStyle: DynamicProperty {

    /// A view that represents the body of a custompicker.
    associatedtype Body: View

    /// Creates a view that represents the body of a custom multi picker.
    ///
    /// The system calls this method for each ``CustomPicker`` instance in a view
    /// hierarchy where this style is the current custom multi picker style.
    ///
    /// - Parameter configuration : The properties of the custom multi picker.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body

    /// The properties of a custom multi picker.
    typealias Configuration = CustomMultiPickerStyleConfiguration
}

/// The properties of a custom multi picker.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomMultiPickerStyleConfiguration {

    /// A type-erased label of a custom multi picker.
    public typealias Label = AnyView

    /// A type-erased option of a custom multi picker.
    public typealias Option = CustomMultiPickerOption

    /// A type-erased selection value of a custom multi picker.
    public typealias SelectionValue = Option.Value

    /// A view that describes the effect of selecting a value with the custom multi picker.
    public let label: Label

    /// An array of views that contain information of each option.
    public let options: [Option]

    /// A binding to a state property that indicates which values are currently selected.
    public let selection: [Binding<Set<SelectionValue>>]

    init<V: Hashable>(label: some View, options: [CustomMultiPickerOption], selection: [Binding<Set<V>>]) {
        self.label = AnyView(label)
        self.options = options
        self.selection = selection.map { s in
            Binding {
                Set(s.wrappedValue.map { $0 })
            } set: { newValue in
                s.wrappedValue = Set(newValue.map { $0.base as! V })
            }
        }
    }
}

/// A type-erased option of a custom multi picker.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomMultiPickerOption: View, Identifiable {

    /// A type-erased value of a custom multi picker option.
    public typealias Value = AnyHashable

    /// A type-erased content of a custom multi picker option.
    public typealias Content = AnyView

    /// The stable identity of the custom multi picker option.
    public let id: Int

    /// A view that contains the content of the custom multi picker option.
    private let content: Content

    let tagValue: Value?

    let defaultValue: Value?

    /// The value associated with the custom multi picker option.
    public var value: Value? {
        tagValue ?? defaultValue
    }

    @Binding public var isOn: Bool

    public var isMixed: Bool

    init<SelectionValue: Hashable>(
        parsedInformation: ParsedInformation<SelectionValue>,
        selection: [Binding<Set<SelectionValue>>]
    ) {
        self.id = parsedInformation.id
        if let tagValue = parsedInformation.tagValue {
            self.tagValue = Value(tagValue)
        } else {
            self.tagValue = nil
        }
        if let defaultValue = parsedInformation.defaultValue {
            self.defaultValue = Value(defaultValue)
        } else {
            self.defaultValue = nil
        }
        self.content = Content(parsedInformation.content)
        if let value = parsedInformation.tagValue ?? parsedInformation.defaultValue {
            self._isOn = Binding {
                selection.allSatisfy { $0.wrappedValue.contains(value) }
            } set: { isOn in
                if isOn {
                    selection.forEach { $0.wrappedValue.insert(value) }
                } else {
                    selection.forEach { $0.wrappedValue.remove(value) }
                }
            }
            self.isMixed = selection.contains { $0.wrappedValue.contains(value) } && selection.contains { !$0.wrappedValue.contains(value) }
        } else {
            self._isOn = .constant(false)
            self.isMixed = false
        }
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
        content
            .id(id)
    }

    struct ParsedInformation<SelectionValue> {
        let id: ID

        let tagValue: SelectionValue?

        let defaultValue: SelectionValue?

        let content: Content

        init(
            id: ID,
            tagValue: SelectionValue?,
            defaultValue: SelectionValue?,
            content: any View
        ) {
            self.id = id
            self.tagValue = tagValue
            self.defaultValue = defaultValue
            self.content = Content(content)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomMultiPickerStyleKey: EnvironmentKey {

    static var defaultValue: any CustomMultiPickerStyle = .toggle
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    var customMultiPickerStyle: any CustomMultiPickerStyle {
        get { self[CustomMultiPickerStyleKey.self] }
        set { self[CustomMultiPickerStyleKey.self] = newValue }
    }
}

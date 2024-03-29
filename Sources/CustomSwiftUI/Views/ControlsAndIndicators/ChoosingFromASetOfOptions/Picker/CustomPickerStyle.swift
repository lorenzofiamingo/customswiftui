import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    /// Sets the style for custom pickers within this view.
    public func customPickerStyle(_ customPickerStyle: some CustomPickerStyle) -> some View {
        environment(\.customPickerStyle, customPickerStyle)
    }
}

/// A type that specifies the appearance and interaction of all custom pickers within a view hierarchy.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol CustomPickerStyle: DynamicProperty {
    
    /// A view that represents the body of a custompicker.
    associatedtype Body: View
    
    /// Creates a view that represents the body of a custom picker.
    ///
    /// The system calls this method for each ``CustomPicker`` instance in a view
    /// hierarchy where this style is the current custom picker style.
    ///
    /// - Parameter configuration : The properties of the custom picker.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
    
    /// The properties of a custom picker.
    typealias Configuration = CustomPickerStyleConfiguration
}

/// The properties of a custom picker.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomPickerStyleConfiguration {
    
    /// A type-erased label of a custom picker.
    public typealias Label = AnyView
    
    /// A type-erased option of a custom picker.
    public typealias Option = CustomPickerOption
    
    /// A type-erased selection value of a custom picker.
    public typealias SelectionValue = Option.Value
    
    /// A view that describes the effect of selecting a value with the custom picker.
    public let label: Label
    
    /// An array of views that contain information of each option.
    public let options: [Option]
    
    /// A binding to a state property that indicates which value is currently selected.
    public let selection: [Binding<SelectionValue>]
    
    init(label: some View, options: [CustomPickerOption], selection: [Binding<some Hashable>]) {
        self.label = AnyView(label)
        self.options = options
        self.selection = selection.map(Binding.init)
    }
}

/// A type-erased option of a custom picker.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomPickerOption: View, Identifiable {
    
    /// A type-erased value of a custom picker option.
    public typealias Value = AnyHashable
    
    /// A type-erased content of a custom picker option.
    public typealias Content = AnyView
    
    /// The stable identity of the custom picker option.
    public let id: Int
    
    /// A view that contains the content of the custom picker option.
    private let content: Content

    private let _select: () -> Void

    let tagValue: Value?
    
    let defaultValue: Value?

    /// The value associated with the custom picker option.
    public var value: Value? {
        tagValue ?? defaultValue
    }

    public var isSelected: Bool

    public var isMixed: Bool

    public func select() {
        _select()
    }

    init<SelectionValue: Hashable>(
        parsedInformation: ParsedInformation<SelectionValue>,
        selection: [Binding<SelectionValue>]
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
            self.isSelected = selection.allSatisfy { $0.wrappedValue == value }
            self.isMixed = selection.contains { $0.wrappedValue == value } && selection.contains { $0.wrappedValue != value }
            self._select = { selection.forEach { $0.wrappedValue = value } }
        } else {
            self.isSelected = false
            self.isMixed = false
            self._select = {}
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
struct CustomPickerStyleKey: EnvironmentKey {
    
    static var defaultValue: any CustomPickerStyle = BridgedCustomPickerStyle(.automatic)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    
    var customPickerStyle: any CustomPickerStyle {
        get { self[CustomPickerStyleKey.self] }
        set { self[CustomPickerStyleKey.self] = newValue }
    }
}

import SwiftUI

extension View {
    
    /// Sets the style for custom pickers within this view.
    public func customPickerStyle(_ pickerStyle: some PickerStyle) -> some View {
        environment(\.customPickerStyle, BridgedCustomPickerStyle(pickerStyle))
    }
}

struct BridgedCustomPickerStyle<BridgedPickerStyle: PickerStyle>: CustomPickerStyle {
    
    private typealias TagValue = BridgedCustomPickerStyleTagValue
    
    private let bridgedPickerStyle: BridgedPickerStyle
    
    init(_ bridgedPickerStyle: BridgedPickerStyle) {
        self.bridgedPickerStyle = bridgedPickerStyle
    }
    
    @ViewBuilder public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            makeDefaultBody(configuration: configuration)
        } else {
            makeFallbackBody(configuration: configuration)
        }
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @ViewBuilder private func makeDefaultBody(configuration: Configuration) -> some View {
        let sources = configuration.selection.map { source in
            Binding {
                TagValue.tagged(source.wrappedValue)
            } set: { tagValue, transaction in
                withTransaction(transaction) {
                    if case .tagged(let value) = tagValue {
                        source.wrappedValue = value
                    }
                }
            }
        }
        
        Picker(sources: sources, selection: \.self) {
            ForEach(configuration.options) { option in
                option
                    .tag(TagValue(value: option.value))
            }
        } label: {
            configuration.label
        }
        .pickerStyle(bridgedPickerStyle)
    }
    
    @ViewBuilder private func makeFallbackBody(configuration: Configuration) -> some View {
        let selection = Binding {
            configuration.selection.first!.wrappedValue // In SwiftUI an empty array crashes as well.
        } set: { value, transaction in
            configuration.selection.forEach { source in
                source.wrappedValue = value
            }
        }
        
        Picker(selection: selection) {
            ForEach(configuration.options) { option in
                option
                    .tag(TagValue(value: option.value))
            }
        } label: {
            configuration.label
        }
        .pickerStyle(bridgedPickerStyle)
    }
}

private enum BridgedCustomPickerStyleTagValue: Hashable {
    
    case tagged(CustomPickerOption.Value)
    
    case untagged
    
    init(value: CustomPickerOption.Value?) {
        if let value {
            self = .tagged(value)
        } else {
            self = .untagged
        }
    }
}

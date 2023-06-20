import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToggleCustomMultiPickerStyle: CustomMultiPickerStyle {

    func makeBody(configuration: Configuration) -> some View {
        ForEach(configuration.options) { option in
            let isOn = Binding<Bool> {
                guard let value = option.value else {
                    return false
                }
                return configuration.selection.wrappedValue.contains(value)
            } set: { isOn in
                guard let value = option.value else {
                    return
                }
                if isOn {
                    configuration.selection.wrappedValue.insert(value)
                } else {
                    configuration.selection.wrappedValue.remove(value)
                }
            }
            Toggle(isOn: isOn) {
                option
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomMultiPickerStyle where Self == ToggleCustomMultiPickerStyle {

    static var toggle: ToggleCustomMultiPickerStyle {
        ToggleCustomMultiPickerStyle()
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ToggleCustomMultiPickerStyle: CustomMultiPickerStyle {

    func makeBody(configuration: Configuration) -> some View {
        ForEach(configuration.options) { option in
            Toggle(isOn: option.$isOn) {
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

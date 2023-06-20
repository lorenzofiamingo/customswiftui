import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomMultiPickerStyle {

    func makeMultiPicker(configuration: Configuration) -> some View {
        CustomMultiPickerStyleView(style: self, configuration: configuration)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomMultiPickerStyleView<Style: CustomMultiPickerStyle>: View {

    private let style: Style

    private let configuration: CustomMultiPickerStyleConfiguration

    init(style: Style, configuration: CustomMultiPickerStyleConfiguration) {
        self.style = style
        self.configuration = configuration
    }

    var body: some View {
        style.makeBody(configuration: configuration)
            // customOnTraitChange action, since it uses transformPreference, doesn't get called when the view is not in hierarchy, so this is required in order to update option tag values.
            .background(ForEach(configuration.options) { $0 }.frame(width: 0, height: 0))
    }
}

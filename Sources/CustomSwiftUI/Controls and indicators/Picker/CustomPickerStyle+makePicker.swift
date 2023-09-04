import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomPickerStyle {
    
    func makePicker(configuration: Configuration) -> some View {
        CustomPickerStyleView(style: self, configuration: configuration)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomPickerStyleView<Style: CustomPickerStyle>: View {
    
    private let style: Style
    
    private let configuration: CustomPickerStyleConfiguration
    
    init(style: Style, configuration: CustomPickerStyleConfiguration) {
        self.style = style
        self.configuration = configuration
    }
    
    var body: some View {
        style.makeBody(configuration: configuration)
            // customOnTraitChange action, since it uses transformPreference, doesn't get called when the view is not in hierarchy, so this is required in order to update option tag values.
            // .background(ForEach(configuration.options) { $0 }.frame(width: 0, height: 0).clipped())
    }
}

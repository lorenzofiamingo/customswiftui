//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct ColorPickerStyle: CustomPickerStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ForEach(configuration.options) { option in
                let isSelected = configuration.selection.first?.wrappedValue == option.value
                let isMixed = configuration.selection.contains { source in
                    source.wrappedValue == option.value
                }
                Button {
                    if let value = option.value {
                        configuration.selection.forEach { source in
                            source.wrappedValue = value
                        }
                    }
                } label: {
                    option
                }
                .buttonStyle(.bordered)
                .tint(isSelected ? .green : isMixed ? .orange : .red)
            }
        }
        .animation(.default, value: configuration.selection.first?.wrappedValue)
    }
}

extension CustomPickerStyle where Self == ColorPickerStyle {
    static var color: ColorPickerStyle {
        ColorPickerStyle()
    }
}


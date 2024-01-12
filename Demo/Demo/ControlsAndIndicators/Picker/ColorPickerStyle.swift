//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct ColorPickerStyle: CustomPickerStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ForEach(configuration.options) { option in
                Button(action: option.select) {
                    option
                }
                .buttonStyle(.bordered)
                .tint(option.isSelected ? .green : option.isMixed ? .orange : .red)
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


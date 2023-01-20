//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct DropdownPickerStyle: CustomPickerStyle {
    
    @State private var showingDropdown = false
    
    func makeBody(configuration: Configuration) -> some View {
        PickerView(configuration: configuration, showingDropdown: $showingDropdown)
    }
    
    struct PickerView: View {
        
        let configuration: Configuration
        
        @Binding var showingDropdown: Bool
        
        var body: some View {
            ZStack(alignment: .bottom) {
                button
                Spacer()
                    .frame(width: 0, height: 0)
                    .overlay(alignment: .top) {
                        Group {
                            if showingDropdown {
                                    overlay
                                        .padding()
                                        .fixedSize()
                                        .background(Material.thick)
                                        .cornerRadius(8)
                                        .shadow(radius: 96)
                                        .padding(.top)
                                        .background {
                                            Spacer()
                                                .frame(width: UIScreen.main.bounds.size.width*2, height: UIScreen.main.bounds.size.height*2)
                                                .ignoresSafeArea()
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    showingDropdown = false
                                                }
                                        }
                                        .transition(.opacity.combined(with: .scale.animation(.interpolatingSpring(stiffness: 200, damping: 20))))
                            }
                        }
                        .animation(.default, value: showingDropdown)
                    }
            }
        }
        
        @ViewBuilder
        var button: some View {
            let selectedOption = configuration.options.first { option in
                configuration.selection.first?.wrappedValue == option.value
            } ?? configuration.options.first
            if let selectedOption {
                Button {
                    showingDropdown = true
                } label: {
                    Label {
                      selectedOption
                        .id(selectedOption.value)
                    } icon: {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.body)
                    }
                }
            }
        }
        
        @ViewBuilder
        var overlay: some View {
            VStack {
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
                            showingDropdown = false
                        }
                    } label: {
                        option
                    }
                    .buttonStyle(.bordered)
                    .tint(isSelected ? .green : isMixed ? .orange : .red)
                }
            }
        }
    }
}

extension CustomPickerStyle where Self == DropdownPickerStyle {
    static var dropdown: DropdownPickerStyle {
        DropdownPickerStyle()
    }
}


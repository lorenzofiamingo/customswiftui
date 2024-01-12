//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct Person: Hashable {
    let name: String
    var initial: String {
        String(name.first ?? "X")
    }
}

enum Thickness: String, CaseIterable, Identifiable {
  case thin
  case regular
  case thick
  
  var id: String { rawValue }
}

struct Border: Hashable, Identifiable {
  var id = UUID().uuidString
  var color: Color
  var thickness: Thickness
}

struct CustomPickerDemo: View {
  
  @State private var selectedObjectBorders: [Border] = [
    Border(color: .blue, thickness: .thin),
    Border(color: .brown, thickness: .regular),
    Border(color: .purple, thickness: .regular)
  ]
  
  private let names: [String?] = ["Mike", "John", "Peter"]
  
  @State private var selectedName: String?
  
  @State private var canSelectNil = true
  
  var body: some View {
    ScrollView {
      Section {
        Toggle("None is selectable", isOn: $canSelectNil.animation(.default))
          .padding()
      }
      Section {
        picker
          .customPickerStyle(.dropdown)
          .pickerStyle(.menu)
          .zIndex(1)
      }
      Section {
        picker
          .customPickerStyle(.color)
          .pickerStyle(.segmented)
      }
      Section {
        HStack {
          ForEach(selectedObjectBorders, id: \.self) { border in
            Text(border.thickness.rawValue).foregroundColor(border.color)
          }
        }
        .frame(maxWidth: .infinity)
        CustomPicker(
          sources: $selectedObjectBorders,
          selection: \.thickness
        ) {
          CustomForEach(Thickness.allCases) { thickness in
            Text(thickness.rawValue)
              .customTag(thickness)
          }
        } label: {
          Text("Hi")
        }
        .customPickerStyle(.color)
        .frame(maxWidth: .infinity)
      }
    }.padding()
    .navigationTitle("Picker")
  }
  
  var picker: some View {
    VStack {
      Section("CustomSwiftUI") {
        CustomPicker(selection: $selectedName.animation(.default)) {
          if canSelectNil {
            Text("Nil")
              .customTag(nil as String?)
          }
          CustomForEach(names, id: \.self) { name in
            Text(name ?? "None")
          }
        } label: { }
          .zIndex(1)
      }
      Section("SwiftUI") {
        Picker(selection: $selectedName.animation(.default)) {
          if canSelectNil {
            Text("Nil")
              .tag(nil as String?)
          }
          ForEach(names, id: \.self) { name in
            Text(name ?? "None")
          }
        } label: { }
      }
    }.padding(.bottom, 50)
  }
}

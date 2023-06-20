//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

enum Tag: String, CaseIterable {
  case dog
  case cat
  case mouse
}

struct CustomMultiPickerDemo: View {

  private let tags = ["Dog", "Cat", "Mouse"].sorted()

  @State private var selectedTags: Set<String> = Set()

  var body: some View {
    List {
      Section {
        CustomMultiPicker("MultiPicker", selection: $selectedTags) {
          CustomForEach(tags, id: \.self) { tag in
            Text(tag)
          }
        }
      } footer: {
          Button("Clear") {
            selectedTags.removeAll()
          }
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
      Section {
        HStack {
          Text("Tags: ")
          ForEach(selectedTags.sorted(), id: \.self) { tag in
            Text(tag)
          }
        }.animation(.default, value: selectedTags)
      }
    }
    .navigationTitle("MultiPicker")
  }
}

struct CustomMultiPickerDemo_Previews: PreviewProvider {
  static var previews: some View {
    CustomTintDemo()
  }
}

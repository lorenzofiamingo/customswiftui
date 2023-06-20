//
// CustomSwiftUI Demo
//

import SwiftUI

struct ControlsAndIndicatorsView: View {
  
  var body: some View {
    List {
      Section("Choosing from a set of options") {
        NavigationLink("Picker") {
          CustomPickerDemo()
        }
        NavigationLink("MultiPicker") {
          CustomMultiPickerDemo()
        }
      }
    }
    .navigationTitle("Controls and indicators")
  }
}

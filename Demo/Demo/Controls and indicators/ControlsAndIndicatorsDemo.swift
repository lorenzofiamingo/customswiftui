//
// CustomSwiftUI Demo
//

import SwiftUI

struct ControlsAndIndicatorsDemo: View {
  
  var body: some View {
    List {
      Section("Choosing from a set of options") {
        NavigationLink("CustomPicker") {
          CustomPickerDemo()
        }
      }
    }
    .navigationTitle("Controls and indicators")
  }
}

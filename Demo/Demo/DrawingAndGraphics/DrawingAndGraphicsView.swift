//
// CustomSwiftUI Demo
//

import SwiftUI

struct DrawingAndGraphicsView: View {

  var body: some View {
    List {
      Section("Setting a color") {
        NavigationLink("Tint") {
          CustomTintDemo()
        }
      }
    }
    .navigationTitle("Drawing and graphics")
  }
}

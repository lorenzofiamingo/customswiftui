//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct Cat: Hashable {
  var name = "Zoe"
}

struct NavigationDemo: View {

  @State private var npath = NavigationPath()

  var body: some View {
    List {
      Section("Stacking views in one column") {
        NavigationLink("CustomNavigationStack") {
          CustomNavigationStackDemo()
        }
        NavigationLink("Test") {
          NavigationStack(path: $npath) {
            Button("Prova") {
              npath.append(Dog())
            }
            .navigationDestination(for: Dog.self) { person in
              Text("A")
            }
          }
        }
      }
    }
    .navigationTitle("Controls and indicators")
  }
}

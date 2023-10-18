//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct CustomNavigationStackDemo: View {

  @State private var path = NavigationPath()

  @State private var isPresented = false

  var pathString: String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(path.codable),
          let output = String(data: data, encoding: .utf8)
    else { fatalError( "Error converting \(path) to JSON string") }
    return output
  }

  struct X: Codable, Hashable {
    let a = "b"
  }

  var body: some View {
    VStack {
      
      Divider()
      NavigationStack(path: $path) {
        Text(pathString)
        Button("Push X") {
          struct X: Codable, Hashable {
            let a = "b"
          }
          path.append(X())
        }
        .navigationDestination(for: X.self) { t in
          Text(pathString)
          Button("Push TT") {
            path.append(T())
          }
        }
        Button("Present") {
          isPresented.toggle()
        }
        .navigationDestination(isPresented: $isPresented) {
          Text(pathString)
          Button("Present") {
            isPresented.toggle()
          }
          Button("Push T") {
            path.append(T())
          }
          .navigationDestination(for: T.self) { t in
            Text(pathString)
            Button("Push T") {
              path.append(T())
            }
          }
        }
      }
      Divider()
      NavigationStack(path: $path) {
        Text(pathString)
        Button("Push T") {
          path.append(T())
        }
        .navigationDestination(for: T.self) { t in
          Text(pathString)
        }
        Button("Present") {
          isPresented.toggle()
        }
        .navigationDestination(isPresented: $isPresented) {
          Text(pathString)
          Button("Present") {
            isPresented.toggle()
          }
        }
      }
      Divider()
    }
    .onChange(of: path) { path in
      let t = Mirror(reflecting: path)
      for child in t.children {
        print(child.label, child.value, Mirror(reflecting: child.value).displayStyle)
      }
    }
  }
}

struct T: Hashable, Codable {
}

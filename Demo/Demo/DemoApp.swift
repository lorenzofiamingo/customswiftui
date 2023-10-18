//
// CustomSwiftUI Demo
//

import SwiftUI
import Runtime
import CustomSwiftUI

@main
struct DemoApp: App {
  var body: some Scene {
    WindowGroup {
      _ContentView()
        .onAppear {
          var path = NavigationPath()

          struct User: Hashable, Codable {
            var id: Int
            var name: String
          }
          path.append(User(id: 42, name: "Blob"))
          struct T: Hashable, Codable {
            let t = "Y"
          }
          //let rr = _typeByName("SwiftUI.NavigationStateHost")
          //let xx = try! typeInfo(of: rr!)
          //let yy = try! typeInfo(of: xx.property(named: "pendingRequests").type)
          //let zz = try! typeInfo(of: yy.genericTypes.first!)
          //let aa = try! typeInfo(of: zz.genericTypes.first!)
          //let bb = try! typeInfo(of: aa.property(named: "key").type)
          //let cc = try! typeInfo(of: bb.cases[0].payloadType!)
          //let dd = try! typeInfo(of: cc.property(named: "column").type)
          let aa = type(of: EmptyView().navigationDestination(isPresented: .constant(true), destination: { EmptyView() }))
          let bb = try! typeInfo(of: aa)
          let cc = try! typeInfo(of: bb.genericTypes[1])
          //print(cc)
          print()
          //fatalError()
          //print(allProperties(NavigationPath([T()])))
        }
    }
  }
}

struct J: Hashable {
  let id = UUID()
}

// isPresented -> ViewDestinationNavigationDestinationModifier<View> destination is a value, isPresented, namespace
// Hashable -> NavigationDestinationModifier<C, EmptyView> destination is a function
func allProperties(_ pippo: Any) -> [[String]: (Any, Any)] {

  var result: [[String]: (Any, Any)] = [:]

  let mirror = Mirror(reflecting: pippo)

  for (labelMaybe, valueMaybe) in mirror.children {
    guard let label = labelMaybe else {
      continue
    }

    result[[label, _typeName(type(of:valueMaybe))]] = (valueMaybe, allProperties(valueMaybe))

    //if let buffer = try? (try! typeInfo(of: type(of:valueMaybe))).property(named: "_buffer") {
    //  let t = valueMaybe as! Array<Any>
    //  print("XXXX")
    //  let xx = try! typeInfo(of: type(of:t.first!))
    //  print(xx)
    //  print("FF", try! xx.property(named: "isDoubleDispatchingEqualityOperation").get(from: t.first!))
    //  print("XXXX")
    //}
  }

  return result
}


private struct _ContentView: View {

  @State private var path: [Dog] = []

  @State private var presentingA = false
  @State private var presentingB = false

  var body: some View {
    CustomNavigationStack(path: $path) {
      ScrollView {
        controllers
      }
      .onChange(of: path) { newValue in
        print("XXX \(newValue)")
      }
      .navigationTitle("Ciao")
      .navigationBarBackButtonHidden(true)
      .customNavigationDestination(for: Dog.self) { dog in
        controllers
      }
      .customNavigationDestination(isPresented: $presentingA) {
        Text("A")
        controllers
      }
      //.customNavigationDestination(isPresented: $presentingB) {
      //  Text("B")
      //  controllers
      //}
    }
    .navigationBarTitleDisplayMode(.inline)
    .edgesIgnoringSafeArea(.all)
    .background(.yellow)
  }

  @ViewBuilder
  var controllers: some View {
    Text("Presenting A: \(presentingA ? "true" : "false")")
    Text("Presenting B: \(presentingB ? "true" : "false")")
    HStack {
      Text("Path: ")
      ForEach(path) { dog in
        Text(dog.name)
      }
    }
    Button("Add Dog") {
      path.append(Dog())
    }
    Button("Remove Dog") {
      if !path.isEmpty {
        path.removeLast()
      }
    }
    Button("Remove all") {
      path.removeAll()
    }
    Button("Toggle A") {
      presentingA.toggle()
    }
    Button("Toggle B") {
      presentingB.toggle()
    }
    NavigationLink("Link dog", value: Dog())
    NavigationLink("Link destination") {
      Button("Add Dog") {
        path.append(Dog())
      }
      Button("Remove Dog") {
        if !path.isEmpty {
          path.removeLast()
        }
      }
      Button("Toggle A") {
        presentingA = true
      }
      Button("Toggle B") {
        presentingA = false
        presentingB = true
      }
      NavigationLink("Link dog", value: Dog())
    }
  }
}

struct Dog: Hashable, Identifiable {
  let id = UUID()
  var name = {
    count += 1
    return "Rex-\(count)"
  }()
}
// NavigationLink presenting a value must appear inside a NavigationStack or NavigationSplitView. Link will be disabled.

private var count = 0

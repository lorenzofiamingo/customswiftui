//
//  ContentView.swift
//  CustomSwiftUITestApp
//
//  Created by Lorenzo Fiamingo on 11/10/22.
//

import SwiftUI
import CustomSwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationView {
      List {
        Section("App structure") {
          NavigationLink("Navigation") {
            NavigationDemo()
          }
        }
        Section("Views") {
          NavigationLink("Controls and indicators") {
            ControlsAndIndicatorsDemo()
          }
        }
      }
      .navigationTitle("CustomSwiftUI")
    }
  }
}

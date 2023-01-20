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
        Section("Views") {
          NavigationLink("Controls and indicators") {
            ControlsAndIndicatorsView()
          }
        }
      }
      .navigationTitle("CustomSwiftUI")
    }
  }
}

//
// CustomSwiftUI Demo
//

import SwiftUI

struct ScrollViewsView: View {

    var body: some View {
        List {
            Section("Creating a scroll view") {
                NavigationLink("ScrollView") {
                    ScrollViewDemo()
                }
            }
        }
        .navigationTitle("Scroll views")
    }
}

//
// CustomSwiftUI Demo
//

import SwiftUI
import CustomSwiftUI

struct CustomTintDemo: View {

    var body: some View {
      TintView()
        .customTint(Color.red)
      TintView()
        .customTint(Color.yellow)
      TintView()
    }
}

struct TintView: View {

  @Environment(\.customTint) private var tint

  var body: some View {

    Group {
      if let tint {
        tint
      } else {
        Text("No tint")
      }
    }
    .frame(maxHeight: 64)
  }
}

struct CustomTintDemo_Previews: PreviewProvider {
    static var previews: some View {
        CustomTintDemo()
    }
}

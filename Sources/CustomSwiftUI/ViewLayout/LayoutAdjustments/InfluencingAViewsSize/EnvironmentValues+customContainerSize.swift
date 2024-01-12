import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    var customContainerSize: CGSize? {
        get { self[CustomContainerSizeKey.self] }
        set { self[CustomContainerSizeKey.self] = newValue }
    }
}

struct CustomContainerSizeKey: EnvironmentKey {
    static var defaultValue: CGSize? {
        .none
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomCoordinateSpaceProtocol where Self == CustomLocalCoordinateSpace {

    /// The local coordinate space of the current view.
    public static var local: CustomLocalCoordinateSpace {
        CustomLocalCoordinateSpace()
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomCoordinateSpaceProtocol where Self == CustomGlobalCoordinateSpace {

    /// The global coordinate space at the root of the view hierarchy.
    public static var global: CustomGlobalCoordinateSpace {
        CustomGlobalCoordinateSpace()
    }
}

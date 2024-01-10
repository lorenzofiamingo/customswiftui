import SwiftUI

/// The global coordinate space at the root of the view hierarchy.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomGlobalCoordinateSpace: CustomCoordinateSpaceProtocol {

    /// The resolved coordinate space.
    public var coordinateSpace: CoordinateSpace {
        .global
    }
}

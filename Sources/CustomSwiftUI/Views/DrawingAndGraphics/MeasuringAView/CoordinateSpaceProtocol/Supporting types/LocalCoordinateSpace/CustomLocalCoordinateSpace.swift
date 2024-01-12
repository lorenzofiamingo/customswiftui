import SwiftUI

/// The local coordinate space of the current view.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomLocalCoordinateSpace: CustomCoordinateSpaceProtocol {

    /// The resolved coordinate space.
    public var coordinateSpace: CoordinateSpace {
        .local
    }
}

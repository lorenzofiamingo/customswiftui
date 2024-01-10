import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomCoordinateSpaceProtocol where Self == CustomNamedCoordinateSpace {

    /// Creates a named coordinate space using the given value.
    ///
    /// Use the `coordinateSpace(_:)` modifier to assign a name to the local
    /// coordinate space of a  parent view. Child views can then refer to that
    /// coordinate space using `.named(_:)`.
    ///
    /// - Parameter name: A unique value that identifies the coordinate space.
    ///
    /// - Returns: A named coordinate space identified by the given value.
    public static func named(_ name: some Hashable) -> CustomNamedCoordinateSpace {
        CustomNamedCoordinateSpace(name: name)
    }
}


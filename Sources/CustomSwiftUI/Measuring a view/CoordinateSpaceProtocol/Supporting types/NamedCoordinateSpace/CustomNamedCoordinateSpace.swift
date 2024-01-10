import SwiftUI

/// A named coordinate space.
///
/// Use the `customCoordinateSpace(_:)` modifier to assign a name to the
/// custom local coordinate space of a  parent view. Child views can then refer to
/// that coordinate space using `.named(_:)`.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomNamedCoordinateSpace: CustomCoordinateSpaceProtocol, Equatable {

    /// The resolved coordinate space.
    public var coordinateSpace: CoordinateSpace {
        .named(name)
    }

    var name: AnyHashable
}

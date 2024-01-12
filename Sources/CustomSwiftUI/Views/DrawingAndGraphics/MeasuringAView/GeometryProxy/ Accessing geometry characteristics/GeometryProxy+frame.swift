import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension GeometryProxy {

    /// Returns the container view's bounds rectangle, converted to a defined
    /// coordinate space.
    public func frame(in coordinateSpace: some CustomCoordinateSpaceProtocol) -> CGRect {
        self.frame(in: coordinateSpace.coordinateSpace)
    }
}

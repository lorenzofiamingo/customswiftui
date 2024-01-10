import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomCoordinateSpaceProtocol where Self == CustomNamedCoordinateSpace {

    /// The named coordinate space that is added by the system for the innermost
    /// containing scroll view that allows scrolling along the provided axis.
    public static func customScrollView(axis: Axis) -> CustomNamedCoordinateSpace {
        switch axis {
        case .horizontal:
            CustomNamedCoordinateSpace(name: CustomScrollViewCoordinateSpaceName.horizontal)
        case .vertical:
            CustomNamedCoordinateSpace(name: CustomScrollViewCoordinateSpaceName.vertical)
        }

    }

    /// The named coordinate space that is added by the system for the innermost
    /// containing scroll view.
    public static var customScrollView: CustomNamedCoordinateSpace {
        CustomNamedCoordinateSpace(name: CustomScrollViewCoordinateSpaceName.all)
    }

    static var customScrollViewContent: CustomNamedCoordinateSpace {
        CustomNamedCoordinateSpace(name: "customScrollViewContent_53G8Y")
    }
}

private enum CustomScrollViewCoordinateSpaceName {
    case all
    case horizontal
    case vertical
}

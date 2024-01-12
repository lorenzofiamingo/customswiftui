import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomScrollTarget: Equatable {
    
    /// The rect that a scrollable view should try and have contained.
    public var rect: CGRect

    /// The anchor to which the rect should be aligned within the visible
    /// region of the scrollable view.
    public var anchor: UnitPoint?

    init(rect: CGRect, anchor: UnitPoint? = nil) {
        self.rect = rect
        self.anchor = anchor
    }

    var anchorPoint: CGPoint {
        CGPoint(
            x: rect.origin.x + (anchor ?? .topLeading).x * rect.size.width,
            y: rect.origin.y + (anchor ?? .topLeading).y * rect.size.height
        )
    }

    func distance(to other: CustomScrollTarget) -> CGFloat {
        hypot(other.anchorPoint.x - anchorPoint.x, other.anchorPoint.y - anchorPoint.y)
    }
}

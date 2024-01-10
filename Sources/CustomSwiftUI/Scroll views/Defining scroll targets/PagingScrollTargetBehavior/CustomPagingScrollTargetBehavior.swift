import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollTargetBehavior where Self == CustomPagingScrollTargetBehavior {
    
    /// The scroll behavior that aligns scroll targets to container-based
    /// geometry.
    ///
    /// In the following example, every view in the lazy stack is flexible
    /// in both directions and the scroll view settles to container-aligned
    /// boundaries.
    ///
    ///     ScrollView {
    ///         LazyVStack(spacing: 0.0) {
    ///             ForEach(items) { item in
    ///                 FullScreenItem(item)
    ///             }
    ///         }
    ///     }
    ///     .scrollTargetBehavior(.paging)
    ///
    public static var paging: CustomPagingScrollTargetBehavior {
        CustomPagingScrollTargetBehavior()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomPagingScrollTargetBehavior: CustomScrollTargetBehavior {

    /// Creates a paging scroll behavior.
    init() {}
    
    /// Updates the proposed target that a scrollable view should scroll to.
    ///
    /// The system calls this method in two main cases:
    /// - When a scroll gesture ends, it calculates where it would naturally
    ///   scroll to using its deceleration rate. The system
    ///   provides this calculated value as the target of this method.
    /// - When a scrollable view's size changes, it calculates where it should
    ///   be scrolled given the new size and provides this calculates value
    ///   as the target of this method.
    ///
    /// You can implement this method to override the calculated target
    /// which will have the scrollable view scroll to a different position
    /// than it would otherwise.
    public func updateTarget(_ target: inout CustomScrollTarget, context: TargetContext) {
        var targetPageIndeces: (x: CGFloat, y: CGFloat)
        if let draggingEndTarget = context.draggingEndTarget {
            targetPageIndeces = calculatePageIndexes(target: target, pageSize: context.containerSize, rule: .toNearestOrAwayFromZero)
            let originPageIndeces = calculatePageIndexes(target: draggingEndTarget, pageSize: context.containerSize, rule: .toNearestOrAwayFromZero)
            if target.rect.origin.x > draggingEndTarget.rect.origin.x, draggingEndTarget.rect.origin.x > 0 {
                if targetPageIndeces.x == originPageIndeces.x {
                    targetPageIndeces.x = originPageIndeces.x+1
                } else {
                    targetPageIndeces.x = min(originPageIndeces.x+1, targetPageIndeces.x)
                }
            }
            if target.rect.origin.x < draggingEndTarget.rect.origin.x, draggingEndTarget.rect.origin.x < context.contentSize.width - context.containerSize.width {
                if targetPageIndeces.x == originPageIndeces.x {
                    targetPageIndeces.x = originPageIndeces.x-1
                } else {
                    targetPageIndeces.x = max(originPageIndeces.x-1, targetPageIndeces.x)
                }
            }
            if target.rect.origin.y > draggingEndTarget.rect.origin.y, draggingEndTarget.rect.origin.y > 0 {
                if targetPageIndeces.y == originPageIndeces.y {
                    targetPageIndeces.y = originPageIndeces.y+1
                } else {
                    targetPageIndeces.y = min(originPageIndeces.y+1, targetPageIndeces.y)
                }
            }
            if target.rect.origin.y < draggingEndTarget.rect.origin.y, draggingEndTarget.rect.origin.y < context.contentSize.height - context.containerSize.height {
                if targetPageIndeces.y == originPageIndeces.y {
                    targetPageIndeces.y = originPageIndeces.y-1
                } else {
                    targetPageIndeces.y = max(originPageIndeces.y-1, targetPageIndeces.y)
                }
            }
        } else {
            targetPageIndeces = calculatePageIndexes(target: target, pageSize: context.containerSize, rule: .down)
        }

        if
            target.rect.origin.x > 0,
            target.rect.origin.x + target.rect.size.width < context.contentSize.width
        {
            target.rect.origin.x = targetPageIndeces.x * context.containerSize.width
        }
        if
            target.rect.origin.y > 0,
            target.rect.origin.y + target.rect.size.height < context.contentSize.height
        {
            target.rect.origin.y = targetPageIndeces.y * context.containerSize.height
        }
    }

    private func calculatePageIndexes(target: CustomScrollTarget, pageSize: CGSize, rule: FloatingPointRoundingRule) -> (x: CGFloat, y: CGFloat) {
        (
            x: (target.rect.origin.x / pageSize.width).rounded(rule),
            y: (target.rect.origin.y / pageSize.height).rounded(rule)
        )
    }
}

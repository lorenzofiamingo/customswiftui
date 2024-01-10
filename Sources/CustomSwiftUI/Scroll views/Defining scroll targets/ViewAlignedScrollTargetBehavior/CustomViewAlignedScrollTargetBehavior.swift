import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollTargetBehavior where Self == CustomViewAlignedScrollTargetBehavior {

    public static var viewAligned: CustomViewAlignedScrollTargetBehavior {
        CustomViewAlignedScrollTargetBehavior(limitBehavior: .automatic)
    }

    public static func viewAligned(limitBehavior: CustomViewAlignedScrollTargetBehavior.LimitBehavior) -> CustomViewAlignedScrollTargetBehavior {
        CustomViewAlignedScrollTargetBehavior(limitBehavior: limitBehavior)
    }
}

/// The scroll behavior that aligns scroll targets to view-based geometry.
///
/// You use this behavior when a scroll view should always align its
/// scroll targets to a rectangle that's aligned to the geometry of a view. In
/// the following example, the scroll view always picks an item view
/// to settle on.
///
///     CustomScrollView(.horizontal) {
///         LazyHStack(spacing: 10.0) {
///             ForEach(items) { item in
///               ItemView(item)
///             }
///         }
///         .scrollTargetLayout()
///     }
///     .customScrollTargetBehavior(.viewAligned)
///     .padding(.horizontal, 20.0)
///
/// You configure which views should be used for settling using the
/// ``View/scrollTargetLayout(isEnabled:)`` modifier. Apply this modifier to a
/// layout container like ``LazyVStack`` or ``HStack`` and each individual
/// view in that layout will be considered for alignment.
///
/// You can customize whether the view aligned behavior limits the
/// number of views that can be scrolled at a time by using the
/// ``ViewAlignedScrollTargetBehavior/LimitBehavior`` type. Provide a value of
/// ``ViewAlignedScrollTargetBehavior/LimitBehavior/always`` to always have
/// the behavior only allow a few views to be scrolled at a time.
///
/// By default, the view aligned behavior will limit the number of views
/// it scrolls when in a compact horizontal size class when scrollable
/// in the horizontal axis, when in a compact vertical size class when
/// scrollable in the vertical axis, and otherwise does not impose any
/// limit on the number of views that can be scrolled.
///
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomViewAlignedScrollTargetBehavior: CustomScrollTargetBehavior {

    /// A type that defines the amount of views that can be scrolled at a time.
    public struct LimitBehavior {
        
        var role: Role

        init(role: Role) {
            self.role = role
        }

        enum Role {
            case automatic
            case always
            case never
        }

        /// The automatic limit behavior.
        ///
        /// By default, the behavior will be limited in compact horizontal
        /// size classes and will not be limited otherwise.
        public static var automatic: LimitBehavior {
            LimitBehavior(role: .automatic)
        }

        /// The always limit behavior.
        ///
        /// Always limit the amount of views that can be scrolled.
        public static var always: LimitBehavior {
            LimitBehavior(role: .always)
        }

        /// The never limit behavior.
        ///
        /// Never limit the amount of views that can be scrolled.
        public static var never: LimitBehavior {
            LimitBehavior(role: .never)
        }
    }

    var limitBehavior: LimitBehavior

    /// Creates a view aligned scroll behavior.
    public init(limitBehavior: CustomViewAlignedScrollTargetBehavior.LimitBehavior = .automatic) {
        self.limitBehavior = limitBehavior
    }

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
        guard let targetCoordinator = context.customScrollEnvironmentProperties.targetCoordinator else { return }
        let targetClosestScrollTargets = targetCoordinator.closestScrollTargets(to: target)

        if var viewAlignedTarget = targetClosestScrollTargets.center {
            if
                let draggingEndTarget = context.draggingEndTarget,
                let viewAlignedOriginTarget = targetCoordinator.closestScrollTargets(to: context.originalTarget).center
            {
                var closestTargetAlignment: (horizontal: HorizontalAlignment, vertical: VerticalAlignment) = (.center, .center)

                if
                    target.rect.origin.x > draggingEndTarget.rect.origin.x,
                    draggingEndTarget.rect.origin.x > 0,
                    viewAlignedTarget == viewAlignedOriginTarget
                {
                    closestTargetAlignment.horizontal = .trailing
                }
                if
                    target.rect.origin.x < draggingEndTarget.rect.origin.x,
                    draggingEndTarget.rect.origin.x < context.contentSize.width - context.containerSize.width,
                    viewAlignedTarget == viewAlignedOriginTarget
                {
                    closestTargetAlignment.horizontal = .leading
                }

                if
                    target.rect.origin.y > draggingEndTarget.rect.origin.y,
                    draggingEndTarget.rect.origin.y > 0,
                    viewAlignedTarget == viewAlignedOriginTarget
                {
                    closestTargetAlignment.vertical = .bottom
                }
                if
                    target.rect.origin.y < draggingEndTarget.rect.origin.y,
                    draggingEndTarget.rect.origin.y < context.contentSize.height - context.containerSize.height,
                    viewAlignedTarget == viewAlignedOriginTarget
                {
                    closestTargetAlignment.vertical = .top
                }

                let alignment = Alignment(horizontal: closestTargetAlignment.horizontal, vertical: closestTargetAlignment.vertical)
                viewAlignedTarget = targetClosestScrollTargets[alignment] ?? viewAlignedTarget
            }

            if
                target.rect.origin.x > 0,
                target.rect.origin.x + target.rect.size.width < context.contentSize.width
            {
                target.rect.origin.x = viewAlignedTarget.rect.origin.x
                target.rect.size.width = viewAlignedTarget.rect.size.width
                if let x = viewAlignedTarget.anchor?.x {
                    target.anchor?.x = x
                }
            }
            if
                target.rect.origin.y > 0,
                target.rect.origin.y + target.rect.size.height < context.contentSize.height
            {
                target.rect.origin.y = viewAlignedTarget.rect.origin.y
                target.rect.size.height = viewAlignedTarget.rect.size.height
                if let y = viewAlignedTarget.anchor?.y {
                    target.anchor?.y = y
                }
            }
        }
    }
}

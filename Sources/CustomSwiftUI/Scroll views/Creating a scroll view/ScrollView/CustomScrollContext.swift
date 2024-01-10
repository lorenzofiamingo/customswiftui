import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomScrollEnvironmentPropertiesKey: EnvironmentKey {

    static var defaultValue: CustomScrollEnvironmentProperties {
        CustomScrollEnvironmentProperties()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    
    var customScrollEnvironmentProperties: CustomScrollEnvironmentProperties {
        get { self[CustomScrollEnvironmentPropertiesKey.self] }
        set { self[CustomScrollEnvironmentPropertiesKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomScrollEnvironmentProperties {
    var targetCoordinator: CustomTargetCoordinator?
    var isEnabled: Bool = true
    var isClippingEnabled: Bool = true
    var defaultAnchor: UnitPoint?
    var contentMargins: EdgeInsets {
        get {
            boxA.wrappedValue
        } set {
            boxA.wrappedValue = newValue
        }
    }
    var indicatorsMargins: EdgeInsets {
        get {
            boxB.wrappedValue
        } set {
            boxB.wrappedValue = newValue
        }
    }

    var vertical = AxisStorage()
    var horizontal = AxisStorage()

    var indicatorsFlashSeed: UInt32 = 0

    struct AxisStorage {
        var indicator = CustomScrollIndicatorConfiguration()
        var bounceBehavior: CustomScrollBounceBehavior = .automatic
    }

    private var boxA = Box(wrappedValue: EdgeInsets())
    private var boxB = Box(wrappedValue: EdgeInsets())
    @propertyWrapper
    private class Box<V> {
        var wrappedValue: V

        init(wrappedValue: V) {
            self.wrappedValue = wrappedValue
        }
    }
}

struct CustomScrollIndicatorConfiguration {
    var visibility: CustomScrollIndicatorVisibility = .automatic
    var style: CustomScrollIndicatorStyle = .automatic
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class CustomTargetCoordinator {

    var positionIDObjectIdentifier: ObjectIdentifier?

    var positionID: AnyHashable?

    var onPositionIDFromScroll: ((AnyHashable?) -> Void)?

    var onPositionIDFromValue: ((AnyHashable?, Transaction) -> Void)?

    var anchor: UnitPoint?

    var targetGeometries: [UUID: GeometryProxy] = [:]

    var targetIDs: [UUID: AnyHashable] = [:]

    func closestTargetID(to target: CustomScrollTarget) -> AnyHashable? {
        let origin = target.rect.origin
        let anchor = target.anchor ?? .topLeading
        let size = target.rect.size

        let contentAnchorPoint = CGPoint(
            x: origin.x+anchor.x*size.width,
            y: origin.y+anchor.y*size.height
        )

        let closestTargetID = targetIDs
            .compactMap { namespace, id in
                targetGeometries[namespace].map { (id, $0) }
            }
            .map { id, geometry in
                (id, geometry.frame(in: .customScrollViewContent))
            }
            .map { id, frame in
                let targetAnchorPoint = CGPoint(
                    x: frame.origin.x+anchor.x*frame.width,
                    y: frame.origin.y+anchor.y*frame.height
                )
                let distance: CGFloat = hypot(targetAnchorPoint.x-contentAnchorPoint.x, targetAnchorPoint.y-contentAnchorPoint.y)
                return (id: id, distance: distance)
            }
            .sorted { $0.distance < $1.distance }
            .first
            .map(\.id)

        return closestTargetID
    }

    struct ClosestTargets {
        var topLeading: CustomScrollTarget?
        var top: CustomScrollTarget?
        var topTrailing: CustomScrollTarget?
        var leading: CustomScrollTarget?
        var center: CustomScrollTarget?
        var trailing: CustomScrollTarget?
        var bottomLeading: CustomScrollTarget?
        var bottom: CustomScrollTarget?
        var bottomTrailing: CustomScrollTarget?

        subscript(alignment: Alignment) -> CustomScrollTarget? {
            switch alignment {
            case .topLeading:
                return topLeading
            case .top:
                return top
            case .topTrailing:
                return topTrailing
            case .leading:
                return leading
            case .center:
                return center
            case .trailing:
                return trailing
            case .bottomLeading:
                return bottomLeading
            case .bottom:
                return bottom
            case .bottomTrailing:
                return bottomTrailing
            default:
                return nil
            }
        }
    }

    /// closest scroll target at `[1][1]`.
    func closestScrollTargets(to target: CustomScrollTarget) -> ClosestTargets {
        var closestTargets = targetGeometries.values
            .map { geometry in
                CustomScrollTarget(rect: geometry.frame(in: .customScrollViewContent))
            }
            .map { scrollTarget in
                (target: scrollTarget, distance: scrollTarget.distance(to: target))
            }
            .sorted { $0.distance < $1.distance }
            .map(\.target)

        if let closestTarget = closestTargets.first {
            closestTargets.removeFirst()

            return ClosestTargets(
                topLeading: closestTargets.first { $0.anchorPoint.y < closestTarget.anchorPoint.y && $0.anchorPoint.x < closestTarget.anchorPoint.x },
                top: closestTargets.first { $0.anchorPoint.y < closestTarget.anchorPoint.y },
                topTrailing: closestTargets.first { $0.anchorPoint.y < closestTarget.anchorPoint.y && $0.anchorPoint.x > closestTarget.anchorPoint.x },
                leading: closestTargets.first { $0.anchorPoint.x < closestTarget.anchorPoint.x },
                center: closestTarget,
                trailing: closestTargets.first { $0.anchorPoint.x > closestTarget.anchorPoint.x },
                bottomLeading: closestTargets.first { $0.anchorPoint.y > closestTarget.anchorPoint.y && $0.anchorPoint.x < closestTarget.anchorPoint.x },
                bottom: closestTargets.first { $0.anchorPoint.y > closestTarget.anchorPoint.y },
                bottomTrailing: closestTargets.first { $0.anchorPoint.y > closestTarget.anchorPoint.y && $0.anchorPoint.x > closestTarget.anchorPoint.x }
            )
        }

        return ClosestTargets()
    }
}


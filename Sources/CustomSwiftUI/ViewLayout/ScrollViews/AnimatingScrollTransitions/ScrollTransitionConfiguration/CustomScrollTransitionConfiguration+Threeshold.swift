import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollTransitionConfiguration {

    /// Describes a specific point in the progression of a target view within a container
    /// from hidden (fully outside the container) to visible.
    public struct Threshold {

        let storage: Storage

        enum Storage {
            case center
            case visibility(_ amount: CGFloat)
            indirect case inset(Double, Storage)
            indirect case mix(from: Storage, to: Storage, amount: Double)
        }

        /// Thresholds for contentFrame offset (aka origin). (0, 0) is at center of container. and origin of content is at  its center also.
        /// Threshold is positive for bottomTrailing (reversed for topLeading).
        func contentOffset(container: CGFloat, content: CGFloat) -> CGFloat  {
            func calculate(container: CGFloat, content: CGFloat, storage: Storage) -> CGFloat {
                switch storage {
                case .center:
                    return 0
                case .visibility(let amount):
                    let threshold = (container - content * (2 * amount - 1)) / 2
                    return threshold
                case .inset(let distance, let storage):
                    let partial = calculate(container: container, content: content, storage: storage)
                    return max(partial - distance, 0)
                case .mix(let from, let to, let amount):
                    let fromPartial = calculate(container: container, content: content, storage: from)
                    let toPartial = calculate(container: container, content: content, storage: to)
                    return fromPartial + (toPartial - fromPartial) * amount
                }
            }
            return calculate(container: container, content: content, storage: storage)
        }

        public static let visible: CustomScrollTransitionConfiguration.Threshold = .visible(1)

        /// The target view is centered within the container
        public static let hidden: CustomScrollTransitionConfiguration.Threshold = .visible(0)

        /// The target view is centered within the container
        static var centered: CustomScrollTransitionConfiguration.Threshold {
            CustomScrollTransitionConfiguration.Threshold(storage: .center)
        }

        /// The target view is visible by the given amount, where zero is fully
        /// hidden, and one is fully visible.
        ///
        /// Values less than zero or greater than one are clamped.
        public static func visible(_ amount: Double) -> CustomScrollTransitionConfiguration.Threshold {
            CustomScrollTransitionConfiguration.Threshold(storage: .visibility(amount))
        }

        /// Creates a new threshold that combines this threshold value with
        /// another threshold, interpolated by the given amount.
        ///
        /// - Parameters:
        ///   - other: The second threshold value.
        ///   - amount: The ratio with which this threshold is combined with
        ///     the given threshold, where zero is equal to this threshold,
        ///     1.0 is equal to `other`, and values in between combine the two
        ///     thresholds.
        public func interpolated(
            towards other: CustomScrollTransitionConfiguration.Threshold,
            amount: Double
        ) -> CustomScrollTransitionConfiguration.Threshold {
            CustomScrollTransitionConfiguration.Threshold(storage: .mix(from: storage, to: other.storage, amount: amount))
        }

        /// Returns a threshold that is met when the target view is closer to the
        /// center of the container by `distance`. Use negative values to move
        /// the threshold away from the center.
        public func inset(by distance: Double) -> CustomScrollTransitionConfiguration.Threshold {
            CustomScrollTransitionConfiguration.Threshold(storage: .inset(distance, storage))
        }

    }
}

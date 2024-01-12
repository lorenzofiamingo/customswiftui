import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    /// The scroll bounce mode for the horizontal axis of scrollable views.
    ///
    /// Use the ``View/customScrollBounceBehavior(_:axes:)`` view modifier to
    /// set this value in the ``Environment``.
    public var customHorizontalScrollBounceBehavior: CustomScrollBounceBehavior {
        get { customScrollEnvironmentProperties.horizontal.bounceBehavior }
        set { customScrollEnvironmentProperties.horizontal.bounceBehavior = newValue }
    }
}

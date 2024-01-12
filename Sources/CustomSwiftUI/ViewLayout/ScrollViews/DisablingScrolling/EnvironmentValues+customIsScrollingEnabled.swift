import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    /// A Boolean value that indicates whether any scroll views associated
    /// with this environment allow scrolling to occur.
    ///
    /// The default value is `true`. Use the ``View/customScrollDisabled(_:)``
    /// modifier to configure this property.
    public var customIsScrollEnabled: Bool {
        get { self.customScrollEnvironmentProperties.isEnabled }
        set { self.customScrollEnvironmentProperties.isEnabled = newValue }
    }
}


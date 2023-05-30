import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets the tint color within this view.
    ///
    /// Use this method to override the default accent color for this view.
    /// Unlike an app's accent color, which can be overridden by user
    /// preference, the tint color is always respected and should be used as a
    /// way to provide additional meaning to the control.
    ///
    /// This example shows Answer and Decline buttons with ``ShapeStyle/green``
    /// and ``ShapeStyle/red`` tint colors, respectively.
    ///
    ///     struct ControlTint: View {
    ///         var body: some View {
    ///             HStack {
    ///                 Button {
    ///                     // Answer the call
    ///                 } label: {
    ///                     Label("Answer", systemImage: "phone")
    ///                 }
    ///                 .tint(.green)
    ///                 Button {
    ///                     // Decline the call
    ///                 } label: {
    ///                     Label("Decline", systemImage: "phone.down")
    ///                 }
    ///                 .tint(.red)
    ///             }
    ///             .padding()
    ///         }
    ///     }
    ///
    /// - Parameter tint: The tint `Color` to apply.
    public func customTint(_ tint: Color?) -> some View {
        environment(\.customTint, tint)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomTintEnvironmentKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    /// The tint to apply to controls within a view.
    public var customTint: Color? {
        get { self[CustomTintEnvironmentKey.self] }
        set { self[CustomTintEnvironmentKey.self] = newValue }
    }
}

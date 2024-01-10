import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Flashes the scroll indicators of scrollable views when a value changes.
    ///
    /// When the value that you provide to this modifier changes, the scroll
    /// indicators of any scrollable views within the modified view hierarchy
    /// briefly flash. The following example configures the scroll indicators
    /// to flash any time `flashCount` changes:
    ///
    ///     @State private var isPresented = false
    ///     @State private var flashCount = 0
    ///
    ///     CustomScrollView {
    ///         // ...
    ///     }
    ///     .customScrollIndicatorsFlash(trigger: flashCount)
    ///     .sheet(isPresented: $isPresented) {
    ///         // ...
    ///     }
    ///     .onChange(of: isPresented) { newValue in
    ///         if newValue {
    ///             flashCount += 1
    ///         }
    ///     }
    ///
    /// Only scroll indicators that you configure to be visible flash.
    /// To flash scroll indicators when a scroll view initially appears,
    /// use ``View/scrollIndicatorsFlash(onAppear:)`` instead.
    ///
    /// - Parameter value: The value that causes scroll indicators to flash.
    ///   The value must conform to the
    ///   <doc://com.apple.documentation/documentation/Swift/Equatable>
    ///   protocol.
    ///
    /// - Returns: A view that flashes any visible scroll indicators when a
    ///   value changes.
    public func customScrollIndicatorsFlash(trigger value: some Equatable) -> some View {
        modifier(CustomScrollIndicatorsFlashModifier(value: value))
    }

    /// Flashes the scroll indicators of a scrollable view when it appears.
    ///
    /// Use this modifier to control whether the scroll indicators of a scroll
    /// view briefly flash when the view first appears. For example, you can
    /// make the indicators flash by setting the `onAppear` parameter to `true`:
    ///
    ///     ScrollView {
    ///         // ...
    ///     }
    ///     .scrollIndicatorsFlash(onAppear: true)
    ///
    /// Only scroll indicators that you configure to be visible flash.
    /// To flash scroll indicators when a value changes, use
    /// ``View/scrollIndicatorsFlash(trigger:)`` instead.
    ///
    /// - Parameter onAppear: A Boolean value that indicates whether the scroll
    ///   indicators flash when the scroll view appears.
    ///
    /// - Returns: A view that flashes any visible scroll indicators when it
    ///   first appears.
    public func customScrollIndicatorsFlash(onAppear: Bool) -> some View {
        modifier(CustomScrollIndicatorsFlashOnAppearModifier(isEnabled: onAppear))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomScrollIndicatorsFlashModifier<V: Equatable>: ViewModifier {

    var value: V

    @State var coordinator: Coordinator

    init(value: V) {
        self.value =  value
        self._coordinator = State(wrappedValue: Coordinator(value: value))
    }

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
                if coordinator.value != value {
                    coordinator.value = value
                    scrollEnvironmentProperties.indicatorsFlashSeed = arc4random()
                }
            }
    }

    class Coordinator {

        var value: V?

        init(value: V? = nil) {
            self.value = value
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomScrollIndicatorsFlashOnAppearModifier: ViewModifier {

    var isEnabled: Bool

    @State private var coordinator = Coordinator()

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.customScrollEnvironmentProperties) { scrollEnvironmentProperties in
                if !coordinator.isAppeared {
                    coordinator.isAppeared = true
                    if isEnabled {
                        scrollEnvironmentProperties.indicatorsFlashSeed = arc4random()
                    }
                }
            }
            .onDisappear {
                coordinator.isAppeared = true
            }
    }

    class Coordinator {
        var isAppeared = false
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Configures the outermost layout as a scroll target.
    public func customScrollTarget(isEnabled: Bool = true) -> some View {
        modifier(CustomScrollTargetViewModifier(isEnabled: isEnabled))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomScrollTargetViewModifier: ViewModifier {

    var isEnabled: Bool

    @State private var ids: [ObjectIdentifier: AnyHashable] = [:]

    @State private var namespace = UUID()

    @Environment(\.customScrollEnvironmentProperties) private var properties

    func body(content: Content) -> some View {
        content
            .environment(\.customScrollTargetRole, .target)
            .onPreferenceChange(CustomIDValuesKey.self) { values in // After background doesn't work (swiftui bug)
                properties.targetCoordinator?.targetIDs[namespace] = properties.targetCoordinator?.positionIDObjectIdentifier.flatMap { values.ids[$0] }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .customOnChange(of: isEnabled, initial: true) {
                            properties.targetCoordinator?.targetGeometries[namespace] = isEnabled ? geometry : nil
                        }
                }
            )
            .onDisappear {
                properties.targetCoordinator?.targetGeometries[namespace] = nil
                properties.targetCoordinator?.targetIDs[namespace] = nil
            }
    }
}

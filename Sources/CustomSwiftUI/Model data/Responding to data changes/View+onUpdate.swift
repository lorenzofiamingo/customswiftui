import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onUpdate(of values: Any?..., action: @escaping (EnvironmentValues, Transaction) -> Void) -> some View {
        onUpdate(of: values, action: { action($1, $2) })
    }

    func onUpdate(of values: Any?..., action: @escaping (UIView, EnvironmentValues, Transaction) -> Void) -> some View {
        background(OnUpdateView(values: values, onUpdate: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OnUpdateView: UIViewRepresentable {

    private let onUpdate: (UIView, EnvironmentValues, Transaction) -> Void

    //In ios17 updateUIView is called
    private let values: Any

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        onUpdate(uiView, context.environment, context.transaction)
    }

    init(values: Any, onUpdate: @escaping (UIView, EnvironmentValues, Transaction) -> Void) {
        self.onUpdate = onUpdate
        self.values = values
    }
}

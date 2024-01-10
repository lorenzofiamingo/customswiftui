import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onMake(_ action: @escaping (EnvironmentValues, Transaction) -> Void) -> some View {
        onMake({ action($1, $2) })
    }

    func onMake(_ action: @escaping (UIView, EnvironmentValues, Transaction) -> Void) -> some View {
        background(OnMakeView(onMake: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OnMakeView: UIViewRepresentable {

    private let onMake: (UIView, EnvironmentValues, Transaction) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        onMake(view, context.environment, context.transaction)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    init(onMake: @escaping (UIView, EnvironmentValues, Transaction) -> Void) {
        self.onMake = onMake
    }
}

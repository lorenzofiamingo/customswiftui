import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onLayout(action: @escaping (UIView) -> Void) -> some View {
        background(OnLayoutView(onLayout: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OnLayoutView: UIViewRepresentable {

    private let onLayout: (UIView) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = LayoutView()
        view.didLayoutSubviewsAction = { onLayout(view) }
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    init(onLayout: @escaping (UIView) -> Void) {
        self.onLayout = onLayout
    }

    class LayoutView: UIView {

        var didLayoutSubviewsAction: (() -> Void)?

        override func layoutSubviews() {
            super.layoutSubviews()
            didLayoutSubviewsAction?()
        }
    }
}

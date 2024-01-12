import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Applies effects to this view, while providing access to layout
    /// information through a geometry proxy.
    ///
    /// You return new effects by calling functions on the first argument
    /// provided to the `effect` closure. In this example, `ContentView` is
    /// offset by its own size, causing its top left corner to appear where the
    /// bottom right corner was originally located:
    /// ```swift
    /// ContentView()
    ///     .customVisualEffect { content, geometryProxy in
    ///         content.offset(geometryProxy.size)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - effect: A closure that returns the effect to be applied. The first
    ///     argument provided to the closure is a placeholder representing
    ///     this view. The second argument is a `GeometryProxy`.
    /// - Returns: A view with the effect applied.
    func customVisualEffect(_ effect: @escaping (CustomEmptyVisualEffect, GeometryProxy) -> some CustomVisualEffect) -> some View {
        modifier(CustomVisualEffectModifier(effect: effect))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomVisualEffectModifier<Effect: CustomVisualEffect>: ViewModifier {

    private let effect: (CustomEmptyVisualEffect, GeometryProxy) -> Effect

    @State private var visualEffect: Effect?

    init(effect: @escaping (CustomEmptyVisualEffect, GeometryProxy) -> Effect) {
        self.effect = effect
    }

    func body(content: Content) -> some View {
        content
            .modifier(Effect._makeModifier(effect: visualEffect))
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onUpdate(of: geometry) { _, transaction in
                            let effect = effect(CustomEmptyVisualEffect(), geometry)
                            DispatchQueue.main.async {
                                withTransaction(transaction) {
                                    visualEffect = effect
                                }
                            }
                        }
                }
            )
    }
}

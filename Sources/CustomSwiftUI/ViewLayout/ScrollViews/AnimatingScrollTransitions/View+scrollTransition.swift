import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Applies the given transition, animating between the phases
    /// of the transition as this view appears and disappears within the
    /// visible region of the containing scroll view, or other container
    /// specified using the `coordinateSpace` parameter.
    ///
    /// - Parameters:
    ///   - configuration: The configuration controlling how the
    ///     transition will be applied. The configuration will be applied both
    ///     while the view is coming into view and while it is disappearing (the
    ///     transition is symmetrical).
    ///   - axis: The axis of the containing scroll view over which the
    ///     transition will be applied. The default value of `nil` uses the
    ///     axis of the innermost containing scroll view, or `.vertical` if
    ///     the innermost scroll view is scrollable along both axes.
    ///   - coordinateSpace: The coordinate space of the container that
    ///     visibility is evaluated within. Defaults to `.scrollView`.
    ///   - transition: A closure that applies visual effects as a function of
    ///     the provided phase.
    public func customScrollTransition(
        _ configuration: CustomScrollTransitionConfiguration = .interactive,
        axis: Axis? = nil,
        transition: @escaping (CustomEmptyVisualEffect, CustomScrollTransitionPhase) -> some CustomVisualEffect
    ) -> some View {
        modifier(CustomScrollTransitionModifier(transition: transition, topLeading: configuration, bottomTrailing: configuration, axis: axis))
    }

    /// Applies the given transition, animating between the phases
    /// of the transition as this view appears and disappears within the
    /// visible region of the containing scroll view, or other container
    /// specified using the `coordinateSpace` parameter.
    ///
    /// - Parameters:
    ///   - transition: the transition to apply.
    ///   - topLeading: The configuration that drives the transition when
    ///     the view is about to appear at the top edge of a vertical
    ///     scroll view, or the leading edge of a horizont scroll view.
    ///   - bottomTrailing: The configuration that drives the transition when
    ///     the view is about to appear at the bottom edge of a vertical
    ///     scroll view, or the trailing edge of a horizont scroll view.
    ///   - axis: The axis of the containing scroll view over which the
    ///     transition will be applied. The default value of `nil` uses the
    ///     axis of the innermost containing scroll view, or `.vertical` if
    ///     the innermost scroll view is scrollable along both axes.
    ///   - transition: A closure that applies visual effects as a function of
    ///     the provided phase.
    public func customScrollTransition(
        topLeading: CustomScrollTransitionConfiguration,
        bottomTrailing: CustomScrollTransitionConfiguration,
        axis: Axis? = nil,
        transition: @escaping (CustomEmptyVisualEffect, CustomScrollTransitionPhase) -> some CustomVisualEffect
    ) -> some View {
        modifier(CustomScrollTransitionModifier(transition: transition, topLeading: topLeading, bottomTrailing: bottomTrailing, axis: axis))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomScrollTransitionModifier<Effect: CustomVisualEffect>: ViewModifier {

    let transition: (CustomEmptyVisualEffect, CustomScrollTransitionPhase) -> Effect

    let topLeading: CustomScrollTransitionConfiguration

    let bottomTrailing: CustomScrollTransitionConfiguration

    var axis: Axis?

    @Environment(\.customContainerSize) private var containerSize

    @Environment(\.customScrollViewConfiguration) private var scrollViewConfiguration

    @State private var topLeadingEffect: Effect

    @State private var bottomTrailingEffect: Effect

    @State private var id = UUID()

    init(transition: @escaping (CustomEmptyVisualEffect, CustomScrollTransitionPhase) -> Effect, topLeading: CustomScrollTransitionConfiguration, bottomTrailing: CustomScrollTransitionConfiguration, axis: Axis?) {
        self.transition = transition
        self.topLeading = topLeading
        self.bottomTrailing = bottomTrailing
        self.axis = axis
        self._topLeadingEffect = State(wrappedValue: transition(CustomEmptyVisualEffect(), .identity))
        self._bottomTrailingEffect = State(wrappedValue: transition(CustomEmptyVisualEffect(), .identity))
    }

    func body(content: Content) -> some View {
        content
            .modifier(Effect._makeModifier(effect: topLeadingEffect))
            .modifier(Effect._makeModifier(effect: bottomTrailingEffect))
            .onUpdate(of: nil) { view, _, _ in
                scrollViewConfiguration?.scrollCoordinator.onScroll[id] = {
                    Task { @MainActor in
                        guard let effects = generateEffects(in: view) else {
                            return
                        }

                        withAnimation(topLeading.animation) {
                            self.topLeadingEffect = effects.topLeading
                        }
                        withAnimation(bottomTrailing.animation) {
                            self.bottomTrailingEffect = effects.bottomTrailing
                        }
                    }
                }
            }
    }

    func generateEffects(in view: UIView) -> (topLeading: Effect, bottomTrailing: Effect)? {
        guard let containerSize else { return nil }
        guard let coordinator = scrollViewConfiguration?.scrollCoordinator else { return nil }
        guard let uiScrollView = coordinator.uiScrollView else { return nil }

        let initialContentOrigin = view.convert(view.frame.origin, to: uiScrollView.coordinateSpace)
        let contentFrame = CGRect(
            x: initialContentOrigin.x - coordinator.contentMargins.leading - uiScrollView.contentOffset.x,
            y: initialContentOrigin.y - coordinator.contentMargins.top - uiScrollView.contentOffset.y,
            width: view.bounds.width,
            height: view.bounds.height
        )

        let axis = axis ?? (scrollViewConfiguration?.axes == .horizontal ? .horizontal : .vertical)

        let containerLength: CGFloat
        let contentLength: CGFloat
        let contentOrigin: CGFloat

        switch axis {
        case .horizontal:
            containerLength = containerSize.width
            contentLength = contentFrame.size.width
            contentOrigin = contentFrame.origin.x
         case .vertical:
            containerLength = containerSize.height
            contentLength = contentFrame.size.height
            contentOrigin = contentFrame.origin.y
        }

        // From center of container
        let topLeadingContentTreshold = topLeading.threshold.contentOffset(container: containerLength, content: contentLength)
        let bottomTrailingContentTreshold = bottomTrailing.threshold.contentOffset(container: containerLength, content: contentLength)
        let contentOffset = contentOrigin + ((contentLength - containerLength) / 2)
        let hiddenContentTreshold = CustomScrollTransitionConfiguration.Threshold.hidden.contentOffset(container: containerLength, content: contentLength)


//        let isTopLeadingTransitioning = contentOffset < -topLeadingContentTreshold
//        let isBottomTrailingTransitioning = contentOffset > bottomTrailingContentTreshold
        //guard isTopLeadingTransitioning || isBottomTrailingTransitioning else { return } // TODO: if you want to do this check, you'll have to check if last transition was done right on 1

        let identityEffect = transition(CustomEmptyVisualEffect(), .identity)
        var topLeadingEffect = transition(CustomEmptyVisualEffect(), .topLeading)
        var bottomTrailingEffect = transition(CustomEmptyVisualEffect(), .bottomTrailing)

        let topLeadingInterpolationAmount: CGFloat
        switch topLeading.mode {
        case .identity:
            topLeadingInterpolationAmount = 1
        case .interactive(timingCurve: let timingCurve, animation: _):
            let unlerped = unlerp(amount: contentOffset, from: -hiddenContentTreshold, towards: -topLeadingContentTreshold)
            topLeadingInterpolationAmount = timingCurve.value(at: unlerped)
        case .animated:
            topLeadingInterpolationAmount = contentOffset < -topLeadingContentTreshold ? 0 : 1
        }
        topLeadingEffect.animatableData.interpolate(towards: identityEffect.animatableData, amount: topLeadingInterpolationAmount)

        let bottomTrailingInterpolationAmount: CGFloat
        switch bottomTrailing.mode {
        case .identity:
            bottomTrailingInterpolationAmount = 1
        case .interactive(timingCurve: let timingCurve, animation: _):
            let unlerped = unlerp(amount: contentOffset, from: hiddenContentTreshold, towards: bottomTrailingContentTreshold)
            bottomTrailingInterpolationAmount = timingCurve.value(at: unlerped)
        case .animated:
            bottomTrailingInterpolationAmount = contentOffset > bottomTrailingContentTreshold ? 0 : 1
        }
        bottomTrailingEffect.animatableData.interpolate(towards: identityEffect.animatableData, amount: bottomTrailingInterpolationAmount)

        return (topLeadingEffect, bottomTrailingEffect)
    }
}

private func unlerp<V: BinaryFloatingPoint>(amount: V, from: V, towards: V) -> V {
    let value = (amount - from) / (towards - from)
    return max(0, min(value, 1))
}

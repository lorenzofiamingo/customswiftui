import SwiftUI

/// A scrollable view.
///
/// The scroll view displays its content within the scrollable content region.
/// As the user performs platform-appropriate scroll gestures, the scroll view
/// adjusts what portion of the underlying content is visible. `ScrollView` can
/// scroll horizontally, vertically, or both, but does not provide zooming
/// functionality.
///
/// In the following example, a `ScrollView` allows the user to scroll through
/// a ``VStack`` containing 100 ``Text`` views. The image after the listing
/// shows the scroll view's temporarily visible scrollbar at the right; you can
/// disable it with the `showsIndicators` parameter of the `ScrollView`
/// initializer.
///
///     var body: some View {
///         ScrollView {
///             VStack(alignment: .leading) {
///                 ForEach(0..<100) {
///                     Text("Row \($0)")
///                 }
///             }
///         }
///     }
/// ![A scroll view with a series of vertically arranged rows, reading
/// Row 1, Row 2, and so on. At the right, a scrollbar indicates that
/// this is the top of the scrollable
/// area.](SwiftUI-ScrollView-rows-with-indicator.png)
///
/// ### Controlling Scroll Position
///
/// You can influence where a scroll view is initially scrolled
/// by using the ``View/defaultScrollAnchor(_:)`` view modifier.
///
/// Provide a value of `UnitPoint/center`` to have the scroll
/// view start in the center of its content when a scroll view
/// is scrollable in both axes.
///
///     ScrollView([.horizontal, .vertical]) {
///         // initially centered content
///     }
///     .defaultScrollAnchor(.center)
///
/// Or provide an alignment of `UnitPoint/bottom`` to have the
/// scroll view start at the bottom of its content when a scroll
/// view is scrollable in its vertical axes.
///
///     ScrollView {
///         // initially bottom aligned content
///     }
///     .defaultScrollAnchor(.bottom)
///
/// After the scroll view initially renders, the user may scroll
/// the content of the scroll view.
///
/// To perform programmatic scrolling, wrap one or more scroll views with a
/// ``ScrollViewReader``.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomScrollView<Content: View>: View {

    private let configuration: CustomScrollViewConfiguration

    /// The scroll view's content.
    public var content: Content

    /// The scrollable axes of the scroll view.
    ///
    /// The default value is ``Axis/vertical``.
    public var axes: Axis.Set {
        configuration.axes
    }

    /// A value that indicates whether the scroll view displays the scrollable
    /// component of the content offset, in a way that's suitable for the
    /// platform.
    ///
    /// The default is `true`.
    public var showsIndicators: Bool {
        configuration.scrollCoordinator.uiScrollView?.showsVerticalScrollIndicator ?? true &&
        configuration.scrollCoordinator.uiScrollView?.showsHorizontalScrollIndicator ?? true
    }

    @State private var targetCooordinator = CustomTargetCoordinator()

    var axisArray: [Axis] {
        var array: [Axis] = []
        for axis in Axis.allCases {
            switch axis {
            case .horizontal where axes.contains(.horizontal):
                array.append(.horizontal)
            case .vertical where axes.contains(.vertical):
                array.append(.vertical)
            default:
                break
            }
        }
        return array
    }

    public var body: some View {
        Representable(self)
            .environment(\.customScrollViewConfiguration, configuration)
            .transformEnvironment(\.customScrollEnvironmentProperties) { properties in
                if properties.targetCoordinator == nil {
                    properties.targetCoordinator = targetCooordinator
                }
            }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollView {

    /// Creates a new instance that's scrollable in the direction of the given
    /// axis and can show indicators while scrolling.
    ///
    /// - Parameters:
    ///   - axes: The scroll view's scrollable axis. The default axis is the
    ///     vertical axis.
    ///   - content: The view builder that creates the scrollable view.
    public init(_ axes: Axis.Set = .vertical, @ViewBuilder content: () -> Content) {
        self.configuration = CustomScrollViewConfiguration(axes: axes)
        self.content = content()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollView {

    struct Representable: CustomUIViewRepresentable {

        @Environment(\.self) private var environment

        @Environment(\.customScrollTargetBehavior) private var scrollTargetBehavior

        @Environment(\.customScrollEnvironmentProperties) private var scrollEnvironmentProperties

        var customScrollView: CustomScrollView<Content>

        init(_ customScrollView: CustomScrollView<Content>) {
            self.customScrollView = customScrollView
        }

        func makeUIView(context: Context) -> UIScrollView {
            context.coordinator.makeUIView(context: context)
        }

        func updateUIView(_ scrollView: UIScrollView, context: Context) {
            context.coordinator.representable = self
            context.coordinator.updateUIView(context: context)
        }

        func sizeThatFits(_ proposal: CustomProposedViewSize, uiView: UIScrollView, context: Context) -> CGSize? {
            context.coordinator.sizeThatFits(proposal, context: context)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator {
            let scrollView = UIScrollView()
            let scrollContentView = UIView()

            var topConstraint: NSLayoutConstraint?
            var leadingConstraint: NSLayoutConstraint?

            var horizontalScrollingDisablingConstraint: NSLayoutConstraint?
            var verticalScrollingDisablingConstraint: NSLayoutConstraint?

            var scrollContentWidthConstraint: NSLayoutConstraint?
            var scrollContentHeightConstraint: NSLayoutConstraint?

            let framedContentHostingController: UIHostingController<ScrollContent<Content>>
            let scrollContentCoordinator: ScrollContentCoordinator<Content>

            var uiScrollViewCoordinator: UIScrollViewCoordinator?

            var scrollingFromValueSemaphore = false
            var scrollOriginalTarget: CustomScrollTarget?

            var indicatorFlashSeed: UInt32 = 0

            var representable: Representable

            var frameTransaction: Transaction?
            var frameInitialContentOffset: CGPoint?

            init(_ representable: Representable) {
                self.representable = representable
                let content = representable.customScrollView.content
                let scrollContentCoordinator = ScrollContentCoordinator<Content>(content: content)
                let scrollContent = ScrollContent(content: content, proxy: scrollContentCoordinator)
                self.framedContentHostingController = UIHostingController(rootView: scrollContent)
                self.scrollContentCoordinator = scrollContentCoordinator
                scrollContentView.backgroundColor = .gray
            }

            func makeUIView(context: Context) -> UIScrollView {
                uiScrollViewCoordinator = UIScrollViewCoordinator(self)
                scrollView.delegate = uiScrollViewCoordinator

                framedContentHostingController.view.backgroundColor = .clear
                scrollContentView.backgroundColor = .clear
                let hostingView = framedContentHostingController.view!
                scrollView.addSubview(scrollContentView)
                scrollView.addSubview(hostingView)

                scrollContentView.translatesAutoresizingMaskIntoConstraints = false
                hostingView.translatesAutoresizingMaskIntoConstraints = true

                topConstraint = scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor)
                leadingConstraint = scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)

                horizontalScrollingDisablingConstraint = scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
                verticalScrollingDisablingConstraint = scrollContentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)

                scrollContentWidthConstraint = scrollContentView.widthAnchor.constraint(equalToConstant: 0)
                scrollContentHeightConstraint = scrollContentView.heightAnchor.constraint(equalToConstant: 0)

                NSLayoutConstraint.activate([
                    topConstraint,
                    scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                    leadingConstraint,
                    scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)
                ].compactMap { $0 })

                if let defaultAnchor = context.environment.customScrollEnvironmentProperties.defaultAnchor {
                    // Dobbiamo attendere che venga settato il frame dopo i due dispatch in scrollView.onFrameLayout nell'update
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                            DispatchQueue.main.async { [self] in
                                scrollView.contentOffset = CGPoint(
                                    x: -scrollView.containerFrame.origin.x + defaultAnchor.x * (scrollView.contentSize.width - scrollView.containerFrame.size.width),
                                    y: -scrollView.containerFrame.origin.y + defaultAnchor.y * (scrollView.contentSize.height - scrollView.containerFrame.size.height)
                                )
                            }
                        }
                    }
                }

                representable.scrollEnvironmentProperties.targetCoordinator?.onPositionIDFromValue = { [self] (id, transaction) in
                    guard let targetCoordinator = representable.scrollEnvironmentProperties.targetCoordinator else { return }
                    let namespace = targetCoordinator.targetIDs.first { $1 == id }?.key
                    let geometry = namespace.flatMap { targetCoordinator.targetGeometries[$0] }
                    guard let frame = geometry?.frame(in: .customScrollViewContent) else { return }

                    let unitPoint = targetCoordinator.anchor ?? .topLeading
                    let minContentOffset = CGPoint(
                        x: -scrollView.containerFrame.origin.x,
                        y: -scrollView.containerFrame.origin.y
                    )
                    let maxContentOffset = CGPoint(
                        x: scrollView.contentSize.width-scrollView.containerFrame.size.width-scrollView.containerFrame.origin.x,
                        y: scrollView.contentSize.height-scrollView.containerFrame.size.height-scrollView.containerFrame.origin.y
                    )
                    var realContentOffset = CGPoint(
                        x: frame.origin.x-unitPoint.x*(scrollView.containerFrame.size.width-frame.size.width)-scrollView.containerFrame.origin.x,
                        y: frame.origin.y-unitPoint.y*(scrollView.containerFrame.size.height-frame.size.height)-scrollView.containerFrame.origin.y
                    )

                    if targetCoordinator.anchor == nil {
                        context.coordinator.scrollOriginalTarget = CustomScrollTarget(
                            rect: CGRect(
                                x: scrollView.contentOffset.x + scrollView.containerFrame.origin.x,
                                y: scrollView.contentOffset.y + scrollView.containerFrame.origin.y,
                                width: scrollView.containerFrame.size.width,
                                height: scrollView.containerFrame.size.height
                            )
                        )
                        uiScrollViewCoordinator?.updateTarget(scrollView, withVelocity: .zero, targetContentOffset: &realContentOffset, draggingEndTarget: nil)
                    }

                    let contentOffset = CGPoint(
                        x: min(maxContentOffset.x, max(minContentOffset.x, realContentOffset.x)),
                        y: min(maxContentOffset.y, max(minContentOffset.y, realContentOffset.y))
                    )

                    let animated = transaction.animation != nil && !transaction.disablesAnimations
                    scrollingFromValueSemaphore = true
                    scrollView.setContentOffset(contentOffset, animated: animated)
                }

                representable.customScrollView.configuration.scrollCoordinator.uiScrollView = scrollView

                return scrollView
            }

            func updateUIView(context: Context)  {
                let content = representable.customScrollView.content
                let scrollContent = ScrollContent(content: content, proxy: scrollContentCoordinator)
                withTransaction(context.transaction) { // This doesn't work :(, just use .animation()
                    self.framedContentHostingController.rootView = scrollContent
                    self.scrollContentCoordinator.contentHostingController.rootView = ScrollContentHostingControllerContent(content: content, proxy: self.scrollContentCoordinator) // Va anticipato qui l'assegnamento altrimenti contentHostingController ha il vecchio idealSize. Eliminare tutta la catena di content
                }
                representable.customScrollView.configuration.scrollCoordinator.uiScrollView = scrollView
                scrollContentCoordinator.onLayout = { [self] _ in
                    representable.customScrollView.configuration.scrollCoordinator.onScroll.values.forEach { $0() }
                }

                let axes = representable.customScrollView.axes

                DispatchQueue.main.async { [self] in // Set scroll view properties
                    let axes = representable.customScrollView.axes
                    let scrollTargetBehavior = representable.scrollTargetBehavior

                    if #available(iOS 16.0, *) {
                        scrollView.isScrollEnabled = context.environment.isScrollEnabled && context.environment.customScrollEnvironmentProperties.isEnabled
                    } else {
                        scrollView.isScrollEnabled = context.environment.customScrollEnvironmentProperties.isEnabled
                    }
                    scrollView.clipsToBounds = context.environment.customScrollEnvironmentProperties.isClippingEnabled

                    switch context.environment.customScrollEnvironmentProperties.horizontal.bounceBehavior.role {
                    case .automatic:
                        scrollView.alwaysBounceHorizontal = axes.contains(.horizontal)
                    case .always:
                        scrollView.alwaysBounceHorizontal = true
                    case .basedOnSize:
                        scrollView.alwaysBounceHorizontal = scrollView.contentSize.width > scrollView.containerFrame.size.width
                    }

                    switch context.environment.customScrollEnvironmentProperties.vertical.bounceBehavior.role {
                    case .automatic:
                        scrollView.alwaysBounceVertical = axes.contains(.vertical)
                    case .always:
                        scrollView.alwaysBounceVertical = true
                    case .basedOnSize:
                        scrollView.alwaysBounceVertical = scrollView.contentSize.height > scrollView.containerFrame.size.height
                    }

                    let contentMargins = context.environment.customScrollEnvironmentProperties.contentMargins
                    let hasNotHorizontalContentMargins = contentMargins.leading == 0 && contentMargins.trailing == 0
                    let hasNotVerticalContentMargins = contentMargins.top == 0 && contentMargins.bottom == 0
                    var hasNotScrollAxesContentMargins = true
                    if axes.contains(.horizontal) {
                        hasNotScrollAxesContentMargins = hasNotScrollAxesContentMargins && hasNotHorizontalContentMargins
                    }
                    if axes.contains(.vertical) {
                        hasNotScrollAxesContentMargins = hasNotScrollAxesContentMargins && hasNotVerticalContentMargins
                    }
                    scrollView.isPagingEnabled = (scrollTargetBehavior is CustomPagingScrollTargetBehavior) && hasNotScrollAxesContentMargins

                    if let limitBehavior = (scrollTargetBehavior as? CustomViewAlignedScrollTargetBehavior)?.limitBehavior {
                        switch limitBehavior.role {
                        case .automatic:
                            let isHorizontalAndCompact = axes == .horizontal && context.environment.horizontalSizeClass == .compact
                            let isVerticalAndCompact = axes == .vertical && context.environment.verticalSizeClass == .compact
                            if isHorizontalAndCompact || isVerticalAndCompact {
                                scrollView.decelerationRate = .fast
                            } else {
                                scrollView.decelerationRate = .normal
                            }
                        case .always:
                            scrollView.decelerationRate = .fast
                        case .never:
                            scrollView.decelerationRate = .normal
                        }
                    } else if scrollTargetBehavior is CustomPagingScrollTargetBehavior {
                        scrollView.decelerationRate = .fast
                    } else {
                        scrollView.decelerationRate = .normal
                    }

                    let showingVisibilities: [CustomScrollIndicatorVisibility] = [.visible, .automatic]
                    scrollView.showsHorizontalScrollIndicator = showingVisibilities.contains(context.environment.customScrollEnvironmentProperties.horizontal.indicator.visibility)
                    scrollView.showsVerticalScrollIndicator = showingVisibilities.contains(context.environment.customScrollEnvironmentProperties.vertical.indicator.visibility)
                    switch context.environment.customScrollEnvironmentProperties.vertical.indicator.style.role {
                    case .automatic:
                        scrollView.indicatorStyle = .default
                    case .black:
                        scrollView.indicatorStyle = .default
                    case .white:
                        scrollView.indicatorStyle = .white
                    }

                    if indicatorFlashSeed != context.environment.customScrollEnvironmentProperties.indicatorsFlashSeed {
                        DispatchQueue.main.async { [self] in
                            scrollView.flashScrollIndicators()
                        }
                        indicatorFlashSeed = context.environment.customScrollEnvironmentProperties.indicatorsFlashSeed
                    }

                    func convertEdgeInsetsToUIEdgeInsets(edgeInsets: EdgeInsets) -> UIEdgeInsets {
                        switch UIView.userInterfaceLayoutDirection(for: self.scrollView.semanticContentAttribute) {
                        case .leftToRight:
                            return UIEdgeInsets(
                                top: edgeInsets.top,
                                left: edgeInsets.leading,
                                bottom: edgeInsets.bottom,
                                right: edgeInsets.trailing
                            )
                        case .rightToLeft:
                            return UIEdgeInsets(
                                top: edgeInsets.top,
                                left: edgeInsets.trailing,
                                bottom: edgeInsets.bottom,
                                right: edgeInsets.leading
                            )
                        @unknown default:
                            return UIEdgeInsets(
                                top: edgeInsets.top,
                                left: edgeInsets.leading,
                                bottom: edgeInsets.bottom,
                                right: edgeInsets.trailing
                            )
                        }
                    }

                    representable.customScrollView.configuration.scrollCoordinator.contentMargins = contentMargins

                    var contentInsets = convertEdgeInsetsToUIEdgeInsets(edgeInsets: contentMargins)
                    if !axes.contains(.horizontal) {
                        contentInsets.left = 0
                        contentInsets.right = 0
                    }
                    if !axes.contains(.vertical) {
                        contentInsets.top = 0
                        contentInsets.bottom = 0
                    }
                    scrollView.contentInset = contentInsets

                    let indicatorsMargins = context.environment.customScrollEnvironmentProperties.indicatorsMargins
                    let indicatorsInsets = convertEdgeInsetsToUIEdgeInsets(edgeInsets: indicatorsMargins)
                    scrollView.horizontalScrollIndicatorInsets = indicatorsInsets
                    scrollView.verticalScrollIndicatorInsets = indicatorsInsets
                }

                var constraintsToActivate: [NSLayoutConstraint] = []
                var constraintsToDeactivate: [NSLayoutConstraint] = []

                if axes.contains(.horizontal) {
                    horizontalScrollingDisablingConstraint.map { constraintsToDeactivate.append($0) }
                    scrollContentWidthConstraint.map { constraintsToActivate.append($0) }
                } else {
                    horizontalScrollingDisablingConstraint.map { constraintsToActivate.append($0) }
                    scrollContentWidthConstraint.map { constraintsToDeactivate.append($0) }
                }

                if axes.contains(.vertical) {
                    verticalScrollingDisablingConstraint.map { constraintsToDeactivate.append($0) }
                    scrollContentHeightConstraint.map { constraintsToActivate.append($0) }
                } else {
                    verticalScrollingDisablingConstraint.map { constraintsToActivate.append($0) }
                    scrollContentHeightConstraint.map { constraintsToDeactivate.append($0) }
                }

                NSLayoutConstraint.deactivate(constraintsToDeactivate)
                NSLayoutConstraint.activate(constraintsToActivate)
                scrollContentWidthConstraint?.constant = scrollContentCoordinator.contentHostingController.idealSize.width
                scrollContentHeightConstraint?.constant = scrollContentCoordinator.contentHostingController.idealSize.height

                DispatchQueue.main.async { [self] in
                    topConstraint?.constant = axes.contains(.horizontal)  ? max((scrollView.bounds.height - scrollContentView.bounds.height) / 2, 0) : 0
                    leadingConstraint?.constant = axes.contains(.vertical) ?  max((scrollView.bounds.width - scrollContentView.bounds.width) / 2, 0) : 0
                    scrollView.updateConstraintsIfNeeded()
                    scrollView.layoutIfNeeded()
                }

                DispatchQueue.main.async { [self] in
                    withTransaction(context.transaction) {
                        scrollContentCoordinator.size = scrollContentView.frame.size
                        scrollContentCoordinator.x = scrollContentView.frame.midX
                        scrollContentCoordinator.y = scrollContentView.frame.midY
                        scrollContentCoordinator.alignment = axes == [.horizontal, .vertical] ? .center : .topLeading
                        scrollContentCoordinator.scrollSize = scrollView.bounds.size
                    }
                }

                scrollContentCoordinator.onContentSize = { [self] size, transaction in

                    frameInitialContentOffset = scrollView.contentOffset
                    frameTransaction = transaction

                    DispatchQueue.main.async { [self] in
                        scrollContentWidthConstraint?.constant = scrollContentCoordinator.contentHostingController.idealSize.width
                        scrollContentHeightConstraint?.constant = scrollContentCoordinator.contentHostingController.idealSize.height
                        scrollView.updateConstraintsIfNeeded()
                        scrollView.layoutIfNeeded()
                    }
                }

                scrollView.onFrameLayout = { [self] frame in
                    var contentOffsetDifference: CGPoint?
                    if let frameInitialContentOffset {
                        contentOffsetDifference = CGPoint(
                            x: scrollView.contentOffset.x - frameInitialContentOffset.x,
                            y: scrollView.contentOffset.y - frameInitialContentOffset.y
                        )
                        self.frameInitialContentOffset = nil
                    }

                    DispatchQueue.main.async { [self] in
                        topConstraint?.constant = axes.contains(.horizontal) ? max((scrollView.bounds.height-scrollContentView.bounds.height)/2, 0) : 0
                        leadingConstraint?.constant = axes.contains(.vertical) ?  max((scrollView.bounds.width-scrollContentView.bounds.width)/2, 0) : 0
                        scrollView.updateConstraintsIfNeeded()
                        scrollView.layoutIfNeeded()
                        DispatchQueue.main.async {  [self] in
                            framedContentHostingController.view.frame = CGRect(
                                x: 0,
                                y: 0,
                                width: max(scrollContentView.bounds.size.width, scrollView.bounds.width),
                                height: max(scrollContentView.bounds.size.height, scrollView.bounds.height)
                            ) // For touch events
                            if let contentOffsetDifference {
                                scrollContentCoordinator.x += contentOffsetDifference.x
                                scrollContentCoordinator.y += contentOffsetDifference.y
                            }
                            withTransaction(frameTransaction ?? Transaction()) {
                                if scrollContentCoordinator.size != scrollContentView.frame.size {
                                    scrollContentCoordinator.size = scrollContentView.frame.size
                                }
                                if scrollContentCoordinator.x != scrollContentView.frame.midX {
                                    scrollContentCoordinator.x = scrollContentView.frame.midX
                                }
                                if scrollContentCoordinator.y != scrollContentView.frame.midY {
                                    scrollContentCoordinator.y = scrollContentView.frame.midY
                                }
                            }
                        }
                    }
                }
            }

            func sizeThatFits(_ proposal: CustomProposedViewSize, context: Context) -> CGSize? {
                let axes = representable.customScrollView.axes

                if proposal.width == nil || proposal.height == nil {
                    let contentIdealSize = context.coordinator.scrollContentCoordinator.contentHostingController.sizeThatFits(in: CGSize(width: Double.infinity, height: Double.infinity))
                    if axes.isEmpty {
                        return proposal.replacingUnspecifiedDimensions()
                    } else {
                        return proposal.replacingUnspecifiedDimensions(by: contentIdealSize)
                    }
                }
                if proposal == .zero {
                    let proposalSize = proposal.replacingUnspecifiedDimensions()
                    let contentSize = context.coordinator.scrollContentCoordinator.contentHostingController.sizeThatFits(in: proposalSize)
                    if axes == .horizontal {
                        return CGSize(width: proposalSize.width, height: contentSize.height)
                    }
                    if axes == .vertical {
                        return CGSize(width: contentSize.width, height: proposalSize.height)
                    }
                }
                if proposal != .zero, proposal != .infinity {
                    let proposalSize = proposal.replacingUnspecifiedDimensions()
                    let contentSize = context.coordinator.scrollContentCoordinator.contentHostingController.maxSize
                    let currentSize = scrollView.bounds.size
                    if axes == .horizontal, contentSize.height <= currentSize.height {
                        return CGSize(width: proposalSize.width, height: contentSize.height)
                    }
                    if axes == .vertical, contentSize.width <= currentSize.width {
                        return CGSize(width: contentSize.width, height: proposalSize.height)
                    }
                }
                return nil
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private extension UIHostingController {

    var minSize: CGSize {
        sizeThatFits(in: .zero)
    }

    var idealSize: CGSize {
        sizeThatFits(in: CGSize(width: Double.infinity, height: Double.infinity))
    }

    var maxSize: CGSize {
        let threshold = 2777776 //.9999999997675 One more and `sizeThatFits` will return the idealSize
        return sizeThatFits(in: CGSize(width: threshold, height: threshold))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ScrollContentCoordinator<Content: View>: ObservableObject {

    @Published var width: CGFloat?

    @Published var height: CGFloat?

    @Published var x: CGFloat = 0

    @Published var y: CGFloat = 0

    @Published var alignment: Alignment = .center

    @Published var scrollWidth: CGFloat?

    @Published var scrollHeight: CGFloat?

    @Published var scrollOffset = CGPoint()

    var onLayout: (UIView) -> Void = { _ in }

    var onContentSize: (CGSize, Transaction) -> Void = { _, _   in }

    var contentSize: CGSize?

    private let content: Content

    private(set) lazy var contentHostingController: ScrollContentHostingController<Content>.UIViewControllerType = {
        UIHostingController(rootView: ScrollContentHostingControllerContent(content: content, proxy: self))
    }()

    init(content: Content) {
        self.content = content
    }

    var size: CGSize? {
        get {
            if let width, let height {
                return CGSize(width: width, height: height)
            } else {
                return nil
            }
        } set {
            width = newValue?.width
            height = newValue?.height
        }
    }

    var origin: CGPoint {
        get {
            CGPoint(x: x, y: y)
        } set {
            x = newValue.x
            y = newValue.y
        }
    }

    var scrollSize: CGSize? {
        get {
            if let scrollWidth, let scrollHeight {
                return CGSize(width: scrollWidth, height: scrollHeight)
            } else {
                return nil
            }
        } set {
            scrollWidth = newValue?.width
            scrollHeight = newValue?.height
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollContent<Content: View>: View {

    var content: Content

    @ObservedObject var proxy: ScrollContentCoordinator<Content>

    @Environment(\.customScrollEnvironmentProperties.contentMargins) private var contentMargins

    @Environment(\.customScrollViewConfiguration?.axes) private var axes

    private var padding: EdgeInsets {
        guard let axes else { return EdgeInsets() }
        var padding = contentMargins
        if axes.contains(.horizontal) {
            padding.leading = 0
            padding.trailing = 0
        }
        if axes.contains(.vertical) {
            padding.top = 0
            padding.bottom = 0
        }
        return padding
    }

    var body: some View {
        ScrollContentHostingController(content: content, proxy: proxy)
            .onLayout(action: proxy.onLayout)
            .padding(padding)
            .frame(width: proxy.width, height: proxy.height, alignment: proxy.alignment)
            .position(x: proxy.x, y: proxy.y)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollContentHostingController<Content: View>: UIViewControllerRepresentable {

    var content: Content

    @ObservedObject var proxy: ScrollContentCoordinator<Content>

    func makeUIViewController(context: Context) -> UIHostingController<ScrollContentHostingControllerContent<Content>> {
        let controller = proxy.contentHostingController
        proxy.contentHostingController.view.backgroundColor = nil
        return controller
    }

    func updateUIViewController(_ uiViewController: UIHostingController<ScrollContentHostingControllerContent<Content>>, context: Context) {
        uiViewController.rootView = ScrollContentHostingControllerContent(content: content, proxy: proxy)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ScrollContentHostingControllerContent<Content: View>: View {

    var content: Content

    @ObservedObject var proxy: ScrollContentCoordinator<Content>

    @Environment(\.customScrollEnvironmentProperties.contentMargins) private var contentMargins

    @Environment(\.customScrollViewConfiguration?.axes) private var axes

    var containerOffset: CGSize {
        CGSize(
            width: -proxy.scrollOffset.x,
            height: -proxy.scrollOffset.y
        )
    }

    var containerSize: CGSize {
        CGSize(
            width: max(0, (proxy.scrollWidth ?? 0) - contentMargins.leading - contentMargins.trailing),
            height: max(0, (proxy.scrollHeight ?? 0) - contentMargins.top - contentMargins.bottom)
        )
    }

    var body: some View {
        content
            .customCoordinateSpace(.customScrollViewContent)
            .background(
                GeometryReader  { geometry in
                    Color.clear
                        .onUpdate(of: geometry.size) { _, transaction in
                            if proxy.contentSize != geometry.size {
                                proxy.contentSize = geometry.size
                                proxy.onContentSize(geometry.size, transaction)
                            }
                        }
                }
            )
            .offset(containerOffset)
            .customCoordinateSpace(.customScrollView)
            .offset(x: -containerOffset.width, y: -containerOffset.height)
            .environment(\.customContainerSize, containerSize)
            //.frame(width: axes == [] ? proxy.width : nil, height: axes == [] ? proxy.height : nil, alignment: proxy.alignment)
    }
}

class UIScrollView: UIKit.UIScrollView {

    var onFrameLayout: ((CGRect) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onFrameLayout?(frame)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomScrollView.Representable.Coordinator {

    class UIScrollViewCoordinator: NSObject, UIScrollViewDelegate {

        let coordinator: CustomScrollView.Representable.Coordinator

        init(_ coordinator: CustomScrollView.Representable.Coordinator) {
            self.coordinator = coordinator
        }

        func updateTarget(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: inout CGPoint, draggingEndTarget: CustomScrollTarget?) {
            let scrollTargetBehavior = coordinator.representable.scrollTargetBehavior
            let adjustedScrollTargetOrigin = CGPoint(
                x: targetContentOffset.x + scrollView.containerFrame.origin.x,
                y: targetContentOffset.y + scrollView.containerFrame.origin.y
            )
            let adjustedScrollTargetRect = CGRect(origin: adjustedScrollTargetOrigin, size: scrollView.containerFrame.size)
            var adjustedScrollTarget = CustomScrollTarget(rect: adjustedScrollTargetRect, anchor: .zero)

            let scrollContext = CustomScrollTargetBehaviorContext(
                originalTarget: coordinator.scrollOriginalTarget!,
                draggingEndTarget: draggingEndTarget,
                velocity: CGVector(dx: velocity.x, dy: velocity.y),
                contentSize: coordinator.scrollView.contentSize,
                containerSize: coordinator.scrollView.containerFrame.size,
                axes: coordinator.representable.customScrollView.axes,
                environment: coordinator.representable.environment
            )

            scrollTargetBehavior.updateTarget(&adjustedScrollTarget, context: scrollContext)

            targetContentOffset = CGPoint(
                x: adjustedScrollTarget.rect.origin.x - scrollView.containerFrame.origin.x,
                y: adjustedScrollTarget.rect.origin.y - scrollView.containerFrame.origin.y
            )
        }

        func updateScrollPositionValue(_ scrollView: UIScrollView) {
            guard let context = coordinator.representable.scrollEnvironmentProperties.targetCoordinator else { return }

            let visibleTarget = CustomScrollTarget(
                rect: CGRect(
                    x: scrollView.contentOffset.x + scrollView.containerFrame.origin.x,
                    y: scrollView.contentOffset.y + scrollView.containerFrame.origin.y,
                    width: scrollView.containerFrame.size.width,
                    height: scrollView.containerFrame.size.height
                ),
                anchor: context.anchor
            )

            let closestTargetID = context.closestTargetID(to: visibleTarget)

            if let closestTargetID, closestTargetID != context.positionID {
                context.positionID = closestTargetID
                context.onPositionIDFromScroll?(closestTargetID)
            }
        }

        @objc(scrollViewDidScroll:)
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            coordinator.scrollContentCoordinator.scrollOffset = scrollView.contentOffset
            coordinator.representable.customScrollView.configuration.scrollCoordinator.onScroll.values.forEach { $0() }
            //print("SCROLLVIEWDIDSCROLL")
            guard !coordinator.scrollingFromValueSemaphore else { return }
            updateScrollPositionValue(scrollView)
        }

        @objc(scrollViewWillEndDragging:withVelocity:targetContentOffset:)
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard !scrollView.isPagingEnabled else { return }
            let draggingEndTarget = CustomScrollTarget(
                rect: CGRect(
                    x: scrollView.contentOffset.x + scrollView.containerFrame.origin.x,
                    y: scrollView.contentOffset.y + scrollView.containerFrame.origin.y,
                    width: scrollView.containerFrame.size.width,
                    height: scrollView.containerFrame.size.height
                )
            )

            updateTarget(scrollView, withVelocity: velocity, targetContentOffset: &targetContentOffset.pointee, draggingEndTarget: draggingEndTarget)
        }

        @objc(scrollViewWillBeginDragging:)
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            coordinator.scrollingFromValueSemaphore = false
            coordinator.scrollOriginalTarget = CustomScrollTarget(
                rect: CGRect(
                    x: scrollView.contentOffset.x + scrollView.containerFrame.origin.x,
                    y: scrollView.contentOffset.y + scrollView.containerFrame.origin.y,
                    width: scrollView.containerFrame.size.width,
                    height: scrollView.containerFrame.size.height
                )
            )
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension UIScrollView {

    var containerFrame: CGRect {
        let origin = CGPoint(
            x: adjustedContentInset.left,
            y: adjustedContentInset.top
        )
        let size = CGSize(
            width: bounds.width - adjustedContentInset.left - adjustedContentInset.right,
            height: bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
        )
        return CGRect(origin: origin, size: size)
    }
}

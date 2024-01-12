import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public protocol CustomUIViewRepresentable: View {

    associatedtype UIViewType: UIView

    @MainActor func makeUIView(context: Context) -> UIViewType

    @MainActor func updateUIView(_ uiView: UIViewType, context: Context)

    @MainActor static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator)

    associatedtype Coordinator = Void

    @MainActor func makeCoordinator() -> Coordinator

    @MainActor func sizeThatFits(_ proposal: CustomProposedViewSize, uiView: UIViewType, context: Context) -> CGSize?

    typealias Context = CustomUIViewRepresentableContext<Self>
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension CustomUIViewRepresentable where Coordinator == () {

    public func makeCoordinator() -> Coordinator {
        return ()
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension CustomUIViewRepresentable {

    public func sizeThatFits(_ proposal: CustomProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
        return nil
    }

    public static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {}

    public var body: some View {
        RepresentableView(customRepresentable: self)
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct CustomUIViewRepresentableContext<CustomRepresentable: CustomUIViewRepresentable> {

    fileprivate var context: UIViewRepresentableContext<Representable<CustomRepresentable>>

    /// The view's associated coordinator.
    public var coordinator: CustomRepresentable.Coordinator {
        context.coordinator
    }

    /// The current transaction.
    public var transaction: Transaction {
        context.transaction
    }

    /// The current environment.
    ///
    /// Use the environment values to configure the state of your view when
    /// creating or updating it.
    public var environment: EnvironmentValues {
        context.environment
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct RepresentableView<CustomRepresentable: CustomUIViewRepresentable>: View {

    var customRepresentable: CustomRepresentable

    @CustomStateObject private var coordinator = LayuotCoordinator()

    var body: some View {
        ZStack {
            if case .calculatingExplicitProposedViewSize(let transaction) = coordinator.layoutPhase {
                GeometryReader { proxy in
                    Color.clear
                        .onUpdate(of: nil) { _, _ in
                            coordinator.layoutPhase = .calculatingExplicitSize(proposedViewSize: CustomProposedViewSize(proxy.size))
                            Task { @MainActor in
                                withTransaction(transaction) {
                                    coordinator.objectWillChange.send()
                                }
                            }
                        }
                }
                .frame(minWidth: coordinator.minSize?.width, idealWidth: coordinator.idealSize?.width, maxWidth: coordinator.maxSize?.width, minHeight: coordinator.minSize?.height, idealHeight: coordinator.idealSize?.height, maxHeight: coordinator.maxSize?.height)
            }
            Representable(customRepresentable: customRepresentable, coordinator: coordinator)
                .frame(width: coordinator.explicitSize?.width, height: coordinator.explicitSize?.height)
                .frame(minWidth: coordinator.minSize?.width, idealWidth: coordinator.idealSize?.width, maxWidth: coordinator.maxSize?.width, minHeight: coordinator.minSize?.height, idealHeight: coordinator.idealSize?.height, maxHeight: coordinator.maxSize?.height)
                .layoutPriority(-1)
                .opacity(coordinator.contentOpacity)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct Representable<CustomRepresentable: CustomUIViewRepresentable>: UIViewRepresentable {

    private var customRepresentable: CustomRepresentable

    @ObservedObject private var coordinator: LayuotCoordinator

    fileprivate init(customRepresentable: CustomRepresentable, coordinator: LayuotCoordinator) {
        self.customRepresentable = customRepresentable
        self.coordinator = coordinator
    }

    public func makeUIView(context: Context) -> CustomRepresentable.UIViewType {
        customRepresentable.makeUIView(context: CustomUIViewRepresentableContext(context: context))
    }

    public func updateUIView(_ uiView: CustomRepresentable.UIViewType, context: Context) {
        switch coordinator.layoutPhase {
        case .idle:
            customRepresentable.updateUIView(uiView, context: CustomUIViewRepresentableContext(context: context))

            coordinator.minSize = customRepresentable.sizeThatFits(.zero, uiView: uiView, context: CustomUIViewRepresentableContext(context: context))
            coordinator.maxSize = customRepresentable.sizeThatFits(.infinity, uiView: uiView, context: CustomUIViewRepresentableContext(context: context))
            coordinator.idealSize = customRepresentable.sizeThatFits(.unspecified, uiView: uiView, context: CustomUIViewRepresentableContext(context: context))

            coordinator.layoutPhase = .calculatingExplicitProposedViewSize(transaction: context.transaction)
            Task { @MainActor in
                withTransaction(context.transaction) {
                    coordinator.objectWillChange.send()
                }
            }
        case .calculatingExplicitProposedViewSize:
            break
        case .calculatingExplicitSize(let proposedViewSize):
            coordinator.explicitSize = customRepresentable.sizeThatFits(proposedViewSize, uiView: uiView, context: CustomUIViewRepresentableContext(context: context))
            coordinator.layoutPhase = .applyingExplicitSize
            coordinator.contentOpacity = 1
            Task { @MainActor in
                withTransaction(context.transaction) {
                    coordinator.objectWillChange.send()
                }
            }
        case .applyingExplicitSize:
            coordinator.layoutPhase = .idle
        }
    }

    public static func dismantleUIView(_ uiView: CustomRepresentable.UIViewType, coordinator: CustomRepresentable.Coordinator) {
        CustomRepresentable.dismantleUIView(uiView, coordinator: coordinator)
    }

    public func makeCoordinator() -> CustomRepresentable.Coordinator {
        customRepresentable.makeCoordinator()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private class LayuotCoordinator: ObservableObject {
    var minSize: CGSize?
    var maxSize: CGSize?
    var idealSize: CGSize?
    var explicitSize: CGSize?

    var layoutPhase: LayoutPhase = .idle

    var contentOpacity: CGFloat = 0

    init() {
        print("HOLA")
    }

    enum LayoutPhase {
        case idle // first we apply updateUIView than we calculate flex sizes.
        case calculatingExplicitProposedViewSize(transaction: Transaction) // Here we spawn a Spacer in order to get the explicit size.
        case calculatingExplicitSize(proposedViewSize: CustomProposedViewSize) // Here we calculate the explicit size.
        case applyingExplicitSize // Here we apply the explicit size without sending an update.
    }

    var isCalculatingExplicitProposedViewSize: Bool {
        if case .calculatingExplicitProposedViewSize(transaction: _) = layoutPhase {
            return true
        } else {
            return false
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
  func onSizeChange(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@frozen public struct CustomProposedViewSize : Equatable {

    /// The proposed horizontal size measured in points.
    ///
    /// A value of `nil` represents an unspecified width proposal, which a view
    /// interprets to mean that it should use its ideal width.
    public var width: CGFloat?

    /// The proposed vertical size measured in points.
    ///
    /// A value of `nil` represents an unspecified height proposal, which a view
    /// interprets to mean that it should use its ideal height.
    public var height: CGFloat?

    /// A size proposal that contains zero in both dimensions.
    ///
    /// Subviews of a custom layout return their minimum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its minimum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let zero = CustomProposedViewSize(.zero)

    /// The proposed size with both dimensions left unspecified.
    ///
    /// Both dimensions contain `nil` in this size proposal.
    /// Subviews of a custom layout return their ideal size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its ideal size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let unspecified = CustomProposedViewSize(width: nil, height: nil)

    /// A size proposal that contains infinity in both dimensions.
    ///
    /// Both dimensions contain
    /// <doc://com.apple.documentation/documentation/CoreFoundation/CGFloat/1454161-infinity>
    /// in this size proposal.
    /// Subviews of a custom layout return their maximum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its maximum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let infinity = CustomProposedViewSize(width: .infinity, height: .infinity)

    /// Creates a new proposed size using the specified width and height.
    ///
    /// - Parameters:
    ///   - width: A proposed width in points. Use a value of `nil` to indicate
    ///     that the width is unspecified for this proposal.
    ///   - height: A proposed height in points. Use a value of `nil` to
    ///     indicate that the height is unspecified for this proposal.
    public init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }

    /// Creates a new proposed size from a specified size.
    ///
    /// - Parameter size: A proposed size with dimensions measured in points.
    public init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }

    /// Creates a new proposal that replaces unspecified dimensions in this
    /// proposal with the corresponding dimension of the specified size.
    ///
    /// Use the default value to prevent a flexible view from disappearing
    /// into a zero-sized frame, and ensure the unspecified value remains
    /// visible during debugging.
    ///
    /// - Parameter size: A set of concrete values to use for the size proposal
    ///   in place of any unspecified dimensions. The default value is `10`
    ///   for both dimensions.
    ///
    /// - Returns: A new, fully specified size proposal.
    public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(width: 10, height: 10)) -> CGSize {
        CGSize(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Positions this view within an invisible frame with a size relative
    /// to the nearest custom container.
    ///
    /// Use this modifier to specify a size for a view's width, height,
    /// or both that is dependent on the size of the nearest custom container.
    /// Different things can represent a "custom container" including:
    ///   - The window presenting a view on iPadOS or macOS, or the
    ///     screen of a device on iOS.
    ///   - A CustomNavigationStack
    ///   - A scrollable view like CustomScrollView
    ///
    /// The size provided to this modifier is the size of a container like
    /// the ones listed above subtracting any safe area insets that might
    /// be applied to that container.
    ///
    /// The following example will have each purple rectangle occupy the full
    /// size of the screen on iOS:
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 0.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .customContainerRelativeFrame([.horizontal, .vertical])
    ///             }
    ///         }
    ///     }
    ///
    /// Use the ``View/customContainerRelativeFrame(_:count:span:spacing:alignment:)``
    /// modifier to size a view such that multiple views will be visible in
    /// the container. When using this modifier, the count refers to the
    /// total number of rows or columns that the length of the container size
    /// in a particular axis should be divided into. The span refers to the
    /// number of rows or columns that the modified view should actually
    /// occupy. Thus the size of the element can be described like so:
    ///
    ///     let availableWidth = (containerWidth - (spacing * (count - 1)))
    ///     let columnWidth = (availableWidth / count)
    ///     let itemWidth = (columnWidth * span) + ((span - 1) * spacing)
    ///
    /// The following example only uses the nearest container size in the
    /// horizontal axis, allowing the vertical axis to be determined using
    /// the ``View/aspectRatio(_:contentMode:)-771ow`` modifier.
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .aspectRatio(3.0 / 2.0, contentMode: .fit)
    ///                     .containerRelativeFrame(
    ///                         .horizontal, count: 4, span: 3, spacing: 10.0)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// Use the ``View/customContainerRelativeFrame(_:alignment:_:)``
    /// modifier to apply your own custom logic to adjust the size
    /// of the nearest container for your view. The following example will
    /// result in the container frame's width being divided by 3 and using
    /// that value as the width of the purple rectangle.
    ///
    ///     Rectangle()
    ///         .fill(.purple)
    ///         .aspectRatio(1.0, contentMode: .fill)
    ///         .customContainerRelativeFrame(
    ///             .horizontal, alignment: .topLeading
    ///         ) { length, axis in
    ///             if axis == .vertical {
    ///                 return length / 3.0
    ///             } else {
    ///                 return length / 5.0
    ///             }
    ///         }
    ///
    public func customContainerRelativeFrame(
        _ axes: Axis.Set,
        alignment: Alignment = .center
    ) -> some View {
        modifier(CustomContainerRelativeFrameModifier(axes: axes, alignment: alignment, updateLength: nil))
    }

    /// Positions this view within an invisible frame with a size relative
    /// to the nearest custom container.
    ///
    /// Use this modifier to specify a size for a view's width, height,
    /// or both that is dependent on the size of the nearest custom container.
    /// Different things can represent a "custom container" including:
    ///   - The window presenting a view on iPadOS or macOS, or the
    ///     screen of a device on iOS.
    ///   - A CustomNavigationStack
    ///   - A scrollable view like CustomScrollView
    ///
    /// The size provided to this modifier is the size of a container like
    /// the ones listed above subtracting any safe area insets that might
    /// be applied to that container.
    ///
    /// The following example will have each purple rectangle occupy the full
    /// size of the screen on iOS:
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 0.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .customContainerRelativeFrame([.horizontal, .vertical])
    ///             }
    ///         }
    ///     }
    ///
    /// Use the ``View/customContainerRelativeFrame(_:count:span:spacing:alignment:)``
    /// modifier to size a view such that multiple views will be visible in
    /// the container. When using this modifier, the count refers to the
    /// total number of rows or columns that the length of the container size
    /// in a particular axis should be divided into. The span refers to the
    /// number of rows or columns that the modified view should actually
    /// occupy. Thus the size of the element can be described like so:
    ///
    ///     let availableWidth = (containerWidth - (spacing * (count - 1)))
    ///     let columnWidth = (availableWidth / count)
    ///     let itemWidth = (columnWidth * span) + ((span - 1) * spacing)
    ///
    /// The following example only uses the nearest container size in the
    /// horizontal axis, allowing the vertical axis to be determined using
    /// the ``View/aspectRatio(_:contentMode:)-771ow`` modifier.
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .aspectRatio(3.0 / 2.0, contentMode: .fit)
    ///                     .containerRelativeFrame(
    ///                         .horizontal, count: 4, span: 3, spacing: 10.0)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// Use the ``View/customContainerRelativeFrame(_:alignment:_:)``
    /// modifier to apply your own custom logic to adjust the size
    /// of the nearest container for your view. The following example will
    /// result in the container frame's width being divided by 3 and using
    /// that value as the width of the purple rectangle.
    ///
    ///     Rectangle()
    ///         .fill(.purple)
    ///         .aspectRatio(1.0, contentMode: .fill)
    ///         .customContainerRelativeFrame(
    ///             .horizontal, alignment: .topLeading
    ///         ) { length, axis in
    ///             if axis == .vertical {
    ///                 return length / 3.0
    ///             } else {
    ///                 return length / 5.0
    ///             }
    ///         }
    ///
    public func customContainerRelativeFrame(
        _ axes: Axis.Set,
        alignment: Alignment = .center,
        _ length: @escaping (CGFloat, Axis) -> CGFloat
    ) -> some View {
        modifier(CustomContainerRelativeFrameModifier(axes: axes, alignment: alignment, updateLength: length))
    }

    /// Positions this view within an invisible frame with a size relative
    /// to the nearest custom container.
    ///
    /// Use this modifier to specify a size for a view's width, height,
    /// or both that is dependent on the size of the nearest custom container.
    /// Different things can represent a "custom container" including:
    ///   - The window presenting a view on iPadOS or macOS, or the
    ///     screen of a device on iOS.
    ///   - A CustomNavigationStack
    ///   - A scrollable view like CustomScrollView
    ///
    /// The size provided to this modifier is the size of a container like
    /// the ones listed above subtracting any safe area insets that might
    /// be applied to that container.
    ///
    /// The following example will have each purple rectangle occupy the full
    /// size of the screen on iOS:
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 0.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .customContainerRelativeFrame([.horizontal, .vertical])
    ///             }
    ///         }
    ///     }
    ///
    /// Use the ``View/customContainerRelativeFrame(_:count:span:spacing:alignment:)``
    /// modifier to size a view such that multiple views will be visible in
    /// the container. When using this modifier, the count refers to the
    /// total number of rows or columns that the length of the container size
    /// in a particular axis should be divided into. The span refers to the
    /// number of rows or columns that the modified view should actually
    /// occupy. Thus the size of the element can be described like so:
    ///
    ///     let availableWidth = (containerWidth - (spacing * (count - 1)))
    ///     let columnWidth = (availableWidth / count)
    ///     let itemWidth = (columnWidth * span) + ((span - 1) * spacing)
    ///
    /// The following example only uses the nearest container size in the
    /// horizontal axis, allowing the vertical axis to be determined using
    /// the ``View/aspectRatio(_:contentMode:)-771ow`` modifier.
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 Rectangle()
    ///                     .fill(.purple)
    ///                     .aspectRatio(3.0 / 2.0, contentMode: .fit)
    ///                     .containerRelativeFrame(
    ///                         .horizontal, count: 4, span: 3, spacing: 10.0)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// Use the ``View/customContainerRelativeFrame(_:alignment:_:)``
    /// modifier to apply your own custom logic to adjust the size
    /// of the nearest container for your view. The following example will
    /// result in the container frame's width being divided by 3 and using
    /// that value as the width of the purple rectangle.
    ///
    ///     Rectangle()
    ///         .fill(.purple)
    ///         .aspectRatio(1.0, contentMode: .fill)
    ///         .customContainerRelativeFrame(
    ///             .horizontal, alignment: .topLeading
    ///         ) { length, axis in
    ///             if axis == .vertical {
    ///                 return length / 3.0
    ///             } else {
    ///                 return length / 5.0
    ///             }
    ///         }
    ///
    public func containerRelativeFrame(
        _ axes: Axis.Set,
        count: Int,
        span: Int = 1,
        spacing: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        customContainerRelativeFrame(axes, alignment: alignment) { containerLength, _ in
            let availableLength = containerLength - (spacing * CGFloat(count - 1))
            let spanLength = availableLength / CGFloat(count)
            let itemLenght = (spanLength * CGFloat(span)) + (spacing * CGFloat(span - 1))
            return itemLenght
        }

    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomContainerRelativeFrameModifier: ViewModifier {

    let axes: Axis.Set

    let alignment: Alignment

    let updateLength: ((CGFloat, Axis) -> CGFloat)?

    @Environment(\.customContainerSize) private var innerContainerSize

    @State private var windowContainerSize: CGSize?

    private var containerSize: CGSize? {
        innerContainerSize ?? windowContainerSize
    }


    var width: CGFloat? {
        guard axes == .horizontal, let width = containerSize?.width else {
            return nil
        }

        return updateLength?(width, .horizontal) ?? width
    }

    var height: CGFloat? {
        guard axes == .vertical, let height = containerSize?.height else {
            return nil
        }

        return updateLength?(height, .vertical) ?? height
    }

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height, alignment: alignment)
            .background(
                Group {
                    if innerContainerSize == nil {
                        WindowSizeAccessor { windowContainerSize = $0 }
                    }
                }
            )
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct WindowSizeAccessor: UIViewRepresentable {

    var onSize: (CGSize?) -> Void

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let size = uiView.window?.bounds.size
        if context.coordinator.size != size {
            context.coordinator.size = size
            onSize(size)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var size: CGSize?
    }
}

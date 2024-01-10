import SwiftUI

/// A view that arranges its subviews in a horizontal line.
///
/// Unlike ``LazyHStack``, which only renders the views when your app needs to
/// display them onscreen, an `HStack` renders the views all at once, regardless
/// of whether they are on- or offscreen. Use the regular `HStack` when you have
/// a small number of subviews or don't want the delayed rendering behavior
/// of the "lazy" version.
///
/// The following example shows a simple horizontal stack of five text views:
///
///     var body: some View {
///         HStack(
///             alignment: .top,
///             spacing: 10
///         ) {
///             ForEach(
///                 1...5,
///                 id: \.self
///             ) {
///                 Text("Item \($0)")
///             }
///         }
///     }
///
/// ![Five text views, named Item 1 through Item 5, arranged in a
/// horizontal row.](SwiftUI-HStack-simple.png)
///
/// > Note: If you need a horizontal stack that conforms to the ``Layout``
/// protocol, like when you want to create a conditional layout using
/// ``AnyLayout``, use ``HStackLayout`` instead.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomHStack<Content: CustomView>: View {

    private let alignment: VerticalAlignment

    private let spacing: CGFloat?

    private let content: Content

    @ContentParser private var parse

    @Environment(\.customScrollTargetRole) private var scrollTargetRole

    /// Creates a horizontal stack with the given spacing and vertical alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This
    ///     guide has the same vertical screen coordinate for every subview.
    ///   - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @CustomViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            ForEach(parse(content), id: \.id) { info in
                AnyView(info.content)
                    .customID(info.defaultValue)
                    .customScrollTarget(isEnabled: scrollTargetRole == .container)
            }
        }
    }    

    struct ParsedInformation {

        let id: CustomNamespace.ID

        let defaultValue: (any Hashable)?

        let content: any View
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomHStack {
    
    @propertyWrapper struct ContentParser: CustomViewParser {
        
        @State private var namespaceGenerator = CustomNamespaceGenerator()

        var wrappedValue: Action {
            action
        }

        func parse(dynamicViewOutputs: [DynamicViewOutput]) -> [CustomHStack.ParsedInformation] {
            let options = dynamicViewOutputs
                .map { dynamicViewOutput in
                    let id = namespaceGenerator.generate(forPath: dynamicViewOutput.path).id

                    return CustomHStack.ParsedInformation(
                        id: id,
                        defaultValue: dynamicViewOutput.defaultValue,
                        content: dynamicViewOutput.view
                    )
                }
            namespaceGenerator.update()
            return options
        }
    }
}

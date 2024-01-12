import SwiftUI

/// A type that represents part of your app's user interface and provides
/// modifiers that you use to configure views.
///
/// You create custom views by declaring types that conform to the `View`
/// protocol. Implement the required ``View/body-swift.property`` computed
/// property to provide the content for your custom view.
///
///     struct MyView: View {
///         var body: some View {
///             Text("Hello, World!")
///         }
///     }
///
/// Assemble the view's body by combining one or more of the built-in views
/// provided by SwiftUI, like the ``Text`` instance in the example above, plus
/// other custom views that you define, into a hierarchy of views. For more
/// information about creating custom views, see <doc:Declaring-a-Custom-View>.
///
/// The `View` protocol provides a set of modifiers — protocol
/// methods with default implementations — that you use to configure
/// views in the layout of your app. Modifiers work by wrapping the
/// view instance on which you call them in another view with the specified
/// characteristics, as described in <doc:Configuring-Views>.
/// For example, adding the ``View/opacity(_:)`` modifier to a
/// text view returns a new view with some amount of transparency:
///
///     Text("Hello, World!")
///         .opacity(0.5) // Display partially transparent text.
///
/// The complete list of default modifiers provides a large set of controls
/// for managing views.
/// For example, you can fine tune <doc:View-Layout>,
/// add <doc:View-Accessibility> information,
/// and respond to <doc:View-Input-and-Events>.
/// You can also collect groups of default modifiers into new,
/// custom view modifiers for easy reuse.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol CustomView: View {
    
    /// The type of view representing the body of this custom view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required ``CustomView/custombody-swift.property`` property.
    associatedtype CustomBody: CustomView

    /// The content and behavior of the custom view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    @CustomViewBuilder var customBody: Self.CustomBody { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomView where Body == CustomBody {

    public var body: Body {
        customBody
    }
}

// MARK: - View Conformations

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderPair: View where FirstContent: View, SecondContent: View {
    
    public var body: some View {
        first
        second
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderConditional: View where TrueContent: View, FalseContent: View {
    
    public var body: some View {
        switch storage {
        case .trueContent(let content):
            content
        case .falseContent(let content):
            content
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderEmpty: View {
    
    public var body: some View {
        EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderBridge: View where Content: View {
    
    public var body: some View {
        content
    }
}

// MARK: - CustomView Conformations

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderPair: CustomView where FirstContent: CustomView, SecondContent: CustomView {
    
    public var customBody: Never {
        return neverCustomBody("CustomBuilderPair")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderConditional: CustomView where TrueContent: CustomView, FalseContent: CustomView {
    
    public var customBody: Never {
        return neverCustomBody("CustomBuilderConditional")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Optional: CustomView where Wrapped: CustomView {
    
    public var customBody: Never {
        return neverCustomBody("Optional")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderEmpty: CustomView {
    
    public var customBody: Never {
        return neverCustomBody("CustomBuilderEmpty")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderBridge: CustomView where Content: View {
    
    public var customBody: Never {
        return neverCustomBody("CustomBuilderBridge")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Never: CustomView {
    
    public var customBody: some CustomView {
        EmptyView()
    }
}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `CustomView`
private func neverCustomBody(_ type: String) -> Never {
  fatalError("\(type) is a primitive custom view, you're not supposed to access its custom body.")
}

import SwiftUI

/// A structure that computes views on demand from an underlying collection of
/// identified data.
///
/// Use `CustomForEach` to provide views based on a
/// <doc://com.apple.documentation/documentation/Swift/RandomAccessCollection>
/// of some data type. Either the collection's elements must conform to
/// <doc://com.apple.documentation/documentation/Swift/Identifiable> or you
/// need to provide an `id` parameter to the `CustomForEach` initializer.
///
/// The following example creates a `NamedFont` type that conforms to
/// <doc://com.apple.documentation/documentation/Swift/Identifiable>, and an
/// array of this type called `namedFonts`. A `CustomForEach` instance iterates
/// over the array, producing new ``Text`` instances that display examples
/// of each SwiftUI ``Font`` style provided in the array.
///
///     private struct NamedFont: Identifiable {
///         let name: String
///         let font: Font
///         var id: String { name }
///     }
///
///     private let namedFonts: [NamedFont] = [
///         NamedFont(name: "Large Title", font: .largeTitle),
///         NamedFont(name: "Title", font: .title),
///         NamedFont(name: "Headline", font: .headline),
///         NamedFont(name: "Body", font: .body),
///         NamedFont(name: "Caption", font: .caption)
///     ]
///
///     var body: some View {
///         CustomForEach(namedFonts) { namedFont in
///             Text(namedFont.name)
///                 .font(namedFont.font)
///         }
///     }
///
/// ![A vertically arranged stack of labels showing various standard fonts,
/// such as Large Title and Headline.](SwiftUI-ForEach-fonts.png)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomForEach<Data: RandomAccessCollection, ID: Hashable, Content> {
    
    /// An enumeration to generate stable identity using the underlying data.
    typealias IDGenerator = CustomIDGenerator<Data.Element, ID>
    
    private let forEach: ForEach<Data, ID, Content>
    
    /// The collection of underlying identified data that SwiftUI uses to create
    /// views dynamically.
    public var data: Data {
        forEach.data
    }
    

    /// A function to create content on demand using the underlying data.
    public var content: (Data.Element) -> Content {
        forEach.content
    }

    /// An enumeration to generate stable identity using the underlying data.
    let idGenerator: IDGenerator
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension CustomForEach {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// When placed inside a `List` the edit actions (like delete or move)
    /// can be automatically synthesized by specifying an appropriate
    /// `EditActions`.
    ///
    /// The following example shows a list of recipes whose elements can be
    /// deleted and reordered:
    ///
    ///     List {
    ///         CustomForEach($recipes, editActions: [.delete, .move]) { $recipe in
    ///             RecipeCell($recipe)
    ///         }
    ///     }
    ///
    /// Use ``View/deleteDisabled(_:)`` and ``View/moveDisabled(_:)``
    /// to disable respectively delete or move actions on a per-row basis.
    ///
    /// The following example shows a list of recipes whose elements can be
    /// deleted only if they satisfy a condition:
    ///
    ///     List {
    ///         CustomForEach($recipes, editActions: .delete) { $recipe in
    ///             RecipeCell($recipe)
    ///                 .deleteDisabled(recipe.isFromMom)
    ///         }
    ///     }
    ///
    /// Explicit ``DynamicViewContent.onDelete(perform:)``,
    /// ``DynamicViewContent.onMove(perform:)``, or
    /// ``View.swipeActions(edge:allowsFullSwipe:content:)``
    /// modifiers will override any synthesized actions.
    /// Use this modifier if you need fine-grain control on how mutations are
    /// applied to the data driving the `CustomForEach`. For example, if you need to
    /// execute side effects or call into your existing model code.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``CustomForEach`` instance uses to
    ///     create views dynamically and can be edited by the user.
    ///   - editActions: The edit actions that are synthesized on `data`.
    ///   - content: The view builder that creates views dynamically.
    public init<C, R>(_ data: Binding<C>, editActions: EditActions<C>, @ViewBuilder content: @escaping (Binding<C.Element>) -> R) where Data == IndexedIdentifierCollection<C, ID>, ID == C.Element.ID, Content == EditableCollectionContent<R, C>, C : MutableCollection, C : RandomAccessCollection, R : View, C.Element : Identifiable, C.Index : Hashable {
        self.forEach = ForEach(data, editActions: editActions, content: content)
        self.idGenerator = .offset
    }

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// When placed inside a `List` the edit actions (like delete or move)
    /// can be automatically synthesized by specifying an appropriate
    /// `EditActions`.
    ///
    /// The following example shows a list of recipes whose elements can be
    /// deleted and reordered:
    ///
    ///     List {
    ///         CustomForEach($recipes, editActions: [.delete, .move]) { $recipe in
    ///             RecipeCell($recipe)
    ///         }
    ///     }
    ///
    /// Use ``View/deleteDisabled(_:)`` and ``View/moveDisabled(_:)``
    /// to disable respectively delete or move actions on a per-row basis.
    ///
    /// The following example shows a list of recipes whose elements can be
    /// deleted only if they satisfy a condition:
    ///
    ///     List {
    ///         CustomForEach($recipes, editActions: .delete) { $recipe in
    ///             RecipeCell($recipe)
    ///                 .deleteDisabled(recipe.isFromMom)
    ///         }
    ///     }
    ///
    /// Explicit ``DynamicViewContent.onDelete(perform:)``,
    /// ``DynamicViewContent.onMove(perform:)``, or
    /// ``View.swipeActions(edge:allowsFullSwipe:content:)``
    /// modifiers will override any synthesized actions.
    /// Use this modifier if you need fine-grain control on how mutations are
    /// applied to the data driving the `CustomForEach`. For example, if you need to
    /// execute side effects or call into your existing model code.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``CustomForEach`` instance uses to
    ///     create views dynamically and can be edited by the user.
    ///   - id: The key path to the provided data's identifier.
    ///   - editActions: The edit actions that are synthesized on `data`.
    ///   - content: The view builder that creates views dynamically.
    public init<C, R>(_ data: Binding<C>, id: KeyPath<C.Element, ID>, editActions: EditActions<C>, @ViewBuilder content: @escaping (Binding<C.Element>) -> R) where Data == IndexedIdentifierCollection<C, ID>, Content == EditableCollectionContent<R, C>, C : MutableCollection, C : RandomAccessCollection, R : View, C.Index : Hashable {
        self.forEach = ForEach(data, id: id, editActions: editActions, content: content)
        self.idGenerator = .offset
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach where ID == Data.Element.ID, Data.Element: Identifiable, Content: View  {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``CustomForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        self.forEach = ForEach(data, content: content)
        self.idGenerator = .keyPath(\Data.Element.id)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach where Content: View  {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the provided key path to the underlying data's
    /// identifier.
    ///
    /// It's important that the `id` of a data element doesn't change, unless
    /// SwiftUI considers the data element to have been replaced with a new data
    /// element that has a new identity. If the `id` of a data element changes,
    /// then the content view generated from that data element will lose any
    /// current state and animations.
    ///
    /// - Parameters:
    ///   - data: The data that the ``CustomForEach`` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.forEach = ForEach(data, id: id, content: content)
        self.idGenerator = .keyPath(id)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach where Content: View {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``CustomForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    public init<C>(
        _ data: Binding<C>,
        @ViewBuilder content: @escaping (Binding<C.Element>) -> Content
    ) where
        Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
        ID == C.Element.ID,
        C: MutableCollection,
        C: RandomAccessCollection,
        C.Element: Identifiable,
        C.Index: Hashable
    {
        self.forEach = ForEach(data, content: content)
        self.idGenerator = .keyPath(\Data.Element.1)
    }
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``CustomForEach`` instance uses to
    ///     create views dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    public init<C>(
        _ data: Binding<C>,
        id: KeyPath<C.Element, ID>,
        content: @escaping (Binding<C.Element>) -> Content
    ) where
        Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
        C: MutableCollection,
        C: RandomAccessCollection,
        C.Index: Hashable
    {
        self.forEach = ForEach(data, id: id, content: content)
        self.idGenerator = .keyPath(\Data.Element.1)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach where Data == Range<Int>, ID == Int, Content: View {
    
    /// Creates an instance that computes views on demand over a given constant
    /// range.
    ///
    /// The instance only reads the initial value of the provided `data` and
    /// doesn't need to identify views across updates. To compute views on
    /// demand over a dynamic range, use ``CustomForEach/init(_:id:content:)``.
    ///
    /// - Parameters:
    ///   - data: A constant range.
    ///   - content: The view builder that creates views dynamically.
    @_semantics("swiftui.requires_constant_range")
    public init(_ data: Range<Int>, content: @escaping (Int) -> Content) {
        self.forEach = ForEach(data, content: content)
        self.idGenerator = .offset
    }
}


// MARK: - Implementations

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach: View where Content: View {
    
    /// The content and behavior of the view.
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
    public var body: some View {
        forEach
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach: DynamicViewContent where Content: View {}


import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomAnyNavigationPath {

    private var elements: [Element] = []

    private enum Element {
        case data(_ data: any Hashable)
        case binded(_ id: UUID)
        case unbacked
    }

    public mutating func append(_ value: some Hashable) {
        elements.append(.data(value))
    }

    public mutating func append(_ value: some Hashable & Codable) {
        elements.append(.data(value))
    }

    public mutating func removeLast(_ k: Int = 1) {
        elements.removeLast(k)
    }

    public var count: Int {
        elements.count
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }

    private func containsBinded(id: UUID) -> Bool {
        elements.contains { element in
            if case .binded(let elementID) = element {
                elementID == id
            } else {
                false
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CustomNavigationPath {

    private var elements: [Element]

    private enum Element {
        case data(_ data: any Hashable)
        case binded
        case unbacked
    }

    public mutating func append(_ value: some Hashable) {
        elements.append(.data(value))
    }

    public mutating func append(_ value: some Hashable & Codable) {
        elements.append(.data(value))
    }

    public mutating func removeLast(_ k: Int = 1) {
        elements.removeLast(k)
    }

    public var count: Int {
        elements.count
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }
}

//public struct CustomNavigationPath {
//
//    private let _items: Representation
//
//    private var subsequentItems: [CustomNavigationPath_ItemBoxBase]
//
//    private var iterationIndex: Int
//
//    public init() {
//        self._items = .eager([])
//        self.subsequentItems = []
//        self.iterationIndex = 0
//    }
//
//    public mutating func append<V: Hashable>(_ value: V) {
//        subsequentItems.append(ItemBox(value))
//    }
//
//    public mutating func append<V: Codable & Hashable>(_ value: V) {
//        subsequentItems.append(CodableItemBox(value))
//    }
//
//    public mutating func removeLast(_ k: Int = 1) {
//        subsequentItems.removeLast(k)
//    }
//
//}

//private enum Representation {
//    case eager([any Hash])
//    case lazy(CodingKeyRepresentable)
//
//    enum ItemBox {}
//
//    enum CodableItemBox {}
//}
// https://forums.swift.org/t/obtaining-the-mangled-name-of-a-type-from-the-fully-qualified-type-name-only/58857/8
// swift_getTypeByName
// https://github.com/alibaba/HandyJSON/blob/f0b15db3bc0c51e935ea2385d6e33d412f04fffe/Source/Metadata.swift#L200

// isPresented -> ViewDestinationNavigationDestinationModifier<View> destination is a value, isPresented, namespace
// Hashable -> NavigationDestinationModifier<C, EmptyView> destination is a function

//private class CustomNavigationPath_ItemBoxBase {
//    // Lock
//    var isDoubleDispatchingEqualityOperation: Bool = true
//}
//
//extension CustomNavigationPath {
//
//    private class CodableItemBox<T: Hashable & Codable>: CustomNavigationPath_ItemBoxBase {
//        var base: T
//        init(_ base: T) {
//            self.base = base
//        }
//    }
//
//    private class ItemBox<T: Hashable>: CustomNavigationPath_ItemBoxBase {
//        var base: T
//        init(_ base: T) {
//            self.base = base
//        }
//    }
//}
//
//extension CustomNavigationPath {
//    private enum Representation {
//        case eager([CustomNavigationPath_ItemBoxBase])
//        case lazy(CodableRepresentation)
//    }
//}
//
//extension CustomNavigationPath {
//    private struct CodableRepresentation {
//        let resolvedItems: [CustomNavigationPath_ItemBoxBase]
//        let remainingItemsReversed: [(tag: String, item: String)]
//        let subsequentItems: [CustomNavigationPath_ItemBoxBase]
//    }
//}

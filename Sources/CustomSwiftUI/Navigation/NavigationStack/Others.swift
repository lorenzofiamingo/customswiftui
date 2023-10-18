import SwiftUI
import ObjectiveC

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class CustomNavigationStateHost: ObservableObject {
    @Published var navigationState: CustomNavigationState?
    @Published var initializedNavState = false
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomNavigationColumnState {
    //var seeds: CustomNavigationState.Seeds
    //var key: CustomNavigationState.StackContent.Key
    //var listState: CustomNavigationListState?
    //var pathSeed: UInt32
    //var realPath: Binding<CustomAnyNavigationPath>?
    //var content: CustomNavigationColumnState.ColumnContent
    var destinations: CustomResolvedNavigationDestinations
    //var animationsDisabledSeed: UInt32
    //var animationRequestedSeed: UInt32
    //var animation: Animation?
    //var hysteresisState: CustomHysteresisState

    //enum ColumnContent {
    //    case stacked(ReplacedRoot?, CustomAnyNavigationPath, [CustomNavigationViewDestinationView]) // identified array
    //    case flat(ReplacedRoot?)
    //}

    enum ReplacedRoot {
        case value(CustomAnyNavigationLinkPresentedValue)
        case view(CustomNavigationViewDestinationView)
    }
}

enum CustomHysteresisState {
    case initial
    case poppedLocal
    case rootReplaced
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomResolvedNavigationDestinations {
    var destinations: [ObjectIdentifier: CustomNavigationDestinationResolverBase]
    //var nonStackDestinations: [ObjectIdentifier: CustomNavigationDestinationResolverBase]
    //var destinationStack: [Int: [ObjectIdentifier]]
    //var pathLength: Int
    //var typesByTag: [String: any Codable]
    //var environment: EnvironmentValues
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomAnyListSelection {
    var storage: StorageBase

    class StorageBase {
        // No props
    }
}

enum CustomNavigationSplitColumn {
    case sidebar
    case content
    case detail
    case stack
    case collapsed
    case inspector
}

struct CustomNavigationViewDestinationView {
    var wrappedValue: CustomAnyNavigationLinkPresentedView
    var id: AnyHashable // Namespace.ID
    var dismiss: () -> Void
}

struct CustomAnyNavigationLinkPresentedView {
    var storage: CustomAnyNavigationLinkPresentedViewStorageBase

}

class CustomAnyNavigationLinkPresentedViewStorageBase {
    // No props
}

struct CustomAnyNavigationLinkPresentedValue {
    var storage: AnyNavigationLinkPresentedValueStorageBase
}

class AnyNavigationLinkPresentedValueStorageBase {
    // Nessuna proprietà
}

// path
//@propertyWrapper
//struct CustomStateOrBinding {}

//struct CustomAnyNavigationPath {
//    var base: BoxBase
//
//    class BoxBase {}
//}

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//class CustomNavigationStateHost: ObservableObject {
//    var navigationState: CustomNavigationState?
//    var pendingRequests: [CustomNavigationRequest]?
//    var initializedNavState = false
//}
//
//// _parentNavigationState in environment
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomNavigationState {
//    // var environment: SwiftUI.Environment
//    var seeds: Seeds
//
//    var stackStateByKey: [StackContent.Key: CustomNavigationColumnState]
//
//    var listState: CustomNavigationListState?
//
//    struct Seeds {
//        var structure: UInt32
//        var viewContent: UInt32
//    }
//
//    struct StackContent {
//        struct Key: Hashable {
//            var id: AnyHashable //Namespace.ID
//            var column: CustomNavigationSplitColumn
//            var columnCount: Int
//        }
//    }
//
//    struct ListKey: Hashable {
//        static func == (lhs: CustomNavigationState.ListKey, rhs: CustomNavigationState.ListKey) -> Bool {
//            true
//        }
//
//        var id: AnyHashable //Namespace.ID
//        var stackKey: StackContent.Key
//        var hasSelection: Bool
//        var selectionType: Any.Type?
//
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//            hasher.combine(stackKey)
//            hasher.combine(hasSelection)
//            hasher.combine(selectionType.map { ObjectIdentifier($0) })
//        }
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomNavigationColumnState {
//    var seeds: CustomNavigationState.Seeds
//    var key: CustomNavigationState.StackContent.Key
//    var listState: CustomNavigationListState?
//    var pathSeed: UInt32
//    var realPath: Binding<CustomAnyNavigationPath>?
//    var content: CustomNavigationColumnState.ColumnContent
//    var destinations: CustomResolvedNavigationDestinations
//    var animationsDisabledSeed: UInt32
//    var animationRequestedSeed: UInt32
//    var animation: Animation?
//    var hysteresisState: CustomHysteresisState
//
//    enum ColumnContent {
//        case stacked(ReplacedRoot?, CustomAnyNavigationPath, [CustomNavigationViewDestinationView]) // identified array
//        case flat(ReplacedRoot?)
//    }
//
//    enum ReplacedRoot {
//        case value(CustomAnyNavigationLinkPresentedValue)
//        case view(CustomNavigationViewDestinationView)
//    }
//}
//
//enum CustomHysteresisState {
//    case initial
//    case poppedLocal
//    case rootReplaced
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomResolvedNavigationDestinations {
//    var destinations: [ObjectIdentifier: CustomNavigationDestinationResolverBase]
//    var nonStackDestinations: [ObjectIdentifier: CustomNavigationDestinationResolverBase]
//    var destinationStack: [Int: [ObjectIdentifier]]
//    var pathLength: Int
//    var typesByTag: [String: any Codable]
//    var environment: EnvironmentValues
//}
//
//class CustomNavigationDestinationResolverBase {
//    // Nessuna proprietà
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomNavigationListState {
//    var seed: UInt32
//    var selectionByKey: [CustomNavigationState.ListKey: Selection]
//    var shadowSelectionByKey: [CustomNavigationState.ListKey: CustomAnyListSelection]
//    var editingByKey: [CustomNavigationState.ListKey: Bool]
//
//    struct Selection {
//        var binding: Binding<CustomAnyListSelection>
//        var locationID: ObjectIdentifier
//        var metatypeID: ObjectIdentifier
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomAnyListSelection {
//    var storage: StorageBase
//
//    class StorageBase {
//        // No props
//    }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//struct CustomNavigationRequest {
//    var action: Action
//    var key: KeyKind
//    var disablesAnimations: Bool
//    var animation: Animation?
//
//    enum Action {
//        case setInitialPossibilities((CustomResolvedNavigationDestinations) -> [CustomNavigationDestinationResolverBase])
//        case setPath(Binding<CustomAnyNavigationPath>, EnvironmentValues)
//        case setSelection(Binding<CustomAnyListSelection>, locationID: ObjectIdentifier, metatypeID: ObjectIdentifier)
//        case setPossibilities([CustomNavigationDestinationResolverBase], Int)
//        case boundPathChange(CustomAnyNavigationPath, EnvironmentValues)
//        case editingChanged(Bool, metatypeID: ObjectIdentifier)
//        case pop(Int)
//        case presentValue(CustomAnyNavigationLinkPresentedValue)
//        case replaceRootValue(CustomAnyNavigationLinkPresentedValue)
//        case replaceRootView(CustomAnyNavigationLinkPresentedView, AnyHashable, () -> ()) // Namespace.ID
//        case presentView(CustomAnyNavigationLinkPresentedView, AnyHashable, () -> (), Bool) // Namespace.ID
//        case updateView(CustomAnyNavigationLinkPresentedView, AnyHashable, Bool) // Namespace.ID
//        case clearSelectionAndPop(Int)
//        case presentValueInList(CustomAnyNavigationLinkPresentedValue, Bool)
//        case programmaticallyPresentView(CustomAnyNavigationLinkPresentedView, Int, AnyHashable, () -> ()) // Namespace.ID
//        case programmaticallyDismissView(AnyHashable) // Namespace.ID
//        case instantiateColumn
//        case resetRoot
//        case revealedBySubsequentPop
//        case popAllForSelectionChange
//    }
//
//    enum KeyKind {
//        case stack(CustomNavigationState.StackContent.Key)
//        case list(CustomNavigationState.ListKey)
//    }
//}
//
//enum CustomNavigationSplitColumn {
//    case sidebar
//    case content
//    case detail
//    case stack
//    case collapsed
//    case inspector
//}
//
//struct CustomNavigationViewDestinationView {
//    var wrappedValue: CustomAnyNavigationLinkPresentedView
//    var id: AnyHashable // Namespace.ID
//    var dismiss: () -> Void
//}
//
//struct CustomAnyNavigationLinkPresentedView {
//    var storage: CustomAnyNavigationLinkPresentedViewStorageBase
//
//}
//
//class CustomAnyNavigationLinkPresentedViewStorageBase {
//    // No props
//}
//
//struct CustomAnyNavigationLinkPresentedValue {
//    var storage: AnyNavigationLinkPresentedValueStorageBase
//}
//
//class AnyNavigationLinkPresentedValueStorageBase {
//    // Nessuna proprietà
//}
//
//// path
////@propertyWrapper
////struct CustomStateOrBinding {}
//struct CustomAnyNavigationPath {
//    var base: BoxBase
//
//    class BoxBase {}
//}

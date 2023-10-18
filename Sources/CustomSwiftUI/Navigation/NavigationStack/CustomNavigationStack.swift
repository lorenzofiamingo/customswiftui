import SwiftUI
import Combine
import Runtime

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@MainActor public struct CustomNavigationStack<Data, Root: View> {

    @StateObject private var localStateHost = CustomNavigationStateHost()

    @Binding private var data: Data

    private let root: Root

    //public init(path: Binding<CustomNavigationPath>, @ViewBuilder root: () -> Root) where Data == CustomNavigationPath {
    //    self._data = path
    //    self.root = root()
    //}
}

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomNavigationStack: View where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Data.Element: Hashable {

    public var body: some View {
        BridgedNavigationController(root: root, data: $data)
            .environmentObject(localStateHost)
            .environment(\.customParentNavigationState, localStateHost.navigationState)
    }

    public init(path: Binding<Data>, @ViewBuilder root: () -> Root) {
        self._data = path
        self.root = root()
    }
}

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct BridgedNavigationController<Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection, Root: View>: UIViewControllerRepresentable where Data.Element: Hashable {

    let root: Root

    @Binding var data: Data

    @EnvironmentObject private var navigationStateHost: CustomNavigationStateHost

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = UINavigationController()
        controller.delegate = context.coordinator
        DispatchQueue.main.async {
            navigationStateHost.navigationState = CustomNavigationState(destinations: [:], bindedDestinations: [:])
            navigationStateHost.initializedNavState = true
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        let currentRealPath = context.coordinator.currentRealPathBridged.map(\.path)
        var realPath: [RealPathElement] = currentRealPath
            .enumerated()
            .filter { (_, element) in
                switch element {
                case .root, .data:
                    return false
                default:
                    return true
                }
            }
            .reduce(into: [.root] + data.map { .data($0) }) { (path, pathElement) in
                let (offset, element) = pathElement
                if offset < path.count {
                    path.insert(element, at: offset)
                } else {
                    path.append(element)
                }
            }

        DispatchQueue.main.async {
            print("WWWbig", ObjectIdentifier(navigationStateHost))
            print("WWWbig", navigationStateHost.navigationState?.bindedDestinations.map({ key, value in
                (key, value.binding)
            }) ?? [])
        }

        for (id, isPresented) in navigationStateHost.navigationState?.bindedDestinations.map({ ($0, $1.binding) }) ?? [] {
            if isPresented && realPath.allSatisfy({ $0 != .binded(id)}) {
                print("WWWbig", isPresented, id)
                realPath.append(.binded(id))
            } else if !isPresented {
                realPath.removeAll(where: { $0 == .binded(id)})
            }
        }

        if realPath != currentRealPath {
            let difference = realPath.difference(from: currentRealPath)
            if !difference.isEmpty {
                for change in difference {
                    switch change {
                    case .insert(offset: let offset, element: let element, associatedWith: _):
                        let controller: UIViewController?
                        switch element {
                        case .root:
                            controller = InspectorController(rootView: root)
                        case .data(let data):
                            let destinationKey = ObjectIdentifier(type(of: data))
                            let destinationResolver = navigationStateHost.navigationState?.destinations[destinationKey] as? CustomNavigationDestinationResolver
                            controller = destinationResolver?.makeViewController(data: data)
                        case .binded(let id):
                            controller = navigationStateHost.navigationState?.bindedDestinations[id]?.resolver.makeViewController()
                        case .unbacked:
                            fatalError()
                        }
                        if let controller {
                            // --> This anticipate the invocation of the internal SwiftUI/UIKit bridging that happens in `viewDidAppear` of UIHostingController
                            controller.beginAppearanceTransition(true, animated: false)
                            controller.endAppearanceTransition()
                            // <--
                            context.coordinator.currentRealPathBridged.insert((element, controller), at: offset)
                        }
                    case .remove(offset: let offset, element: let element, associatedWith: _):
                        switch element {
                        case .root:
                            fatalError("Root should not be removed.")
                        case .data:
                            context.coordinator.currentRealPathBridged.remove(at: offset)
                        case .binded(_):
                            context.coordinator.currentRealPathBridged.remove(at: offset)
                        case .unbacked:
                            break
                        }
                    }
                }
                DispatchQueue.main.async {
                    uiViewController.setViewControllers(context.coordinator.currentRealPathBridged.map(\.viewController), animated: true)
                }
            }
        }

        DispatchQueue.main.async {
            for (element, viewController) in context.coordinator.currentRealPathBridged {
                switch element {
                case .root:
                    guard let viewController = viewController as? UIHostingController<Root> else { fatalError() }
                    viewController.rootView = root
                    // --> This tells UIHostingController to update view also if not showed
                    //viewController.viewDidAppear(false)
                    //viewController.viewWillDisappear(false)
                    // <--
                case .data(let data):
                    let destinationKey = ObjectIdentifier(type(of: data))
                    guard let destinationResolver = navigationStateHost.navigationState?.destinations[destinationKey] as? CustomNavigationDestinationResolver else { fatalError() }
                    // Check if updates state of destination view (rex must appear in path)
                    destinationResolver.updateViewController(viewController, data: data)
                case .binded(let id):
                    navigationStateHost.navigationState?.bindedDestinations[id]?.resolver.updateViewController(viewController)
                case .unbacked:
                    break
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(bridgedNavigationcontroller: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate {
        var currentRealPathBridged: [(path: RealPathElement, viewController: UIViewController)] = []

        var bridgedNavigationcontroller: BridgedNavigationController<Data, Root>

        init(bridgedNavigationcontroller: BridgedNavigationController<Data, Root>) {
            self.bridgedNavigationcontroller = bridgedNavigationcontroller
        }

        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            let showedViewControllerOffset = currentRealPathBridged.firstIndex { bridge in
                bridge.viewController === viewController
            }
            if let showedViewControllerOffset {
                let lastViewControllerToRemoveOffset = showedViewControllerOffset + 1
                for bridge in currentRealPathBridged[(lastViewControllerToRemoveOffset)...].reversed() {
                    if case .data(let element) = bridge.path {
                        let offset = bridgedNavigationcontroller.data.lastIndex { dataElement in
                            dataElement == element
                        }
                        if let offset {
                            bridgedNavigationcontroller.data.remove(at: offset)
                        }
                    }
                }
                let elementsToRemoveCount = currentRealPathBridged.count - lastViewControllerToRemoveOffset
                currentRealPathBridged.removeLast(elementsToRemoveCount)
            } else {
                currentRealPathBridged.append((.unbacked, viewController))
            }
        }
    }

    enum RealPathElement: Hashable {
        case root
        case data(Data.Element)
        case binded(UUID)
        case unbacked
    }
}

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class InspectorController<Root: View>: UIHostingController<Root> {

    override func viewWillDisappear(_ animated: Bool) {
        print("XXX", "View will disappear")
        DispatchQueue.main.async {
            self.viewWillAppear(animated)
            self.viewDidAppear(animated)
            self.loadView()
        }
        //super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("XXX", "View did disappear")
        //super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.viewWillAppear(animated)
            self.viewDidAppear(animated)
            self.loadView()
        }
    }


}

// Hashable -> NavigationDestinationModifier<C, EmptyView> destination is a function

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    public func customNavigationDestination<D: Hashable, C: View>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View {
        modifier(NavigationDestinationModifier(destination: destination))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct NavigationDestinationModifier<D: Hashable, C: View>: ViewModifier {

    @EnvironmentObject private var navigationStateHost: CustomNavigationStateHost
    @Environment(\.customParentNavigationState) private var navigationState

    let destination: (D) -> C

    func body(content: Content) -> some View {
        if navigationState == nil {
            content
        } else {
            content
                .onMake { _, _ in
                    let resolver = CustomNavigationDestinationResolver()
                    resolver.updateDestination(destination: destination)
                    navigationStateHost.navigationState!.destinations[ObjectIdentifier(D.self)] = resolver
                }
                .onUpdate { _, _ in
                    let destinationResolver = navigationStateHost.navigationState!.destinations[ObjectIdentifier(D.self)] as? CustomNavigationDestinationResolver
                    destinationResolver?.updateDestination(destination: destination)
                    //THis is called to late
                }
        }
    }
}


// isPresented -> ViewDestinationNavigationDestinationModifier<View> destination is a value, isPresented, namespace


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    public func customNavigationDestination<C: View>(isPresented: Binding<Bool>, @ViewBuilder destination: () -> C) -> some View {
        modifier(ViewDestinationNavigationDestinationModifier(isPresented: isPresented, destination: destination()))
    }
}

//NavigationDestinationModifier
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ViewDestinationNavigationDestinationModifier<C: View>: ViewModifier {

    @EnvironmentObject private var navigationStateHost: CustomNavigationStateHost
    @Environment(\.customParentNavigationState) private var navigationState

    @Binding var isPresented: Bool

    @State private var id = UUID()

    let destination: C

    func body(content: Content) -> some View {
        if navigationState == nil {
            content
        } else {
            content
                .onMake { _, _ in
                    let resolver = CustomViewDestinationNavigationDestinationResolver()
                    resolver.updateDestination(destination: { destination })
                    navigationStateHost.navigationState!.bindedDestinations[id] = (isPresented, resolver)
                }
                .onUpdate { _, _ in
                    let destination = navigationStateHost.navigationState!.bindedDestinations[id]
                    destination?.resolver.updateDestination(destination: { self.destination })
                    print("WWW", "Update \(isPresented)")
                }
                .customOnChange(of: isPresented) {
                    let destination = navigationStateHost.navigationState!.bindedDestinations[id]
                    navigationStateHost.navigationState!.bindedDestinations[id]?.binding = isPresented
                    destination?.resolver.updateDestination(destination: { self.destination })
                    print("WWW", ObjectIdentifier(navigationStateHost))
                    print("WWW", id, navigationStateHost.navigationState!.bindedDestinations[id]?.binding)
                    print("WWW", navigationStateHost.navigationState?.bindedDestinations.map({ key, value in
                        (key, value.binding)
                    }) ?? [])
                }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onUpdate(_ action: @escaping (EnvironmentValues, Transaction) -> Void) -> some View {
        background(OnUpdateView(onUpdate: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct OnUpdateView: UIViewRepresentable {

    private let onUpdate: (EnvironmentValues, Transaction) -> Void

    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        onUpdate(context.environment, context.transaction)
    }

    init(onUpdate: @escaping (EnvironmentValues, Transaction) -> Void) {
        self.onUpdate = onUpdate
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onMake(_ action: @escaping (EnvironmentValues, Transaction) -> Void) -> some View {
        background(OnMakeView(onMake: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct OnMakeView: UIViewRepresentable {

    private let onMake: (EnvironmentValues, Transaction) -> Void

    func makeUIView(context: Context) -> some UIView {
        onMake(context.environment, context.transaction)
        return UIView()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    init(onMake: @escaping (EnvironmentValues, Transaction) -> Void) {
        self.onMake = onMake
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    func onDismantle(_ action: @escaping () -> Void) -> some View {
        background(OnDismantleView(onDismantle: action))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct OnDismantleView: UIViewRepresentable {

    private let onDismantle: () -> Void

    func makeUIView(context: Context) -> UIView {
        UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> (() -> Void) {
        return onDismantle
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: () -> Void) {
        coordinator()
    }

    init(onDismantle: @escaping () -> Void) {
        self.onDismantle = onDismantle
    }
}

import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    @ViewBuilder func customOnChange<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping (V, V) -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, macCatalyst 17.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(OnChangeModifier(value: value, initial: initial, action: action))
        }
    }

    @ViewBuilder func customOnChange<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, macCatalyst 17.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else if #available(iOS 14.0, macOS 11, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, *), !initial {
            onChange(of: value) { _ in action() }
        } else {
            modifier(OnChangeModifier(value: value, initial: initial) { _, _ in action() })
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct OnChangeModifier<V: Equatable>: ViewModifier {

    @State private var oldValue: V

    private var value: V

    private var initial: Bool

    private var action: (V, V) -> Void

    init(value: V, initial: Bool, action: @escaping (V, V) -> Void) {
        self._oldValue = State(wrappedValue: value)
        self.value = value
        self.initial = initial
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onReceive(Just(value)) { (value) in
                if value != oldValue {
                    action(oldValue, value)
                    oldValue = value
                }
            }
            .onAppear {
                if initial {
                    action(oldValue, value)
                }
            }
    }
}


@propertyWrapper struct Updater: DynamicProperty {
    var wrappedValue: Void = ()

    func update() {
        print("WWW Updater updating")
    }
}

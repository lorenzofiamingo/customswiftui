import SwiftUI

// _parentNavigationState in environment
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomNavigationState {
    
    var destinations: [ObjectIdentifier: CustomNavigationDestinationResolverBase]

    var bindedDestinations: [UUID: (binding: Binding<Bool>, resolver: CustomViewDestinationNavigationDestinationResolver)]
}

class CustomNavigationDestinationResolverBase {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class CustomNavigationDestinationResolver: CustomNavigationDestinationResolverBase {

    private var _destination: ((any Hashable) -> any View)!

    private var _makeUIViewController: ((any Hashable) -> UIViewController)!

    private var _updateUIViewController: ((UIViewController, any Hashable) -> Void)!

    func updateDestination<D, V: View>(destination: @escaping (D) -> V) {
        self._destination = { data in
            guard let data = data as? D else {
                assertionFailure("Data type was not correct")
                if #available(iOS 15.0, *) {
                    return Image(systemName: "exclamationmark.triangle").symbolVariant(.fill).symbolRenderingMode(.multicolor).font(.largeTitle)
                } else {
                    return Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow).font(.largeTitle)
                }
            }
            return destination(data)
        }
        self._makeUIViewController = { data in
            guard let view = self._destination(data) as? V else {
                assertionFailure("View type was not correct")
                return UIViewController()
            }
            return UIHostingController(rootView: view)
        }
        self._updateUIViewController = { uiViewController, data in
            guard let hostingController = uiViewController as? UIHostingController<V> else {
                return
            }
            guard let view = self._destination(data) as? V else {
                return
            }
            hostingController.rootView = view
        }
    }

    func makeViewController(data: some Hashable) -> UIViewController {
        _makeUIViewController(data)
    }

    func updateViewController(_ uiViewController: UIViewController, data: some Hashable) {
        _updateUIViewController(uiViewController, data)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class CustomViewDestinationNavigationDestinationResolver: CustomNavigationDestinationResolverBase {

    private var _destination: (() -> any View)!

    private var _makeUIViewController: (() -> UIViewController)!

    private var _updateUIViewController: ((UIViewController) -> Void)!

    func updateDestination<V: View>(destination: @escaping () -> V) {
        self._destination = destination
        self._makeUIViewController = {
            guard let view = self._destination() as? V else {
                assertionFailure("View type was not correct")
                return UIViewController()
            }
            return UIHostingController(rootView: view)
        }
        self._updateUIViewController = { uiViewController in
            guard let hostingController = uiViewController as? UIHostingController<V> else {
                return
            }
            guard let view = self._destination() as? V else {
                return
            }
            hostingController.rootView = view
        }
    }

    func makeViewController() -> UIViewController {
        _makeUIViewController()
    }

    func updateViewController(_ uiViewController: UIViewController) {
        _updateUIViewController(uiViewController)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomNavigationStateKey: EnvironmentKey {
    static var defaultValue: CustomNavigationState? = nil
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    var customParentNavigationState: CustomNavigationState? {
        get { self[CustomNavigationStateKey.self] }
        set { self[CustomNavigationStateKey.self] = newValue }
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomScrollViewConfiguration {
    var axes: Axis.Set = .vertical

    var scrollCoordinator = ScrollCoordinator()
//    var showsIndicators: Bool = true
//    var alwaysBounceAxes: Axis.Set = .all
//    var contentInsets: EdgeInsets = EdgeInsets()
//    var onScrollToTopGesture:
//    var safeAreaTransitionState:
//    var refreshAction:
//    var interactionActivityTag:

    class ScrollCoordinator {
        var uiScrollView: UIScrollView?
        var contentMargins = EdgeInsets()
        var onScroll: [UUID: () -> Void] = [:]
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomScrollViewConfigurationKey: EnvironmentKey {

    static var defaultValue: CustomScrollViewConfiguration? {
        nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {

    var customScrollViewConfiguration: CustomScrollViewConfiguration? {
        get { self[CustomScrollViewConfigurationKey.self] }
        set { self[CustomScrollViewConfigurationKey.self] = newValue }
    }
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol CustomViewParser: DynamicProperty {
    
    associatedtype Output
    
    func parse(customView: any CustomView) -> [CustomViewOutput]
    
    func parse(customViewOutputs: [CustomViewOutput]) -> [ViewOutput]
    
    func parse(viewOutputs: [ViewOutput]) -> [DynamicViewOutput]
    
    func parse(dynamicViewOutputs: [DynamicViewOutput]) -> Output
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomViewParser {
    
    typealias Action = ParseCustomViewAction<Output>
    
    var action: Action {
        Action { customView in
            let customViewOutputs = parse(customView: customView)
            let viewOutputs = parse(customViewOutputs: customViewOutputs)
            let dynamicViewOutputs = parse(viewOutputs: viewOutputs)
            let output = parse(dynamicViewOutputs: dynamicViewOutputs)
            return output
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomViewParser {
    
    func parse(customView: any CustomView) -> [CustomViewOutput] {
        [CustomViewOutput(customView: customView, path: CustomPath())].flatMap(parse)
    }
    
    private func parse(customViewOutput: CustomViewOutput) -> [CustomViewOutput] {
        if let customViewOutputProvider = customViewOutput.customView as? CustomViewOutputProvider {
            return customViewOutputProvider.makeViewOutputs(path: customViewOutput.path).flatMap(parse)
        } else if customViewOutput.customView is ViewOutputProvider {
            return [customViewOutput]
        } else {
            return parse(customViewOutput: CustomViewOutput(customView: customViewOutput.customView.customBody, path: customViewOutput.path))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomViewParser {
    
    func parse(customViewOutputs: [CustomViewOutput]) -> [ViewOutput] {
        customViewOutputs.flatMap { customViewOutput in
            if let viewOutputProvider = customViewOutput.customView as? ViewOutputProvider  {
                return viewOutputProvider.makeViewOutputs(path: customViewOutput.path)
            } else {
                return []
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomViewParser {
    
    func parse(viewOutputs: [ViewOutput]) -> [DynamicViewOutput] {
        viewOutputs
                .map { DynamicViewOutput(view: $0.view, path: $0.path, defaultValue: nil) }
                .flatMap(parse)
    }
    
    private func parse(dynamicViewOutput: DynamicViewOutput) -> [DynamicViewOutput] {
        if let dynamicViewOutputProvider = dynamicViewOutput.view as? any DynamicViewOuputProvider {
            return dynamicViewOutputProvider.makeDynamicViewOutputs(path: dynamicViewOutput.path).flatMap(parse)
        } else {
            return [dynamicViewOutput]
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ParseCustomViewAction<Output> {
    
    private let action: (any CustomView) -> Output
    
    func callAsFunction(_ customView: any CustomView) -> Output  {
        action(customView)
    }
    
    init(action: @escaping (any CustomView) -> Output) {
        self.action = action
    }
}


// MARK: - CustomViewOutput

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomViewOutput {
    
    let customView: any CustomView
    
    let path: CustomPath
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private protocol CustomViewOutputProvider {
    
    func makeViewOutputs(path: CustomPath) -> [CustomViewOutput]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderPair: CustomViewOutputProvider where FirstContent: CustomView, SecondContent: CustomView {
    
    func makeViewOutputs(path: CustomPath) -> [CustomViewOutput] {
        [
            CustomViewOutput(customView: first, path: path.appending(.pairFirst)),
            CustomViewOutput(customView: second, path: path.appending(.pairSecond))
        ]
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderConditional: CustomViewOutputProvider where TrueContent: CustomView, FalseContent: CustomView {
    
    func makeViewOutputs(path: CustomPath) -> [CustomViewOutput] {
        switch storage {
        case let .trueContent(view):
            return [CustomViewOutput(customView: view, path: path.appending(.conditionalTrue))]
        case let .falseContent(view):
            return [CustomViewOutput(customView: view, path: path.appending(.conditionalFalse))]
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Optional: CustomViewOutputProvider where Wrapped: CustomView {
    
    func makeViewOutputs(path: CustomPath) -> [CustomViewOutput] {
        switch self {
        case .some(let view):
            return [CustomViewOutput(customView: view, path: path)]
        case .none:
            return[]
        }
    }
}

// MARK: - ViewOutput

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct ViewOutput {
    
    let view: any View
    
    let path: CustomPath
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private protocol ViewOutputProvider {
    
    func makeViewOutputs(path: CustomPath) -> [ViewOutput]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomBuilderBridge: ViewOutputProvider where Content: View {
    
    func makeViewOutputs(path: CustomPath) -> [ViewOutput] {
        [ViewOutput(view: content, path: path)]
    }
}

// MARK: - DynamicViewOutput

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct DynamicViewOutput {
    
    let view: any View
    
    let path: CustomPath
    
    let defaultValue: (any Hashable)?
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private protocol DynamicViewOuputProvider {
    
    associatedtype Data: RandomAccessCollection
    
    associatedtype ID: Hashable
    
    associatedtype Content: View
    
    var dataProxy: Data { get }
    
    var contentProxy: (Data.Element) -> Content { get }
    
    var idGeneratorProxy: CustomIDGenerator<Data.Element, ID>? { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension DynamicViewOuputProvider {
    
    func makeDynamicViewOutputs(path: CustomPath) -> [DynamicViewOutput] {
        dataProxy.enumerated().map { (offset, element) in
            let defaultValue: (any Hashable)?
            switch idGeneratorProxy {
            case .offset:
                defaultValue = offset
            case .keyPath(let keyPath):
                defaultValue = element[keyPath: keyPath]
            case .none:
                defaultValue = nil
            }
            let view = contentProxy(element)
            return DynamicViewOutput(view: view, path: path.appending(.forEach(offset: offset)), defaultValue: defaultValue)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomForEach: DynamicViewOuputProvider where Content: View {
    
    var dataProxy: Data {
        data
    }
    
    var contentProxy: (Data.Element) -> Content {
        content
    }
    
    var idGeneratorProxy: IDGenerator? {
        idGenerator
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ForEach: DynamicViewOuputProvider where Content: View {
    
    var dataProxy: Data {
        data
    }
    
    var contentProxy: (Data.Element) -> Content {
        content
    }
    
    var idGeneratorProxy: CustomIDGenerator<Data.Element, ID>? {
        nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ModifiedContent: DynamicViewOuputProvider where Content: DynamicViewOuputProvider, Modifier: ViewModifier {
    
    var dataProxy: Content.Data {
        content.dataProxy
    }
    
    var contentProxy: (Content.Data.Element) -> ModifiedContent<Content.Content, Modifier> {
        { content.contentProxy($0).modifier(modifier) }
    }
    
    var idGeneratorProxy: CustomIDGenerator<Content.Data.Element, Content.ID>? {
        content.idGeneratorProxy
    }
}

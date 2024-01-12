import SwiftUI

@resultBuilder public struct CustomContentBuilder {
    
    public static func buildExpression<Content>(_ content: Content) -> CustomBuilderBridge<Content> {
        CustomBuilderBridge(content: content)
    }
    
    public static func buildPartialBlock<T>(first content: T) -> T {
        content
    }
    
    public static func buildPartialBlock<T1, T2>(accumulated: T1, next: T2) -> CustomBuilderPair<T1, T2> {
        CustomBuilderPair(first: accumulated, second: next)
    }
    
    public static func buildBlock() -> CustomBuilderEmpty {
        CustomBuilderEmpty()
    }
    
    public static func buildIf<T>(_ content: T?) -> T? {
        content
    }
    
    public static func buildEither<T1, T2>(first: T1) -> CustomBuilderConditional<T1, T2> {
        CustomBuilderConditional(storage: .trueContent(first))
    }
    
    public static func buildEither<T1, T2>(second: T2) -> CustomBuilderConditional<T1, T2> {
        CustomBuilderConditional(storage: .falseContent(second))
    }
    
    public static func buildLimitedAvailability<T>(_ content: T) -> T {
        content
    }
}

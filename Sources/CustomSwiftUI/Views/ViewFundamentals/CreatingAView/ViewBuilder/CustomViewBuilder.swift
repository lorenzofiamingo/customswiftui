import SwiftUI

public typealias CustomViewBuilder = CustomContentBuilder

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CustomViewBuilder {
    
    public static func buildExpression<T: CustomView>(_ content: T) -> T {
        content
    }
}

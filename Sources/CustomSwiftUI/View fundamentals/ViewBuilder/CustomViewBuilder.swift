import SwiftUI

public typealias CustomViewBuilder = CustomContentBuilder

extension CustomViewBuilder {
    
    public static func buildExpression<T: CustomView>(_ content: T) -> T {
        content
    }
}

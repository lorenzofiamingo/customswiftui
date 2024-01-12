import SwiftUI

public protocol CustomTraitKey {

    associatedtype Value: Equatable

    static var defaultValue: Value { get }
    
    static func reduce(value: inout Value, nextValue: () -> Value)
}

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomCombinedVisualEffect<First: CustomVisualEffect, Second: CustomVisualEffect>: CustomVisualEffect {
    var first: First
    var second: Second

    var animatableData: AnimatablePair<First.AnimatableData, Second.AnimatableData> {
        get {
            AnimatablePair(first.animatableData, second.animatableData)
        } set {
            first.animatableData = newValue.first
            second.animatableData = newValue.second
        }
    }

    static func _makeModifier(effect: CustomCombinedVisualEffect<First, Second>?) -> some ViewModifier {
        First._makeModifier(effect: effect?.first).concat(Second._makeModifier(effect: effect?.second))
    }
}

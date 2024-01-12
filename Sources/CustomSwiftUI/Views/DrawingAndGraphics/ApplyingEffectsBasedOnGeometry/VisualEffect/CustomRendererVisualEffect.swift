import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CustomRendererVisualEffect<Base: CustomVisualEffect>: CustomVisualEffect {

    var base: Base

    var animatableData: Base.AnimatableData {
        get {
            base.animatableData
        } set {
            base.animatableData = newValue
        }
    }

    static func _makeModifier(effect: CustomRendererVisualEffect<Base>?) -> some ViewModifier {
        Base._makeModifier(effect: effect?.base)
    }
}

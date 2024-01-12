import SwiftUI

struct CustomTraitKeyPreferenceKey<Key: CustomTraitKey>: PreferenceKey {

    static var defaultValue: Key.Value? {
        nil
    }

    static func reduce(value: inout Key.Value?, nextValue: () -> Key.Value?) {
        if var _value = value, let nextValue = nextValue() {
            Key.reduce(value: &_value) { nextValue }
            value = _value
        }
    }
}

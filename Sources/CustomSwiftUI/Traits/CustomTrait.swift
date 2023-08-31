import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    public func customTrait<K: CustomTraitKey>(key: K.Type = K.self, value: K.Value) -> some View {
        modifier(CustomTraitWritingModifier<K>(value: value))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    public func customOnTraitChange<K: CustomTraitKey>(_ key: K.Type = K.self, perform action: @escaping (K.Value) -> Void) -> some View where K.Value: Equatable {
        modifier(CustomTraitReadingModifier<K>(readTraitAction: action))
    }
}

private struct CustomTraitKeyPreferenceKey<Key: CustomTraitKey>: PreferenceKey {
    
    static var defaultValue: Key.Value? {
        nil
    }

    static func reduce(value: inout Key.Value?, nextValue: () -> Key.Value?) {
        var _value = value ?? Key.defaultValue
        Key.reduce(value: &_value) { nextValue() ?? Key.defaultValue }
        value = _value
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomTraitReadingModifier<Key: CustomTraitKey>: ViewModifier where Key.Value: Equatable {
    
    private let readTraitAction: (Key.Value) -> Void
    
    init(readTraitAction: @escaping (Key.Value) -> Void) {
        self.readTraitAction = readTraitAction
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(CustomTraitKeyPreferenceKey<Key>.self) { trait in
                readTraitAction(trait ?? Key.defaultValue)
            }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct CustomTraitWritingModifier<Key: CustomTraitKey>: ViewModifier {
    
    private let value: Key.Value
    
    init(value: Key.Value) {
        self.value = value
    }
    
    func body(content: Content) -> some View {
        content
            .transformPreference(CustomTraitKeyPreferenceKey<Key>.self) { trait in
                if trait == nil {
                    trait = value
                }
            }
    }
}

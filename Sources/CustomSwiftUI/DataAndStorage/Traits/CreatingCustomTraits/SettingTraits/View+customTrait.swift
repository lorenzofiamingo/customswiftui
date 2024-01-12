import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    public func customTrait<K: CustomTraitKey>(key: K.Type = K.self, value: K.Value) -> some View {
        modifier(CustomTraitWritingModifier<K>(value: value))
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

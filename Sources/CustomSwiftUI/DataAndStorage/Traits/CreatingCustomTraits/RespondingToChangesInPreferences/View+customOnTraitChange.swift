import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    public func customOnTraitChange<K: CustomTraitKey>(_ key: K.Type = K.self, perform action: @escaping (K.Value) -> Void) -> some View where K.Value: Equatable {
        modifier(CustomTraitReadingModifier<K>(readTraitAction: action))
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

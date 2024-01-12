import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Binds a view's identity to the given proxy value.
    ///
    /// When the proxy value specified by the `id` parameter changes, the
    /// identity of the view — for example, its state — is reset.
    public func customID<ID: Hashable>(_ id: ID) -> some View {
        transformPreference(CustomIDValuesKey.self) { values in
            if values.ids[ObjectIdentifier(ID.self)] == nil {
                values.ids[ObjectIdentifier(ID.self)] = id
            }
        }
    }

    func customID(_ id: (any Hashable)?) -> some View {
        transformPreference(CustomIDValuesKey.self) { values in
            if let id, values.ids[ObjectIdentifier(type(of: id))] == nil {
                values.ids[ObjectIdentifier(type(of: id))] = AnyHashable(id)
            }
        }
    }
}

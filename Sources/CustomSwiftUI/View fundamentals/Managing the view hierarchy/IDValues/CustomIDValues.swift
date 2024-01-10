import SwiftUI

struct CustomIDValues: Hashable {

    var ids: [ObjectIdentifier: AnyHashable] = [:]
}

struct CustomIDValuesKey: PreferenceKey {

    static var defaultValue: CustomIDValues {
        CustomIDValues()
    }

    static func reduce(value: inout CustomIDValues, nextValue: () -> CustomIDValues) {
        value = CustomIDValues()
    }
}

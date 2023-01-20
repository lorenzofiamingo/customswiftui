enum CustomTagValue<V: Hashable>: Equatable {
    
    case untagged
    
    case tagged(V)
}

struct CustomTagValueKey<V: Hashable>: CustomTraitKey {
    
    static var defaultValue: CustomTagValue<V> {
        .untagged
    }
    
    static func reduce(value: inout CustomTagValue<V>, nextValue: () -> CustomTagValue<V>) {
        value = .untagged
    }
}

// How tag works in SwiftUI in conjuction to Picker.
// Starting from most internal tag SwiftUI matches the first tag having SelectionValue as type.
// If SwiftUI doesn't find a tag it tries to use the id of the ForEach if ID is equal to SelectionValue.
// If tag is inside a stack the stack doesn't inherit the child tag.
// If tag is inside a _ConditionalContent the tag is mainteined.

// PreferenceKey onPreferenceChange takes the outermost tag.
// EnvironmentKey is unable to use generics.

// Solution use onPreferenceChange under preference to take the inner if present

// Better solution implement CustomTrait? possibile

// ModifiedContent<Spacer, _TraitWritingModifier<TagValueTraitKey<Int>>>


// _EnvironmentKeyWritingModifier -> sovrascrivere un valore nell'environment del figlio (verrà letto dal figlio)
// _EnvironmentKeyTransformModifier -> trasforma un valore nell'environment del figlio (verrà letto dal figlio)
// _PreferenceWritingModifier  -> sovrascrivere una preference del figlio (verrà letto dal padre)
// _PreferenceTransformModifier -> trasforma una preference del figlio (verrà letto dal padre) (ecco a che serve una defaultValue qui)
// TransactionalPreferenceTransformModifier -> forse per animare una _PreferenceTransformModifier
// _TraitWritingModifier -> sovrascrivere un trait del padre (verrà letto dal padre)
// _TraitTransformModifier -> trasforma un trait del padre (verrà letto dal padre)

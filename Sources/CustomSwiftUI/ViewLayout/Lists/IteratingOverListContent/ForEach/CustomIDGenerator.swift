/// An enumeration to generate stable identity using the underlying data.
enum CustomIDGenerator<Element, ID> {
    
    case offset
    
    case keyPath(KeyPath<Element, ID>)
}

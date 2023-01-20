struct CustomPath: Hashable {
    
    private let elements: [Element]
    
    private init(_ elements: [Element]) {
        self.elements = elements
    }
}

extension CustomPath {
    
    enum Element: Hashable {
        
        case pairFirst
        
        case pairSecond
        
        case conditionalTrue
        
        case conditionalFalse
        
        case forEach(offset: Int)
    }
}

extension CustomPath {
    
    init(_ elements: Element...) {
        self.elements = elements
    }
}

extension CustomPath {
    
    func appending(_ elements: Element...) -> CustomPath {
        CustomPath(self.elements + elements)
    }
}

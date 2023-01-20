struct CustomNamespace {
    
    public typealias ID = Int
    
    let id: ID
    
    fileprivate init(id: ID) {
        self.id = id
    }
}

class CustomNamespaceGenerator {
    
    private var cache: [CustomPath: CustomNamespace] = [:]
    
    private var transientCache: [CustomPath: CustomNamespace] = [:]
    
    func generate(forPath path: CustomPath) -> CustomNamespace {
        let namespace = cache[path] ?? Self.generateNamespace()
        transientCache[path] = namespace
        return namespace
    }
    
    func update() {
        cache = transientCache
        transientCache.removeAll()
    }
}

extension CustomNamespaceGenerator {
    
    private static var lastID: CustomNamespace.ID = 0
    
    private static func generateNamespace() -> CustomNamespace {
        lastID += 1
        return CustomNamespace(id: lastID)
    }
}

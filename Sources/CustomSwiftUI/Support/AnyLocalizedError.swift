import Foundation

struct AnyLocalizedError: LocalizedError {
    
    let errorDescription: String?
    
    let failureReason: String?
    
    let recoverySuggestion: String?
    
    let helpAnchor: String?
}

extension AnyLocalizedError {
    
    init(erasing localizedError: LocalizedError) {
        errorDescription = localizedError.errorDescription
        failureReason = localizedError.failureReason
        recoverySuggestion = localizedError.recoverySuggestion
        helpAnchor = localizedError.helpAnchor
    }
}

extension AnyLocalizedError {
    
    init(error: Error) {
        if let localizedError = error as? LocalizedError {
            self.init(erasing: localizedError)
        } else {
            self.init(
                errorDescription: error.localizedDescription,
                failureReason: nil,
                recoverySuggestion: nil,
                helpAnchor: nil
            )
        }
    }
}

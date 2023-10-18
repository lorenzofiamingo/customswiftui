import SwiftUI

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension View {
    
    public func customTask(priority: TaskPriority = .userInitiated, _ action: @escaping () async throws -> Void) -> some View {
        modifier(CustomTaskViewModifier(priority: priority, action: action))
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
struct CustomTaskViewModifier: ViewModifier {
    
    let priority: TaskPriority
    
    let action: () async throws -> Void
    
    @State private var showingErrorAlert = false
    
    @State private var localizedError: AnyLocalizedError?
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            defaultBody(content: content)
        } else {
            fallbackBody(content: content)
        }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    @ViewBuilder private func defaultBody(content: Content) -> some View {
        content
            .onAppear {
                Task(priority: priority) {
                    do {
                        try await action()
                    } catch {
                        self.localizedError = AnyLocalizedError(error: error)
                        showingErrorAlert = true
                    }
                }
            }
            .alert(isPresented: $showingErrorAlert, error: localizedError) { error in
                Button("OK") {
                    showingErrorAlert = false
                }
            } message: { error in
                if let message = error.failureReason ?? error.recoverySuggestion ?? error.helpAnchor {
                    Text(message)
                }
            }
    }
    
    @ViewBuilder private func fallbackBody(content: Content) -> some View {
        content
            .onAppear {
                Task(priority: priority) {
                    try await action()
                }
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text(localizedError?.errorDescription ?? ""),
                    message: (localizedError?.failureReason ?? localizedError?.recoverySuggestion ?? localizedError?.helpAnchor).map(Text.init),
                    dismissButton: .default(Text("OK")) { showingErrorAlert = false }
                )
            }
    }
}

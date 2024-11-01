import Foundation

actor FirestoreOperationQueue {
    private var operations: [() async throws -> Void] = []
    private var isProcessing = false
    
    func enqueue(_ operation: @escaping () async throws -> Void) {
        operations.append(operation)
        Task {
            await processQueue()
        }
    }
    
    private func processQueue() async {
        guard !isProcessing else { return }
        isProcessing = true
        
        while !operations.isEmpty {
            let operation = operations.removeFirst()
            do {
                try await operation()
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay between operations
            } catch {
                print("Operation failed: \(error.localizedDescription)")
            }
        }
        
        isProcessing = false
    }
} 
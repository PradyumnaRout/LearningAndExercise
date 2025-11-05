//
//  CancellationAndErrorHandlingPart7.swift
//  LearningAndExercise
//
//  Created by hb on 05/11/25.
//

import Foundation
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-7-cancellation-error-handling-523ee97a4e27

// MARK: - Cancellation and Error Handling.
/**
 ✅ Best Practices
 • Always check for cancellation (Task.isCancelled or Task.checkCancellation()).
 • Use withTaskCancellationHandler for cleanup logic.
 • Cancel tasks when leaving a view (.onDisappear).
 • Treat cancellation differently from errors.
 • Catch specific errors (URLError, CancellationError) for clarity.
 ⚠️ Common Pitfalls
 • Forgetting to cancel tasks → wasted resources.
 • Treating cancellation as an error → wrong UX.
 • Ignoring cleanup → timers, streams, and delegates may leak.
 • Cancelling child tasks incorrectly in structured concurrency.
 ✅ Key Takeaways
 • Cancellation in Swift is cooperative → tasks must check and stop.
 • Use Task.isCancelled, Task.checkCancellation(), or withTaskCancellationHandler.
 • Error handling works naturally with try/throw in async/await.
 • Cancellation ≠ Error → handle them separately for correct UX.
 • In real-world apps, always cancel stale tasks (search, network, timers).
 */


struct CancellationAndErrorHandling {
    // 🔹 How Task Cancellation Works in Swift
    // Cancelling a task does not kill it immediately.
    // Instead, tasks check Task.isCancelled and exit themselves.
    func isCancellationCheck() {
        Task {
            for i in 0...5 {
                try await Task.sleep(nanoseconds: 1_000_000_000)
//                try Task.checkCancellation()      // ✅ Throws if cancelled
                if Task.isCancelled {               // Check for task cancellation.
                    print("❌ Task was cancelled at iteration \(i)")
                    return
                }
                print("✅ Fetched Item: \(i)")
            }
        }
        
        /**
         If we call .cancel() on this task after 2 seconds:
         ✅ Fetched item 1
         ✅ Fetched item 2
         ❌ Task was cancelled at iteration 3
         */
    }
    
    //🔹 Using withTaskCancellationHandler
    // Sometimes, task need cleanup code when cancelled (e.g., stop a timer, close a stream, free memory).
    func useWithTaskCancellationHandler() {
        Task {
            do {
                try await withTaskCancellationHandler {
                    // 👇 Task body
                    for i in 1...10 {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        print("⏳ Tick \(i)")
                    }
                } onCancel: {
                    // 👇 Cleanup when task is cancelled
                    print("🧹 Cleanup: Task cancelled")
                }
            } catch {
                print("Error occured")
            }
        }
        
        /**
         If cancelled mid-way:
         ⏳ Tick 1
         ⏳ Tick 2
         🧹 Cleanup: Task cancelled
         */
    }
}

// 🔹 Real-World SwiftUI Example: Search with Cancellation
import SwiftUI

struct SearchView: View {
    
    @State private var query = ""
    @State private var results: [String] = []
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            TextField("Search...", text: $query)
                .onChange(of: query) { oldValue, newValue in
                    searchTask?.cancel()    // Cancel the old task
                    searchTask = Task {
                        do {
                            let reuslt = try await performSearch(newValue)
                            results.append(reuslt)
                        } catch is CancellationError {
                            print("🔎 Search cancelled")
                        } catch {
                            print("❌ Search failed:", error)
                        }
                    }
                }
            
            List(results, id: \.self) { item in
                Text(item)
            }
        }
    }
    
    func performSearch(_ query: String) async throws -> String {
        try Task.checkCancellation()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if query.isEmpty { return "" }
        return query
    }
}



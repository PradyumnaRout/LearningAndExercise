//
//  CancellationAndErrorHandlingPart7.swift
//  LearningAndExercise
//
//  Created by hb on 05/11/25.
//

import Foundation
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-7-cancellation-error-handling-523ee97a4e27

// https://dev.to/arshtechpro/structured-and-unstructured-tasks-in-swift-5cgi

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

/**
 ➡️➡️➡️ Comapring Task.cancel() with dispatchworkItem.cancel() ⬅️⬅️⬅️
 Task.cancel() in Swift concurrency works very similarly to DispatchWorkItem.cancel()

 • Both: Do not forcibly stop execution.
 • Only mark the task/work item as cancelled.
 • Rely on cooperative cancellation, meaning the work must check for cancellation and exit.
 
 So yes:
 task.cancel() does not stop the task by force — it only sets a cancellation flag (isCancelled = true).

 🧠 Deeper Explanation: How Swift Task.cancel() Actually Works
 When you call:
 task.cancel(), Swift sets an internal flag: Task.isCancelled == true, But the task will keep running until: It explicitly checks Task.isCancelled

 It hits an await point that can throw CancellationError
 (e.g., Task.sleep, URLSession.shared.data, etc.)

 You call Task.checkCancellation() inside the task. If the task never checks cancellation, it will continue running.

 This is intentional — Swift uses cooperative cancellation, not forced cancellation.
 
 🧩 Comparison Table
 
 | Feature                             | `Task.cancel()` (Swift Concurrency) | `DispatchWorkItem.cancel()` |
 | ----------------------------------- | ----------------------------------- | --------------------------- |
 | Forcibly stops work?                | ❌ No                                | ❌ No                        |
 | Sets an internal cancellation flag? | ✅ Yes (`Task.isCancelled`)          | ✅ Yes (`isCancelled`)       |
 | Automatically stops at safe points? | ⚠️ Only if awaited call checks      | ❌ Never                     |
 | Can throw cancellation error?       | ✅ Yes (e.g., `Task.sleep`)          | ❌ No                        |
 | Cooperative cancellation required?  | ✅ Yes                               | ✅ Yes                       |

 
 
 
 
 Important example
 
 let task = Task {
     for i in 0...5 {
         try await Task.sleep(nanoseconds: 1_000_000_000)
         print("✅ Fetched Item: \(i)")
     }
 }

 Task {
     try await Task.sleep(nanoseconds: 2_000_000_000)
     print("🛑 Cancelling task...")
     task.cancel()
 }
 🔍 What happens in real execution
 Timeline:
 Time    Action
 0s    Task starts, enters loop
 1s    prints: Fetched Item: 0
 2s    prints: Fetched Item: 1
 2s    second task fires, prints "Cancelling task..."
 2s    calls task.cancel() → sets isCancelled = true
 3s    main task wakes from sleep → Task.sleep checks cancellation!

 ✅ Because Task.sleep is a cancellation point, the next sleep call throws CancellationError.

 ⭐ Important: You are NOT catching the error
 Your task will crash (terminate immediately) when cancellation happens because there is no do/catch.

 It will not print iteration 2 or anything after.

 📌 Actual Output
 The output will be:

 ✅ Fetched Item: 0
 ✅ Fetched Item: 1
 🛑 Cancelling task...
 Then the main task throws CancellationError during the 3rd sleep and stops without printing anything else.

 ✔️ If you want to see the cancellation clearly
 You need to catch the error:

 swift
 Copy code
 let task = Task {
     do {
         for i in 0...5 {
             try await Task.sleep(nanoseconds: 1_000_000_000)
             print("✅ Fetched Item: \(i)")
         }
     } catch {
         print("❌ Task cancelled")
     }
 }
 Then the output becomes:

 yaml
 Copy code
 ✅ Fetched Item: 0
 ✅ Fetched Item: 1
 🛑 Cancelling task...
 ❌ Task cancelled
 ✔️ Final Summary
 Without error handling → prints:
 nginx
 Copy code
 Fetched 0
 Fetched 1
 Cancelling...
 Then silently stops because of a thrown cancellation error.

 With error handling → prints:
 arduino
 Copy code
 Fetched 0
 Fetched 1
 Cancelling...
 Task cancelled
 */

struct CancellationAndErrorHandling {
    // 🔹 How Task Cancellation Works in Swift
    // Cancelling a task does not kill it immediately.
    // Instead, tasks check Task.isCancelled and exit themselves.
    func isCancellationCheck() {
        let task = Task {
            for i in 0...5 {
                try await Task.sleep(nanoseconds: 1_000_000_000)        // Task.sleep is a cancellation point, the next sleep call throws CancellationError.
                
                //                try Task.checkCancellation()      // ✅ Throws if cancelled
                
                
//                if Task.isCancelled {               // Check for task cancellation.
//                    print("❌ Task was cancelled at iteration \(i)")
//                    return
//                }
                print("✅ Fetched Item: \(i)")
            }
        }
        
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("🛑 Cancelling task...")
            task.cancel()
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
        let task = Task {
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
        
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("🛑 Cancelling task...")
            task.cancel()
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

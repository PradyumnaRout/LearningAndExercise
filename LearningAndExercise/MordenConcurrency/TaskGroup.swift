//
//  TaskGroup.swift
//  LearningAndExercise
//
//  Created by hb on 04/11/25.
//

import Foundation
import UIKit
import SwiftUI
// Task Group - https://ahmadgsufi.medium.com/taskgroup-7e73ecea1a6

/*
 ✅ Why Use TaskGroup?

 Here are the main reasons:

 1. Run many tasks at the same time (in parallel):
 If you want to perform async work on multiple items (like downloading files or processing data), TaskGroup lets all those tasks run concurrently.

 2. Automatically wait for all tasks to finish:
 With TaskGroup, you don’t manually track when each task is done. The group handles it for you — you just collect the results.

 3. Better structured code:
 All tasks in the group are contained within one scope (withTaskGroup), making your code clean and easy to manage.

 4. Safe and cancellable:
 If the parent task is cancelled, all child tasks in the group are automatically cancelled too.
 
 🔍 When Should You Use TaskGroup?
 
 | Use Case                                     | Use `TaskGroup`?                   |
 | -------------------------------------------- | ---------------------------------- |
 | Run independent tasks in parallel            | ✅ Yes                              |
 | Wait for all async tasks to finish           | ✅ Yes                              |
 | Manage child task cancellation automatically | ✅ Yes                              |
 | Run one async task only                      | ❌ No (just use `await`)            |
 | Want ordered results like `.map`             | ⚠ Build your own or use `asyncMap` |

 
 ✅ In Short

 TaskGroup is used to:

 ✔ Run many async tasks in parallel
 ✔ Collect their results
 ✔ Keep concurrency safe and structured
 ✔ Simplify cancellation and error handling
 */

class WhyTaskGroup {
    func downloadImage( from url: URL) async -> UIImage {
        // Pretend downloading
        return UIImage()
    }
    
    func gromTaskGroup() {
        let urls = ["url1", "url2", "url3"]
        Task {
            var images: [UIImage] = []
            
            await withTaskGroup(of: UIImage.self) { group in
                for url in urls {
                    group.addTask {
                        await self.downloadImage(from: URL(string: url)!)
                    }
                }
                
                for await image in group {
                    images.append(image)
                }
            }
            print("Downloaded images: \(images.count)")
        }
    }
}

/*
 🔹 Two Types of Task Groups
 
 Type                                       Handles Errors?                             Example
 TaskGroup                   ❌ No (errors are ignored or must be                withTaskGroup(of: Int.self)
                            handled inside task manually)
 ThrowingTaskGroup          ✅ Yes (errors can be thrown, caught, and will       withThrowingTaskGroup(of: Int.self)
                            cancel remaining tasks)
 */

class CompareTaskAndThrowingTask {
    
    func doWork(_ number: Int) async throws -> Int {
        if number == 2 {
            throw NSError(domain: "TestError", code: 1)
        }
        return number * 2
    }

    /**
     ✅ If You Use TaskGroup (Non-Throwing)
     🖍️ If a task inside fails(throw an error), the error is ignored unless you catch it manually inside the task.
     
     • Errors stay inside the task.
     • Other tasks continue running normally.
     • No automatic cancellation.
     */
    func nonThrowingTaskGroup() async {
        await withTaskGroup(of: Int.self) { group in
            for number in [1, 2, 3] {
                group.addTask {
                    do {
                        return try await self.doWork(number)
                    } catch {
                        print("Task failed: \(error)")
                        return -1
                    }
                }
            }
            
            for await result in group {
                print("Result:", result)
            }
            
        }
    }
    
    /**
     ✅ If You Use ThrowingTaskGroup (Recommended for Errors)
     🖍️ This allows throwing tasks safely. If one task fails:
     
     ✔ The error is propagated out of the group
     ✔ Remaining tasks in the group are automatically cancelled
     ✔ You can catch the error outside
     */
    

    func throwingTaskGroup() {
        Task {
            do {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for number in [1, 2, 3, 4, 5] {
                        group.addTask {
                            //try await self.doWork(number) // this will cancel all the remaining task in case of fail(throw)
                            
                            
                            // This won't cancel the remaining task as it is handled in a do-try-catch block
                            do {
                                return try await self.doWork(number)
                            } catch {
                                return -1
                            }
                        }
                    }

                    for try await result in group {
                        print("Result:", result)
                    }
                }
            } catch {
                print("❗Task group failed because of:", error)
            }
        }
    }
    /**
     | Behavior                          | `TaskGroup`            | `ThrowingTaskGroup`   |
     | --------------------------------- | ---------------------- | --------------------- |
     | Error propagation                 | ❌ No                   | ✅ Yes                 |
     | Cancels remaining tasks on error  | ❌ No                   | ✅ Yes                 |
     | You can use `try / catch` outside | ❌ No                   | ✅ Yes                 |
     | Best for                          | Tasks that don’t throw | Tasks that might fail |

     */
    
}


// MARK: - Question:
// with swift taskgroup I can execute multiple task concurrently, and I think I can only get the result after the completion of all task inside the task group. But if I want some result independent of another and they will execute concurrently, then what should I use

/*
 ✅ withTaskGroup (and withThrowingTaskGroup) executes multiple tasks concurrently, but you can only start getting results as they complete, and the function itself doesn’t return until all tasks in the group finish.
 
 However, you can consume results incrementally as tasks finish — and if you want even looser coupling (tasks that don’t depend on each other and don’t have to wait for the group to finish), you have a few different patterns. Let’s go through them clearly 👇
 */

class IndependentResultWithTask {
    
    func fetchData(_ value: Int) async throws -> String {
        if value == 2 {
            throw NSError(domain: "Not applicable", code: 101)
        }
        return "\(value) is acceptable"
    }
    
    func fetchValue(_ value: Int) async -> String {
        return "\(value) is acceptable"
    }
    
    // using Task Group we can consume result immediately as tasks finish, but the function does not return untill all tasks in the group finish
    func dependentButImmediateResultConsume() async {
        await withTaskGroup(of: String.self) { group in
            for i in 1...6 {
                group.addTask {
                    do {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        return try await self.fetchData(i)
                    } catch {
                        print("Task failed: \(error)")
                        return error.localizedDescription
                    }
                }
                
                // You can process result as they complete
                for await result in group {
                    print("Got Result: \(result)")
                }
            }
        }
        
        /*
         Output - Every result will print after 3 seconds each.
         Got Result: 1 is acceptable
         Task failed: Error Domain=Not applicable Code=101 "(null)"
         Got Result: The operation couldn’t be completed. (Not applicable error 101.)
         Got Result: 3 is acceptable
         Got Result: 4 is acceptable
         Got Result: 5 is acceptable
         Got Result: 6 is acceptable
         
         
         In this case:

         • Each fetchData runs concurrently.
         • The for await result in group loop yields results as soon as each task finishes.
         • The function will still wait for all tasks to complete before exiting the group, but you can handle results progressively.
         */
    }
    
    
    /**
     🔹 2. Using unstructured tasks (fully independent)
     If tasks are independent and you don’t want them tied to the lifetime of the current scope, you can use plain Task { … }:
     */
    func independentTask() async {
        let task1 = Task {
            await fetchValue(1)
        }
        
        let task2 = Task {
            await fetchValue(2)
        }
        
        let task3 = Task {
            await fetchValue(3)
        }
        
        let _ = await task1.value
        let _ = await task2.value
        let _ = await task3.value
        
        /**
         Here:

         • Each Task runs concurrently and independently.
         • They are not canceled automatically if the parent task is canceled.
         • You can await their results separately, whenever you need.
         • This is useful when tasks are independent and can outlive the calling scope.
         */
    }
    
    // MARK: - Detached Task
    /**
     🧩 What is a DetachedTask?

     🔹 A DetachedTask creates a completely independent concurrent task that:
     🔹 does not inherit the parent’s priority or cancellation status,
     🔹 does not inherit the current actor context,
     🔹 and runs freely in the background.

     It’s often used for background or fire-and-forget work like:
     🔹 Logging or analytics
     🔹 Background cleanups
     🔹 Non-UI data processing
     🔹 Isolated tasks outside actor or view model
     */
    
    func userTappedButton() {
        print("👆 User tapped the button")
        
        // Start a detached task to log this event
        Task.detached {
            await self.logAnalyticsEvent("button_tapped")
        }
        
        print("Main work continues immediately")
        
        /**
         Output -
         👆 User tapped the button
         Main work continues immediately
         🪵 Logged event: button_tapped

         🔍 Explanation

         🔹 DetachedTask launches independently — the main function doesn’t wait for it.
         🔹 Even if `userTappedButton() ends,` the detached task continues running.
         🔹 It doesn’t inherit actor isolation — so it’s safe to call from anywhere.
         */
    }
    
    func logAnalyticsEvent(_ event: String) async {
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        print("🪵 Logged event:", event)
    }
    
    /// ⚙️ Another Example — Background Data Processing
    actor DataStore {
        func updateDatabase() async {
            print("🧠 Updating database...")
            try? await Task.sleep(for: .seconds(2))
            print("✅ Database updated")
        }
    }
    
    let store = DataStore()
    
    /// The app flow continues immediately — the detached task handles the background work.
    func performBackgroundMaintainance() {
        Task.detached {
            // Detached task runs outside of the actore
            await self.store.updateDatabase()
        }
        
        print("🏃‍♂️ Maintenance task started, continuing app flow")
    }
    
    
    // Caller Function
    func caller() {
        Task{
            await dependentButImmediateResultConsume()
        }
    }
}



// MARK: Async let child task
class AsyncLetChildTaks {
    /// 🔷 Non-throwing async let (simple, independent children)
    
    func fetchName() async -> String {
        try? await Task.sleep(for: .seconds(1))
        return "Alice"
    }

    func fetchAge() async -> Int {
        try? await Task.sleep(for: .seconds(2))
        return 30
    }
    
    func independentAsyncLet() {
        Task  {
            async let name = fetchName()
            async let age = fetchAge()
            
            // We can await them in any order
            let n = await name      // returns as soon as fetchName() finishes (≈1s)
            print("Got Name: \(n)")
            
            let a = await age    // returns when fetchAge() finishes (≈2s)
            print("Gor Age: \(a)")
            
            // Or await both together:
            // let (n, a) = await (name, age) // waits for both to complete
            
            /**
             
             output -
             Got Name: Alice
             Gor Age: 30
             
             
             Key points
             🔹 These are non-throwing child tasks.
             🔹 await name returns when that child finishes — you do not have to wait for the other child to finish before receiving this result.
             🔹 If you await (name, age) you will wait until both children have finished.
             */
        }
    }
    
    /// 🔷 Throwing async let (child tasks that can throw)
    enum NetworkError: Error { case failed }
    
    func fetchDataOK() async throws -> String {
        try? await Task.sleep(for: .seconds(1))
        return "data"
    }
    
    func fetchDataFail() async throws -> String {
        try? await Task.sleep(for: .seconds(1))
        throw NetworkError.failed
    }
    
    func throwingAsyncLet() {
        Task {
            async let good = fetchDataOK()
            async let bad = fetchDataFail()
            async let ok = fetchDataOK()
            
            do {
                // You can await both at once; the `try` applies when awaiting.
                let (g, b, o) = try await (good, bad, ok)
                print("Both Successed:", g, b, o)   // Never execute becuase of task failure
            } catch {
                print("Caught error:", error)
                // At this point, Swift will ensure child tasks are cleaned up.
            }
        }
        
        /**
         output - Caught error: failed
         
         What happens to the other async let tasks if one fails?

         Important behavior to understand:
         
         🔹 async let children are structured child tasks. If one child throws and that error is propagated out (i.e., you try await and don't swallow the error), Swift will cancel the sibling child tasks when the parent scope exits due to that error.

         🔹 You must await all child tasks (either explicitly, or implicitly by awaiting a tuple). The compiler enforces that child tasks are awaited or otherwise handled before leaving the scope.
         */
    }
    
    func longTask(id: Int) async throws -> String {
        for i in 1...5 {
            try Task.checkCancellation()
            print("Task \(id) working step", i)
            try await Task.sleep(for: .seconds(1))
        }
        return "done \(id)"
    }
    
    func failingTask() async throws -> String {
//        try await Task.sleep(for: .seconds(2))
        throw NetworkError.failed
    }
    
    
    func execute() {
        Task {
            async let t1 = longTask(id: 1)    // long running
            async let t2 = failingTask()     // will throw after ~2s
            async let t3 = longTask(id: 3)   // long running
            
            do {
                // Await both t1 and t2 (and t3 if included). If any throws, error propagates.
                let (r1, r2, r3) = try await (t1, t2, t3)
                print("All results:", r1, r2, r3)       // Never execute because of task failure.
            } catch {
                print("A child threw — error:", error)
                // The runtime will cancel remaining children (t1, t3) as the error escapes
                // from this scope. Those tasks may see Task.isCancelled or Task.checkCancellation().
            }
        }
        
        /**
         Output -
         Task 1 working step 1
         Task 3 working step 1
         Task 3 working step 2
         Task 1 working step 2
         Task 1 working step 3
         Task 3 working step 3
         Task 1 working step 4
         Task 3 working step 4
         Task 3 working step 5
         Task 1 working step 5
         A child threw — error: failed
         
         
         What you should expect
         
         🔹 failingTask throws at ~2s.
         🔹 When try await (t1, t2, t3) rethrows, the remaining long tasks are cancelled by the runtime.
         🔹 Those tasks can notice cancellation (e.g., Task.checkCancellation()), stop work, and exit early.
         */
    }
        
        /// 🔷If you want other tasks to continue even when one fails
        func fetchMaybeFail(id: Int) async -> Result<String, Error> {
            do {
                if id == 2 {
                    try await Task.sleep(for: .seconds(2))
                    throw NetworkError.failed
                } else {
                    try await Task.sleep(for: .seconds(1))
                    return .success("OK \(id)")
                }
            } catch {
                print("On fail")
                return .failure(error)
            }
        }
        
    func asyncLetWithoutFail() {
        Task {
            async let r1 = fetchMaybeFail(id: 1)
            async let r2 = fetchMaybeFail(id: 2) // would fail internally but returns .failure
            async let r3 = fetchMaybeFail(id: 3)
            
            // No try — we get Results, so nothing throws here and siblings won't be canceled.
            let (res1, res2, res3) = await (r1, r2, r3)
            
            for res in [res1, res2, res3] {
                switch res {
                case .success(let val): print("Success:", val)
                case .failure(let err): print("Failed:", err)
                }
            }
        }
        /**
         Output -
         On fail
         Success: OK 1
         Failed: failed
         Success: OK 3
         */
    }
}


class TaskGroupExecution {
    
    func executionOne() {
        Task {
            await withTaskGroup(of: Int.self) {[weak self] group in
                guard let self = self else { return }
                for i in [1, 6, 11] {
                    group.addTask {
                        self.runLoop(start: i, end: i + 4)
                    }
                }
            }
        }
    }
    
    func executionTwo() {
        Task {
            await withTaskGroup(of: Int.self) {[weak self] group in
                guard let self = self else { return }
                group.addTask {
                    self.runLoop(start: 1, end: 5)
                }
                
                group.addTask {
                    self.runLoop(start: 6, end: 10)
                }
                
                group.addTask {
                    self.runLoop(start: 11, end: 15)
                }
            }
        }
    }
    
    // Both execution one and two run concurrently and actual output can't be predicted.
    
    func runLoop(start: Int, end: Int) -> Int {
        for i in start...end {
            print("☺️ value :: \(i)")
        }
        return 0
    }
}


// structured Task
class StructuredTaskExectuionAndCancellation {
    func asyncLetExecution() {
        let parent = Task {
            async let value1 = fetchDataOne()
            async let value2 = fetchDataTwo()
            
            do {
                let (one, two) = await (value1, value2)
                print("Execution done ✅")
            } catch {
                print("Failed with cancellation!")
            }
        }
        
        parent.cancel()
    }
    
    func fetchDataOne() async {
        for i in 1...5 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            print("☺️ value :: \(i)")
        }
    }
    
    func fetchDataTwo() async {
        for i in 6...10 {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            print("☺️ value :: \(i)")
        }
    }
}



class StructuredTaskExecutionAndCancellation {
    func asyncLetExecution_immediateCancel() {
        let parent = Task {
            async let value1 = try fetchDataOne()
            async let value2 = try fetchDataTwo()
            
            do {
                // `try await` so errors (including CancellationError) propagate
                let (_ , _) = try await (value1, value2)
                print("Execution done ✅")
            } catch {
                print("Parent caught:", error)
            }
        }
        
        // Request cancellation of the parent (and its structured children)
        parent.cancel()
    }
    
    func asyncLetExecution_cancelAfterDelay() async {
        let parent = Task {
            async let value1 = try fetchDataOne()
            async let value2 = try fetchDataTwo()
            
            do {
                let (_ , _) = try await (value1, value2)
                print("Execution done ✅")
            } catch {
                print("Parent caught:", error)
            }
        }
        
        // Wait a bit, then cancel so you can see some child output first
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        parent.cancel()
    }
    
    // Make these `async throws` and check cancellation cooperatively
    func fetchDataOne() async throws {
        for i in 1...5 {
            try Task.checkCancellation()                // immediate throw if cancelled
            try await Task.sleep(nanoseconds: 2_000_000_000) // suspension point — throws on cancel
            print("☺️ fetchDataOne :: \(i)")
        }
    }
    
    func fetchDataTwo() async throws {
        for i in 6...10 {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("☺️ fetchDataTwo :: \(i)")
        }
    }
}


/// ✅ without using .sleep, .yeild, task.cancel(), Task.checkCancellation() and withTaskCancellationHandler we can not cancel any task, no matter child or parent, because swift does not support forcefully cancellation, you have to manage it  manually.

//
//  PracticeConcurrency.swift
//  LearningAndExercise
//
//  Created by hb on 20/01/26.
//

import SwiftUI

struct PracticeConcurrency: View {
    
    var obj = DispatchGroupExecution()
    
    var body: some View {
        VStack {
            Button {
                obj.groupWithNotify()
//                obj.operations()
            } label: {
                Text("Start")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
//                obj.getValue()
            } label: {
                Text("Get Value")
            }
            .buttonStyle(.borderedProminent)
        }

    }
}

#Preview {
    PracticeConcurrency()
}




// MARK: Async / Await / Task

class PracticeConcurrencyViewModel {
    
    // Init
    init() {
        foo9()
    }
    
    //MARK:  Task -
    // Creates an asynchronous context
    // Does not block the UI/Main Thread, runs in other thread managed by system
    // Execute the code concurrently with outside code and also with inside with a certain condition, other wise serail with the inside code.
    // For running inside code concurrently it requires child tasks or suspension points.
    
    // Loop1 and Loop2 will execute concurrently, because tasak creates a asynchronous context.
    func foo1() {
        Task {
            print("is Main Thread insdie block :: \(Thread.isMainThread)")
            // Loop 1
            for i in 0...10 {
                print("Execution inside task block :: \(i)")
            }
        }
        // Loop 2
        print("is Main Thread Outside block :: \(Thread.isMainThread)")
        for i in 11...20 {
            print("Execution outside task block :: \(i)")
        }
    }
    
    
    // Execute seraillay and synchronously becasue task execute asynchonously with only outside code. So Loop1 and Loop2 will execute serially.
    func foo2() {
        Task {
            // Loop 1
            for i in 0...10 {
                print("Loop One Execution :: \(i)")
            }
            
            // Loop 2
            for i in 11...20 {
                print("Loop Two Execution :: \(i)")
            }
        }
    }
    
    // Execute Serailly. Loop 1 will wait for Loop 2 to complete
    func foo3() {
        Task {
            await asyncBlock1()
            // Loop 1
            for i in 1...10 {
                print("Inside Task :: \(i)")
            }
        }
    }
    
    // Loop 2
    func asyncBlock1() async {
        for i in 11...20 {
            print("Async Block One :: \(i)")
        }
    }
    
    // Concurrent Execution
    func foo4() {
        Task {
            await asyncBlock1()
        }
        
        // Loop 1
        for i in 1...10 {
            print("Inside Task :: \(i)")
        }
    }
    
    
    //MARK: Inner Task Block Concurrent Execution:
    // 1. Child Task
    // Run concurrently
    func foo5() {
        Task {
            // Child Task
            Task {// Create another async context with the outer block. Does not cancel with parent.
                for i in 1...10 {
                    print("Child Task :: \(i)")
                }
            }
            
            for i in 11...20 {
                print("Parent Task :: \(i)")
            }
        }
    }
    
    
    // 2. async let (structured concurrency)
    func foo6() {
        Task {
            async let _ = asyncBlock2()// Child task creates automaticllay, and also cancel with prent
            
            for i in 1...10 {
                print("Task :: \(i)")
            }
        }
    }
    
    func asyncBlock2() async  {
        for i in 11...20 {
            print("Async Block Two:: \(i)")
        }
    }
    
    // 3. Suppension via Task.Yeild()
    
    // This will run serially because the inner child task will only start after asyncBlock3 finish.
    // so to make this concurrent we have to write the child task first.
    func foo7() {
        Task {
            await asyncBlock3()
            Task {
                for i in 1...10 {
                    print("Task :: \(i)")
                }
            }
        }
    }
    
    func asyncBlock3() async  {
        for i in 11...20 {
            print("Async Block Three:: \(i)")
            await Task.yield()
        }
    }
    
    // Will execute concurrently
    func foo8() {
        Task {
            Task {
                for i in 1...10 {
                    print("Task :: \(i)")
                    await Task.yield()
                }
            }
            await asyncBlock3()
        }
    }
    
    // Concurrent Execution.
    func foo9() {
        Task {
            async let a: () = asyncBlock1()
            async let b: () = asyncBlock2()
            
            await a
            await b
        }
    }
    
}


// MARK: TaskGroup
class TaskGroupExecutionViewModel {
    init() {
        Task {
            await asyncLetExecution_cancelAfterDelayWithThrow()
        }
    }
    
    func loopThroughRange(in range: ClosedRange<Int>) async {
        for i in range {
            print("Range Value:: \(i)")
        }
    }
    
    // Concurrent execution.
    func foo1() {
        let ranges = [1...5, 6...10, 11...15, 16...20]
        Task {
            await withTaskGroup(of: Void.self) { group in
                for range in ranges {
                    group.addTask {
                        await self.loopThroughRange(in: range)
                    }
                }
            }
        }
    }
    
    func loopRange(in range: ClosedRange<Int>) async throws -> Int {
        for i in range {
            if i == 2 {
                throw NSError(domain: "Range Error", code: 99)
            }
            print("Range Value:: \(i)")
        }
        return 1
    }
    
    func foo2() {
        let ranges = [1...5, 6...10, 11...15, 16...20]
        Task {
            await withTaskGroup { group in
                for range in ranges {
                    group.addTask {
                        try? await self.loopRange(in: range)
                    }
                }
            }
        }
    }
    
    func  foo3() {
        let ranges = [1...5, 6...10, 11...15, 16...20]
        Task {
            await withThrowingTaskGroup { group in
                for range in ranges {
                    group.addTask {
                        try await self.loopRange(in: range)
                    }
                }
            }
        }
    }
    
    // The remaining task will never failed until you consume the result.
    func foo4() {
        let ranges = [1...5, 6...10, 11...15, 16...20]
        Task {
            await withThrowingTaskGroup(of: Int.self) { group in
                for range in ranges {
                    group.addTask {
                        return try await self.loopRange(in: range)
                    }
                }
            }
        }
    }
    
    func foo5() {
        let ranges = [1...5, 6...10, 11...15, 16...20]
        Task {
            do {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for range in ranges {
                        group.addTask {
                            return try await self.loopRange(in: range)
                        }
                    }
                    
                    // IMPORTANT: Consume results so errors propagate
                    // Now the task group will get failed, while the loop will be executing. as it is already in execution and force cancellation is not worked in swift.
                    for try await value in group {
                        // no-op
                        print("Value : \(value)")
                    }
                }
            } catch {
                print("❗Task group failed because of:", error)
            }
        }
    }
    
    
    // Non throwing async let
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
            let n = await name
            print("Got Name: \(n)")
//            
            let a = await age
            print("Gor Age: \(a)")
            
            // Or await both together:
//             let (n, a) = await (name, age) // waits for both to complete
//            print("Got name : \(n)")
//            print("Got age : \(a)")
        }
    }
    
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
            
            // Approach 1 - output: Caught error: failed
//            do {
//                let (g, b, o) = try await (good, bad, ok)
//                print("Both Successed:", g, b, o)
//            } catch {
//                print("Caught error:", error)
//            }
            
            
            // Approach 2
            // Output - Both Successed: data data, after that the task will failed with error and the belwo lines will never execute.
            let (g, o) = try await (good, ok)
            print("Both Successed:", g, o)
            let b = try await bad
            print("Result of b:", b)
            print("Hellow")
        }
    }
    
    
    // Concurrent Execution
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
    
    func fetchDataOneWithThrow() async throws {
        for i in 1...5 {
            try Task.checkCancellation()                // immediate throw if cancelled
            try await Task.sleep(nanoseconds: 2_000_000_000) // suspension point — throws on cancel
            print("☺️ fetchDataOne :: \(i)")
        }
    }
    
    func fetchDataTwoWithThrow() async throws {
        for i in 6...10 {
            try Task.checkCancellation()
//            if Task.isCancelled { }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("☺️ fetchDataTwo :: \(i)")
        }
    }
    
    func fetchDataThreeWithThrow() async throws {
        for i in 11...20 {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("☺️ fetchDataThree :: \(i)")
        }
    }
    
    func asyncLetExecution_cancelAfterDelayWithThrow() async {
        let parent = Task {
            async let value1 = try fetchDataOneWithThrow()
            async let value2 = try fetchDataTwoWithThrow()
            
            do {
                let (_ , _) = try await (value1, value2)
                print("Execution done ✅")
            } catch {
                print("Parent caught:", error)
            }
        }
        
        
        // It will succeed as we are only cancelling parent task.
        Task {
            async let value1 = try fetchDataThreeWithThrow()
            
            do {
                let _ = try await value1
                print("Third fetch datat Succeed✅")
            } catch {
                print("Third fetch datat cancelled")
            }
        }
        
        // Wait a bit, then cancel so you can see some child output first
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        parent.cancel()
    }
}


//
//  AsyncAwaitTask.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import Foundation
import SwiftUI

// MARK: VIP - Async/Task

/**
 ➡️ In Swift Concurrency, Task is used to start asynchronous work concurrently.
 ➡️ Task creates a concurrent execution context where:

 • async functions can run
 • work can suspend and resume
 • the system manages threads for you
 • cancellation and priority are handled automatically
 • start work concurrently
 • allow suspension (await)
 • don’t block the current thread
 
 
 Question - even if we do not execute async async function inside Task block it will run it asynchronously.
 
 Yes — exactly 👍
 Even if you don’t call any async function inside a Task block, the code still runs asynchronously.
 
 ➡️ Task {} itself creates asynchronous execution
 ➡️  async/await is not required for code to run concurrently.
 
 Task {
     print("A")
     print("B")
 }
 print("C")
 
 Possible Output -
 C
 A
 B
 
 or
 
 A
 C
 B

 ➡️ The Task block runs concurrently, even though:

• there is no await
• no async function is called
 
 Important clarification 🧠
 ➡️ Task is  async, but not concurrent within itself
 
 executeSecond()
  └── Task { }   ← asynchronous boundary
       ├── taskTwo()   ← synchronous
       └── for loop    ← synchronous

 ➡️ Task runs concurrently with outside code
 ➡️ A Task is concurrent with the outside world, but code inside a Task is sequential unless it suspends.
 ➡️ Code inside the Task runs serially
 
 
 Question: so can I make the code inside Task concurrent.
 ➡️ Yes — you can make code inside a Task concurrent, but only by creating additional tasks or suspension points.
 
 1️⃣ Can code inside a Task be concurrent?
 ❌ By default: NO
 Task {
     taskTwo()
     loop()
 }


 This is sequential.

 A Task is a single serial execution context.

 ✅ How to make code inside a Task concurrent

 You have three valid mechanisms.

 🔹 Option 1: Create child tasks (most explicit)
 Task {
     Task {
         taskTwo()
     }

     for i in 11...20 {
         print("Outside task:: ➡️ \(i)")
     }
 }

 What happens

 • Two tasks run concurrently
 • Output may interleave
 • No ordering guarantee

 ✔ Fire-and-forget
 ✔ True concurrency

 🔹 Option 2: async let (structured concurrency)
 Task {
     async let _ = taskTwoAsync()

     for i in 11...20 {
         print("Outside task:: ➡️ \(i)")
     }
 }

 func taskTwoAsync() async {
     for i in 0...10 {
         print("Inside async task:: ➡️ \(i)")
     }
 }

 What happens

 • Child task is created automatically
 • Cancelled with parent
 • Cleaner and safer

 ✔ Preferred when possible

 🔹 Option 3: Suspension via Task.yield()
 func taskTwoAsync() async {
     for i in 0...10 {
         print("Inside async task:: ➡️ \(i)")
         await Task.yield()
     }
 }

 Task {
     await taskTwoAsync()
     for i in 11...20 {
         print("Outside task:: ➡️ \(i)")
     }
 }


 ✔ Allows interleaving
 ❌ Still not parallel

 2️⃣ Task.yield() vs await (CRITICAL difference)

 This is where most confusion happens.

 🔸 await
 await someAsyncFunction()

 Meaning

 • “Pause here until this async work completes.”
 • Mandatory for async calls
 • Creates a suspension point
 • May switch threads
 • Required for correctness

 Example
 await fetchData()
 print("Runs later")

 🔸 Task.yield()
 await Task.yield()

 Meaning

 • “I’m willing to pause — let other tasks run.”
 • Does not wait for work
 • Only gives scheduler a chance
 • Resumes almost immediately
 • Useful for long CPU loops
 */
/**
 4️⃣ Core interview truths (MEMORIZE THESE)
 🔑 Truth #1

 Task is concurrent with the outside world, not within itself.

 🔑 Truth #2

 Swift concurrency is cooperative, not preemptive.

 🔑 Truth #3

 Concurrency only happens at suspension points or task boundaries.

 🔑 Truth #4

 await does not create concurrency — Task does.

 5️⃣ Common interview questions (with answers)
 Q1️⃣ What is Task in Swift?

 Answer:

 Task represents a unit of concurrent asynchronous work managed by Swift’s concurrency runtime. It allows async code to run concurrently without blocking threads and supports cancellation, priority, and actor isolation.

 Q2️⃣ Does Task create a new thread?

 Answer:

 No. Task is scheduled onto a thread pool by Swift. Tasks are lightweight and may resume on different threads.

 Q3️⃣ Can code inside a Task run concurrently?

 Answer:

 No. A single task executes serially. Concurrency inside a task requires child tasks or suspension points.

 Q4️⃣ What is the difference between Task and async?

 Answer:

 async marks a function as suspendable. Task actually creates concurrent execution. async alone does not run code concurrently.

 Q5️⃣ Difference between Task and Task.detached?

 Answer:

 Task inherits priority, cancellation, and actor context. Task.detached does not and runs independently.

 Q6️⃣ Why does a Task sometimes appear to run serially?

 Answer:

 Because Swift concurrency is cooperative. Without suspension points, a task runs to completion before others execute.

 Q7️⃣ What is Task.yield()?

 Answer:

 Task.yield() is a voluntary suspension point that allows other tasks to run, improving fairness for CPU-bound work.

 Q8️⃣ When should you avoid using Task?

 Answer:

 When structured concurrency (async callers) is possible, or when you ignore cancellation and lifecycle management.

 Q9️⃣ Is await required inside a Task?

 Answer:

 Only when calling an async function or suspension point. Task itself does not require await.

 Q🔟 How does cancellation work in Task?

 Answer:

 Cancellation is cooperative. Tasks must check Task.isCancelled or hit cancellable suspension points.

 6️⃣ One-sentence interview answer (golden line)

 Task defines concurrency, async defines suspension capability, and await defines waiting.
 */




struct TestContent: View {
    var obj = AsyncTest()
    
    var body: some View {
        VStack {
            Text("Hello World")
        }
        .onAppear {
            obj.executeThird()
        }
    }
}

// An async test
class AsyncTest {
    func executeOne() {
        let _ = Task {
            await taskOne()
            for i in 11...20 {
                print("Outside task:: ➡️ \(i)")
            }
        }
    }
    
    func taskOne() async {
        for i in 0...10 {
            print("Inside async task:: ➡️ \(i)")
        }
    }
    
    // without Async/Await
    func executeSecond() {
        // This will execute serially, because task execute concurrently only with outside code.
        let _ = Task {
            print("Is Main Thread:: \(Thread.isMainThread)")
            taskTwo()
            for i in 11...20 {
                print("Outside task:: ➡️ \(i)")
            }
        }
    }
    
    func taskTwo() {
        for i in 0...10 {
            print("Inside async task:: ➡️ \(i)")
        }
    }
    
    func executeThird() {
        // This will execute concurrently, because task execute concurrently only with outside code.
        // Concurrency only happens at suspension points or task boundaries. so without suspension it can run serially.
        let _ = Task {
            print("Is Main Thread:: \(Thread.isMainThread)")
            await taskTwo()
        }
        
        for i in 11...20 {
            print("Outside task:: ➡️ \(i)")
        }
    }
    
    func taskThree() async {
        for i in 0...10 {
            print("Inside async task:: ➡️ \(i)")
        }
    }
}



/**
 ✅ What is Task?

 Task creates a new concurrent unit of work.

 Think of it as:

 “Start this async work in the background without blocking the current thread.”

 It’s Swift’s way of saying:
 ➡️ Run this asynchronously.

 🔹 Why is Task needed?

 Because await can only be used inside an async context.

 So when you're in a normal function (like a button tap, viewDidLoad, etc.) and you want to call an async function, you must wrap it in a Task.

 Example
 func buttonTapped() {
     Task {
         await loadData()
     }
 }


 Without Task, this is illegal:

 func buttonTapped() {
     await loadData() ❌ Compile error
 }

 🔹 What does Task actually do?

 When you write:

 Task {
     await apiCall()
 }


 It:

 Creates a lightweight concurrent thread

 Runs your async code

 Doesn't block UI

 Automatically manages cancellation & memory

 Runs on Swift’s cooperative thread pool
 */

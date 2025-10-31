//
//  Combine+Extension.swift
//  LearningAndExercise
//
//  Created by hb on 30/10/25.
//

import Foundation
import Combine

// 🔷 1. Custom Operator
// Custom operators allow you to extend Combine's power. You can write them by extending Publisher.

extension Publisher {
    /// Retries the publisher if `shouldRetry` returns true, up to `maxRetries` times.
    func retryIf(
        maxRetries: Int,
        shouldRetry: @escaping (Failure) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard maxRetries > 0, shouldRetry(error) else {
                // Don’t retry – rethrow the error
                return Fail(error: error).eraseToAnyPublisher()
            }
            // Retry recursively
            // 👇 Re-subscribes to the *same publisher chain* recursively
            // self here is the upstream publisher, e.g. the dataTaskPublisher chain.
            return self.retryIf(maxRetries: maxRetries - 1,
                                shouldRetry: shouldRetry)
            .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    func retryWithDelay(
        _ retries: Int,
        delay: TimeInterval
    ) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard retries > 0 else { return Fail(error: error).eraseToAnyPublisher() }
            
            return self
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .retry(retries - 1)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}



// MARK: - COMBINE VS ASYNC/AWAIT
/**
 `🧩 1. Combine = Deferred Pipelines

 When you build a Combine chain like this:

 let publisher = URLSession.shared.dataTaskPublisher(for: url)
     .map(\.data)
     .decode(type: User.self, decoder: JSONDecoder())
     .retry(3)


 👉 Nothing happens yet.
 No network request is made.
 No decoding occurs.

 You’re just building a description of work — a pipeline that says:
 “When someone subscribes, fetch data → decode → retry if needed.”

 `Execution is deferred until you do something like:

 publisher
     .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
     .store(in: &cancellables)


 Only at that moment does Combine:
 ➡️ Subscribe to the publisher chain
 ➡️ Start running your network request
 ➡️ Eventually emit values or errors

 So, Combine pipelines are lazy.
 They describe what to do later, not what to do now.

 That’s what we mean by deferred execution or a declarative pipeline.

 `🧠 2. async/await = Immediate Execution (Imperative)

 Now compare that to Swift’s async/await style:

 let (data, _) = try await URLSession.shared.data(from: url)
 let user = try JSONDecoder().decode(User.self, from: data)

 
 As soon as this line runs, Swift immediately starts the work —
 the network request begins right now.

 There’s no “declaration” of future work — you’re directly executing the steps sequentially:

 ➡️ Run request
 ➡️ Wait for result
 ➡️ Decode data
 ➡️ Continue execution
 
 `Even though the function may suspend at each await, the control flow is synchronous-looking and immediate — it doesn’t wait for someone to “subscribe later”.

 That’s what I mean by immediate execution.

 ⚖️ 3. Direct Comparison
 Concept                                Combine (Deferred)                              async/await (Immediate)
 Starts running when…                   Someone subscribes                              Function executes
 Execution style                        Declarative / lazy                              Imperative / eager
 Built as…                              A pipeline of publishers                        A sequence of async calls
 Closures                               Often escaping (stored until subscription)      Usually non-escaping (executed inline)
 Retrying logic                         Implemented via operators (catch, retry)        Implemented via loops and do/catch
 Example                                .map().flatMap().retry(3)                       for _ in 0..<3 { try await ... }
 
 `🧠 So in short:

 📕`Combine builds pipelines that describe what will happen later, when subscribed.

 📕`async/await executes steps immediately as your code runs — no deferred subscription phase.

 That’s why async/await can’t be dropped directly inside Combine operators:
 Combine’s internal closures are stored for later (they must escape), while async/await is designed for now, not later.
 */


/**
 Perfect — this is one of the best questions you can ask as a Swift developer. ❤️
 Understanding the difference between async/await and @escaping closures, and why Apple introduced async/await even though escaping closures already worked, is absolutely key to writing modern, safe, and readable concurrent Swift code.

 Let’s go deep step by step 👇

 🧩 1. The Core Difference
 Concept                                @escaping Closure                                   async/await
 What it is                     A callback you store and call later                 A language feature for structured concurrency
 When it runs                   Later (manually triggered)                          Suspends and resumes automatically
 Control flow                   Split across functions — hard to read               Looks sequential — easy to follow
 Error handling                 Via completion blocks (Result, optional error)      Built-in try / catch
 Threading                      You decide manually (DispatchQueue, GCD)            Swift runtime manages it safely
 Type safety                    Complex (escaping, retain cycles, weak self)        Much cleaner, compiler-managed
 Introduced                     Swift 1 (old way)                                   Swift 5.5 (modern concurrency)
 🧠 2. What @escaping Closures Really Do

 Let’s look at the pre–async/await world (old-style async):

 func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
     URLSession.shared.dataTask(with: url) { data, _, error in
         if let data = data {
             let user = try! JSONDecoder().decode(User.self, from: data)
             completion(.success(user))
         } else {
             completion(.failure(error!))
         }
     }.resume()
 }


 Here:

 🔘completion is marked @escaping because it’s stored and called later, after the network request finishes.
 🔘The function returns immediately, but the closure runs sometime in the future.\
 
 You must handle:

 🔘Capturing self weakly (to avoid retain cycles)
 🔘Dispatching back to the main queue
 🔘Nested callbacks → “callback hell”

 Example usage:

 fetchUser { result in
     switch result {
     case .success(let user): print(user)
     case .failure(let error): print(error)
     }
 }


 This works fine — but it’s hard to compose and debug as complexity grows.

 `⚙️ 3. async/await — The Modern Replacement

 Apple introduced Swift Concurrency (async/await) to make this simpler, safer, and more readable.

 Equivalent async version:

 func fetchUser() async throws -> User {
     let (data, _) = try await URLSession.shared.data(from: url)
     return try JSONDecoder().decode(User.self, from: data)
 }


 Now the compiler:

 🔘Handles suspension and resumption automatically
 🔘Eliminates the need for escaping closures
 🔘Makes code look synchronous, but still non-blocking
 🔘Integrates with structured concurrency (Task, TaskGroup, actor, etc.)

 Usage:

 do {
     let user = try await fetchUser()
     print(user)
 } catch {
     print(error)
 }


 Much cleaner ✅

 💡 4. Why Apple Introduced async/await

 Closures work, but they come with significant pain points:

 Pain with @escaping closures                                               Solved by async/await
 Callback hell (nested closures)                                            Sequential code flow
 Hard error handling                                                        Natural try / catch
 Manual thread management                                                   Automatic cooperative concurrency
 Retain cycles & weak self                                                  Compiler-managed lifetime
 Debugging call stacks is difficult                                         Straight, readable call stacks
 Hard to compose tasks (run 2 async calls in parallel, wait for both)       Use async let, TaskGroup

 Essentially, Apple introduced async/await because @escaping closures were too low-level and error-prone for safe, scalable concurrency.

 🧱 5. Conceptual Analogy
 Idea                                               Analogy
 @escaping closure              “Leave me your number — I’ll call you back later.” ☎️
 async/await                    “Wait right here — I’ll pause what I’m doing until I get the info.” ⏸️

 The closure model is a callback system.
 The async/await model is a suspension system — it feels synchronous but isn’t blocking.

 ⚖️ 6. Summary Table
 Feature                          @escaping Closure                         async/await
 Syntax style                       Callback-based                          Sequential
 Execution control                      Manual                          Compiler/runtime-managed
 Error handling                     Callback or Result                      try / catch
 Threading                          Manual (GCD)                            Automatic
 Readability                        Low (nested)                            High (linear)
 Introduced                         Swift 1                                 Swift 5.5 (2021)
 Best used for                 Compatibility / legacy APIs                  Modern async code
 */

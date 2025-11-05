//
//  ConcurrencyPart6.swift
//  LearningAndExercise
//
//  Created by hb on 03/11/25.
//

// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-6-async-sequences-and-streams-c402a4251308

import Foundation
import UIKit
import CoreLocation

// MARK: - Part 6: Async Sequences and Streams

/*
 • Real-world apps does not just deal with shared state - they need to *** continuously receive values over time. ***
 
 • Chat messages arriving one by one
 • Timer events firing every second
 • Location updates form GPS
 • Notifications from sensors
 
 For this, Swift provides a Async Sequences and Streams, Which bring a Combine-like reactive model into the world of async/await.
 
 🔷 In this article, we’ll cover:

 ✅ What are AsyncSequence and AsyncIterator
 ✅ How to use for await to consume values
 ✅ Creating custom streams with AsyncStream
 ✅ Bridging delegate and Combine APIs to async streams
 ✅ Real-world example: building a chat message stream
 ✅ Best practices and common pitfalls
 ✅ Visualizing the full AsyncStream flow
 
 */


// MARK: - 🔹 From Sequences → to Async Sequences

/**
 🔹 The Building Blocks
 ● AsyncSequence → a collection of values delivered asynchronously.
 ● AsyncIterator → produces the next value when asked.
 ● for await loop → consumes the sequence asynchronously.
 
 ✅ Real-World Example: Streaming Live Stock Prices Using AsyncSequence
 Imagine you’re building a stock trading app that receives live stock price updates from a server. The server streams updates line-by-line over an HTTP connection.

 You can model this stream in Swift using AsyncSequence.
 */
class SequencesToAsyncSequences {
    
    var results: [Int] = []
    
    // with Sequences
    func normalSequences() {
        let numbers = [1, 2, 3]
        for number in numbers {
            print(number)
        }
        
        // This prints values synchronously.    //1 2 3
    }
    
    // But what if values arrives over time, instead of all at once?
    // That'w where AsyncSequence comes in.
    // 📌 Step 2: Use the AsyncSequence in Your App
    func useAsyncSequence() {
        let url = URL(string: "https://example.com/live-stocks")!
        let stream = StockPriceStream(url: url)
        
        Task {
            do {
                for try await priceUpdate in stream {
                    print("📈 Price Update:", priceUpdate)
                }
            } catch {
                print("❌ Error streaming data:", error)
            }
        }
    }
    /**
     💡 What This Does

     ✅ Connects to a real server
     ✅ Reads data line-by-line asynchronously
     ✅ Prints stock price updates as they arrive
     ✅ Uses AsyncSequence to model a live data stream
     
     🛠 Why This Is Real-World?
     ● Streaming live stock data
     ● Works similarly for chat messages, sensor data, server logs, etc.
     ● Efficient: doesn’t wait for full response, processes incrementally
     */
    
}

// 📌 Step 1: Create an AsyncSequence
struct StockPriceStream: AsyncSequence {
    typealias Element = String
    
    let url: URL
    
    struct AsyncIterator: AsyncIteratorProtocol {
        let url: URL
        var lines: AsyncLineSequence<URLSession.AsyncBytes>.AsyncIterator?
        
        mutating func next() async throws -> String? {
            // If no stream yet, start one
            if lines == nil {
                let (bytes, _) = try await URLSession.shared.bytes(from: url)
                lines = bytes.lines.makeAsyncIterator()
            }
            // Return the next line (each is a price update)
            return try await lines?.next()
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(url: url)
    }
}



// MARK: - 🔹 Using AsyncStream to Create Custom Streams
// https://chatgpt.com/share/690ad31c-337c-800e-8db7-a625b134994d
/**
 More  real-world apps need to produce values dynamically. That's where AsyncStream comes in - it is like building your own async publisher.
 
 ● It is a type in swift that lets you create your own asynchronous sequence - a series of values that are produced over time and can be iterated using `for await`.
 
 🧠 In Simple Terms
 ➡️ AsyncStream -  A way to create your own async data pipeline, where values are added one by one(like streaming events),and other part of your app can asynchronously receive them.
 
 ✅ Key Features of AsyncStream
 Feature                                                                    Explanation
 Produces values over time                    Unlike arrays (which contain all values), AsyncStream gives values one at a time, asynchronously.
 Works with for await                         You can loop through emitted values using Swift's async/await syntax.
 Controlled using a continuation              The producer side uses continuation to send values (yield) or finish the stream.
 Cancels automatically                        If the consumer stops listening, Swift handles cleanup
 
 📍 Real-World Use Cases
 Use Case                                               How AsyncStream Helps
 Keyboard/Motion/Sensor Events                  Stream user interactions as they happen
 WebSocket Messages                             Receive live chat updates
 Notifications                                  Async wrapper for NotificationCenter
 Timers                                         Emit values over intervals easily
 Combine bridging                               `Convert Combine publishers into async sequences`
 
 🎯 In Short
 • AsyncStream makes it easy to generate async sequences manually.
 • It’s ideal when you want to send data from `callbacks, timers, sensors, or events into Swift's async/await world.`
 */

class BasicAsyncStream {
    
    func basicExample() {
        let numberStream = AsyncStream<Int> { continuation in
            Task {
                for i in 1...5 {
                    try await Task.sleep(nanoseconds: 1_000_000_000)    // 1 sec
                    continuation.yield(i)
                }
                continuation.finish()
            }
        }
        
        Task {
            for await number in numberStream {
                print("Received Value: \(number)")
            }
        }
    }
}

// ⚡ Example: Wrapping NotificationCenter with AsyncStream
// Questions - will it call every time the apps enter to background.
class NotificationCenterAsyncStremWrapper {
    
    func notificationStream(name: NSNotification.Name) -> AsyncStream<Notification> {
        AsyncStream { continuation in       // continuation object
            let observe = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: nil) { notification in
                    continuation.yield(notification)
                }
            
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observe)
            }
        }
    }
    
    func usage() {
        // The print("App moved to background") will be executed every time the app goes to background, as long as the usage() method has been called and the Task is still alive.
        Task {
            for await notification in notificationStream(name: UIApplication.didEnterBackgroundNotification) {
                print("App moved to background")
            }
        }
    }
}

// MARK: - Differnce between AsyncSequence and AsyncStream

/**
 
 ✅ Short Answer
 | Type              | What it is                                     | Usage                                                                     |
 | ----------------- | ---------------------------------------------- | ------------------------------------------------------------------------- |
 | **AsyncSequence** | A *protocol* (like `Sequence` but async)       | You conform to it when you want to **define your own streaming type**     |
 | **AsyncStream**   | A *concrete implementation* of `AsyncSequence` | You use it when you want a **ready-made stream you can feed values into** |

 
 So:

 • AsyncStream IS an AsyncSequence
 • But not every AsyncSequence is an AsyncStream
 
 ✅ Real Meaning
 🔷AsyncSequence

 ● A protocol like Sequence
 ● Apple provides built-in async sequences:
 ● URLSession.AsyncBytes
 ● AsyncLineSequence
 ● NotificationCenter.Notifications in iOS 17+
 ● Timer.TimerPublisher bridging
 ● You use it when you're designing your own custom async type (like we did with StockPriceStream)

 Example:
 You implement makeAsyncIterator() and next() yourself.

 🔷 AsyncStream
 ● A utility helper that makes it easy to convert callback-based systems into async sequences
 ● Mainly used when you need to "push" values into the stream manually using continuation.yield()

 Example:
 Perfect for NotificationCenter, WebSockets callbacks, delegates, async timers, etc.
 
 ✅ When to use each one?
 | Situation                                                                                       | Use                                              |
 | ----------------------------------------------------------------------------------------------- | ------------------------------------------------ |
 | You already have async data (e.g. URLSession async bytes, async iterator provided by framework) | **AsyncSequence** (just `for await`)             |
 | You want to create your own sequence manually                                                   | **AsyncSequence** + custom iterator              |
 | You want to adapt callbacks, delegates, Combine, sensors, timers, WebSockets, etc.              | **AsyncStream**                                  |
 | You need to push values manually (`yield`)                                                      | **AsyncStream**                                  |
 | You need buffering, backpressure, continuation control                                          | **AsyncStream** (it supports buffering policies) |

 
 ✅ Code Comparison
 Example using AsyncStream (push values manually)
 let stream = AsyncStream<Int> { continuation in
     continuation.yield(1)
     continuation.yield(2)
     continuation.yield(3)
     continuation.finish()
 }

 Example creating your own AsyncSequence
 struct Counter: AsyncSequence {
     typealias Element = Int
     let max: Int
     
     struct Iterator: AsyncIteratorProtocol {
         var current = 0
         let max: Int
         
         mutating func next() async -> Int? {
             guard current < max else { return nil }
             current += 1
             return current
         }
     }
     
     func makeAsyncIterator() -> Iterator {
         Iterator(max: max)
     }
 }

 ✅ Analogy
 | Concept         | Analogy                                                               |
 | --------------- | --------------------------------------------------------------------- |
 | `AsyncSequence` | The **recipe** (a definition)                                         |
 | `AsyncStream`   | A **microwave** (tool that helps you cook without writing the recipe) |
 
 ➡️ - `How to use asyncStream with AsyncSequence
 */


// MARK: - 🔹 Bridging Delegate/Combine APIs

// Mant iOS APIs still use delgates or callbacks. With AsyncStrem, we can bridge them into async/await.
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var continuation: AsyncStream<CLLocation>.Continuation?
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        for location in locations {
            continuation?.yield(location)
        }
    }
}

class UseLocationDelegate {
    func locationStream(manager: CLLocationManager) -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            let delegate = LocationDelegate()
            delegate.continuation = continuation
            manager.delegate = delegate
            manager.startUpdatingLocation()
            
            // Stop updates when stream is terminated
            continuation.onTermination = { _ in
                manager.stopUpdatingLocation()
            }
        }
    }
    
    func usage() {
        Task {
            let manager = CLLocationManager()
            for await location in locationStream(manager: manager) {
                print("📍 Location update:", location)
            }
        }
    }
}


/**
 
 ✅ The core difference between a delegate and an AsyncStream is this:
 
 | Concept          | Delegate                                                 | AsyncStream                                                        |
 | ---------------- | -------------------------------------------------------- | ------------------------------------------------------------------ |
 | Style            | Callback-based (inverted control)                        | Async/await (linear, structured)                                   |
 | Execution        | Not naturally async — can't `await`                      | Fully async — suspend/resume automatically                         |
 | Consumer control | Delegate *pushes* values to you                          | You *pull* values when ready (`next()` or `for await`)             |
 | Cancellation     | Manual cleanup required                                  | Built-in cancellation, automatic cleanup (`onTermination`)         |
 | Composability    | Hard to chain, map, filter, merge                        | Uses `AsyncSequence` operators like `.map`, `.filter`, `.throttle` |
 | SwiftUI usage    | Requires @ObservableObject, delegates, strong references | Works directly inside `.task {}` with `for await`                  |
 | Memory model     | Must store delegate strongly to keep it alive            | No need to store anything — stream owns continuity                 |
 | Threading        | You must dispatch manually to main thread                | AsyncStream values resume on caller’s context                      |

 🔍 Let's compare with a simple example
 ✅ 1. Delegate version (callback-based)
 class LocationDelegate: NSObject, CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager,
                          didUpdateLocations locations: [CLLocation]) {
         print("📍 New location:", locations.last!)
     }
 }

 let manager = CLLocationManager()
 let delegate = LocationDelegate()
 manager.delegate = delegate
 manager.startUpdatingLocation()

 🔴 Problems:

 • You cannot await the next location
 • You must keep delegate alive or it stops working
 • No automatic stop → must manually call stopUpdatingLocation()
 • Hard to combine with other async data sources (network, sensors, etc.)
 • Hard to use in SwiftUI view lifecycle (onAppear / onDisappear)

 ✅ 2. AsyncStream version (async/await)
 func locationStream(manager: CLLocationManager) -> AsyncStream<CLLocation> {
     AsyncStream { continuation in
         let delegate = LocationDelegate()
         delegate.continuation = continuation
         manager.delegate = delegate
         manager.startUpdatingLocation()

         continuation.onTermination = { _ in
             manager.stopUpdatingLocation()
         }
     }
 }

 Task {
     let manager = CLLocationManager()
     for await location in locationStream(manager: manager) {
         print("📍 New location:", location)
     }
 }

 🟢 Benefits:

 ✅ Behaves like a live asynchronous list of values
 ✅ for await suspends until a new value arrives — no callbacks
 ✅ Clean cancellation (task.cancel() automatically stops updates)
 ✅ No need to store a delegate — lifetime is tied to the stream
 ✅ Can map, filter, debounce, prefix, etc.
 ✅ SwiftUI-friendly
 
 
 💡 Main conceptual difference
 🔴 Delegate = inverted control - Framework calls you, you react.
 🟢 AsyncStream = you control consumption flow - You request the next value by awaiting:
 
 
 🔧 Best Practices & Common Pitfalls - https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-6-async-sequences-and-streams-c402a4251308
 */

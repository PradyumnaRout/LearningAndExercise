//
//  AdvancedCombinePartNine.swift
//  LearningAndExercise
//
//  Created by hb on 30/10/25.
//

/// https://blog.stackademic.com/mastering-combine-in-swift-part-9-advanced-combine-4b2f03130f8c

import Foundation
import Combine

// 🔷 1. Custom Publishers
struct CustomTimerPublisher: Publisher {
    typealias Output = Date
    typealias Failure = Never
    
    private let interval: TimeInterval
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Date == S.Input {
        
    }
}

final class CusotmTimerSubscription<S: Subscriber>: Subscription where S.Input == Date {
    private var subscriber: S?
    private var timer: Timer?
    
    init(subscriber: S, interval: TimeInterval) {
        self.subscriber = subscriber
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            _ = subscriber.receive(Date())
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        // Here we could respect demand if needed
    }
    
    func cancel() {
        timer?.invalidate()
        subscriber = nil
    }
}

// Usage :
/*
 let cancellable = CustomTimerPublisher(interval: 1)
     .sink { print("Tick: \($0)") }
 */

class MulticastInCombine {
    
    var cancellable = Set<AnyCancellable>()
    
    // 🔷 Share - share() turns the upstream publisher into a multicast publisher:
    // By default, each subscriber triggers the publisher separately, which can be inefficient `(especially for NETWORK CALLS)`.
    
    //🧩 What Happens without .share()
    func callWithoutShare() {
        let publisehr = URLSession.shared.dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
            .map(\.data)
        
        publisehr
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 1: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        publisehr
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 2: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        /**
         ❌ Problem :
         
         Each .sink subscribers `separately` to the dataTaskPublisher.
         That means:
         🔘 Each subscriber triggers its own network request as it is a cold publisher.
         🔘 You'll get two HTTP requests to the same URL
         
          so your console would show:
                 Subscriber 1: 83 bytes
                 Subscriber 2: 83 bytes
         
         but two request actually hit the same server.
         */
    }
    
    // 🧠 What .share() Does?
    /**
     ✅ Behavior

     🔘.share() turns your cold publisher (each subscriber starts a new operation) into a hot publisher (one shared stream of values).
     🔘The first subscriber triggers the network request.
     🔘The result is shared with all other subscribers.
     🔘Only one HTTP request happens.
     🔘All subscribers receive the same value.
     
     ⚙️ 3. What .share() Actually Is (Under the Hood)

     .share() is shorthand for:
     
     `.multicast(subject: PassthroughSubject<Output, Failure>())`
     `.autoconnect()`
     

     That means it:
     ➡️ Internally creates a PassthroughSubject to fan out values.
     ➡️ Connects automatically when the first subscriber appears.
     ➡️ Shares the result with all subscribers.
     ➡️ Ends when the source publisher completes or fails.
     So it’s a reference-counted, replay-less sharing operator.
     
     🧱 5. Analogy
     `Without .share()`                                         `With .share()`
     Each subscriber orders their own pizza 🍕      Everyone shares the same pizza slice by slice 🍕
     Multiple HTTP requests                         One shared HTTP request
     “Cold” publisher                               “Hot” publisher
     
     
     ⚠️ 6. Important Caveats

     📕.share() does not replay past values to new subscribers.
     → If you need replay behavior (e.g., late subscribers still get the last value), use .share(replay: 1) (in Swift 5.9+) or multicast with CurrentValueSubject.

     📕.share() stops sharing after the source completes or fails.
     → If you resubscribe later, it’ll start again with a new subscription.
     */
    func callWithShare() {
        let publisehr = URLSession.shared.dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
            .map(\.data)
            .share()
        
        publisehr
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 1: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        publisehr
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 2: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        /**
         Only one network request.
         Both subscribers print the same output:

         Subscriber 1: 83 bytes
         Subscriber 2: 83 bytes
         */
        
    }
    
    func foo() {
        let publisher = Future<String, Never> { promise in
            print("Calling future")
            return promise(.success("Hello Future"))
        }
            .share()
        
        
        publisher
            .sink { value in
                print("Publisher One: \(value)")
            }
            .store(in: &cancellable)
        
        publisher
            .sink { value in
                print("Publisher Two: \(value)")
            }
            .store(in: &cancellable)
    }
    
    /**
     Output without .share()
     
     Calling future
     Publisher One: Hello Future
     Publisher Two: Hello Future
     
     
     Output with .share()
     Calling future
     Publisher One: Hello Future
     
     Why didn’t Publisher Two fire?
     That means:

     First sink subscribes → triggers the Future
     Future immediately completes
     Second sink subscribes after it already completed
     share() does not replay values
     It only shares live emissions.
     
     .multicast(subject: CurrentValueSubject<String?, Never>(nil))
     .autoconnect()
     
     You can use the above to print the latest value in the above share case.
     Here the future block will only call one time because of .share().
     🧠 The output will be smae if you use deffered also.
     */
    
    
    // MARK: -  Easily Accessable Example of .share()
    
    func exampleWithShare() {
        
        let defferPub = Deferred {
            Future<String, Never> { promise in
                print("Entering into the publisehr")
                promise(.success("Successfully Fetched data!"))
            }
        }.share()
        
        
        // Subscribe with subscriber one
        defferPub
            .sink { value in
                print("Fetched Data: \(value)")
            }
            .store(in: &cancellable)
        
        // Subscribe with subscriber two
        defferPub
            .sink { value in
                print("Fetched Data: \(value)")
            }
            .store(in: &cancellable)
        
    }
    
    func callWithMultiCast() {
        let subject = PassthroughSubject<Data, URLError>()
        
        let multicasted = URLSession.shared.dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
            .map(\.data)
            .multicast(subject: subject)
//            .autoconnect()
        
        multicasted
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 1: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        multicasted
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { data in
                print("Subscriber 2: \(data.count) bytes")
            })
            .store(in: &cancellable)
        
        // magic Key which connect the subscribers to one.
        multicasted.connect().store(in: &cancellable)
    }
    
    // 🔷 multicast()
    /**
     🧩 1. The default problem — duplicate upstream work

     If you use a simple Combine chain like this:
     
    let publisher = URLSession.shared.dataTaskPublisher(for: url)
         .map(\.data)
     
     and then you attach two subscribers:
     
    publisher.sink { print("A:", $0.count) }
    publisher.sink { print("B:", $0.count) }
     
     You’ll make two separate HTTP requests ❌

     Why?
     Because Combine publishers are “cold” by default — each new subscription starts the upstream work again.
     
     🧠 2. What .multicast(subject:) does
     .multicast(subject:) is an operator that gives you fine-grained control over when the upstream publisher starts producing values.

     `Its job:`
     Create a “hot” shared stream — but don’t start it automatically.

     You pass in a Subject (like PassthroughSubject or CurrentValueSubject) that acts as the hub through which values are fanned out to multiple subscribers.
     
     ⚙️ 3. Your code, step by step:
     
    let subject = PassthroughSubject<Data, URLError>()
     
     🔘A PassthroughSubject is a “hot” publisher — it can send values manually and multicast them to any subscribers.
     🔘It will be the fan-out point for your shared stream.
     
     
    let multicasted = URLSession.shared.dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
         .map(\.data)
         .multicast(subject: subject)
     
     ➡️.multicast(subject:) wraps your dataTaskPublisher so that:
     🔘All downstream subscribers get values through your subject
     🔘The network request (upstream) doesn’t start until you connect manually
     🔘At this stage, nothing has run yet — no network call has happened.
     
    multicasted
         .sink { print("Subscriber A: \($0.count) bytes") }
         .store(in: &cancellables)

    multicasted
         .sink { print("Subscriber B: \($0.count) bytes") }
         .store(in: &cancellables)
     
     ✅ Both subscribers are attached — but still, nothing has started.
     They’re simply waiting to receive values from the subject.
     
    multicasted.connect().store(in: &cancellables)
     
     🔥 This line is the magic key.
     🔘.connect() tells the multicasted publisher to subscribe to its upstream (dataTaskPublisher) and start emitting values.
     🔘When the upstream emits a value (the HTTP response), it sends it to the subject.
     🔘The subject fans out the value to all downstream subscribers.
     
     Now:
     🔘Only one HTTP request is made.
     🔘Both subscribers receive the same data.
     
     `Output:`
         Subscriber A: 83 bytes
         Subscriber B: 83 bytes
     
     🧱 4. Analogy
     Concept                            Analogy
     dataTaskPublisher              A chef who starts cooking whenever anyone orders
     .multicast(subject:)           A waiter who says: “Let’s wait until everyone’s seated before telling the chef to start.”
     .connect()                     The signal to start cooking (one meal shared among everyone)
     subject                        The serving table where everyone takes their portion
     
     🧠 5. Why use .multicast()?
     🔘It’s mainly useful when you need:
     🔘Manual control over when the upstream work begins (deferred start)
     🔘Shared data for multiple subscribers (hot stream)
     🔘Custom behavior through a specific Subject type
     
     `Example:
     You might want to attach multiple subscribers before starting a long-running or expensive operation (like a network call, file load, or computation).
     
     🧩 6. Comparison: .share() vs .multicast()
     Feature                                                    .share()                                .multicast(subject:)
     Starts automatically when first subscriber appears             ✅                                   ❌ (must call .connect())
     Automatically uses internal subject                            ✅                                   You provide your own
     Easy one-liner for sharing                                     ✅                                   Gives you full manual control
     Reconnect behavior                                  Restarts on new subscriptions                  You decide when to reconnect

    So .share() is basically a convenient wrapper around .multicast(PassthroughSubject()) + .autoconnect().
     */
}

// MARK: - HOT AND COLD PUBLISHER:

/**
 `If I create a PassthroughSubject, and multiple subscribers subscribe to it, will sending one value through the subject go to all subscribers?”

 ✅ Yes — exactly!
 `A PassthroughSubject (and all Combine Subjects) broadcasts emitted values to all of its active subscribers.
 `That’s what makes it a “hot” publisher.

 Let’s unpack this carefully 👇

 🧩 1. What a Subject is

 A Subject in Combine is a special kind of publisher that you can manually control.
 You can:
 🔘send values to it (.send(value))
 🔘send completions (.send(completion:))
 🔘Have multiple subscribers listening to it.

 ⚙️ 2. Example
         import Combine
         var cancellables = Set<AnyCancellable>()
         let subject = PassthroughSubject<String, Never>()
         subject
             .sink { print("Subscriber 1 received: \($0)") }
             .store(in: &cancellables)

         subject
             .sink { print("Subscriber 2 received: \($0)") }
             .store(in: &cancellables)

         // Send a value manually
         subject.send("Hello, Combine!")

 Output:
 Subscriber 1 received: Hello, Combine!
 Subscriber 2 received: Hello, Combine!


 ✅ Both subscribers get the same event because the subject fans out everything it sends to all active subscribers.

 🧠 3. Why? Because Subjects are “Hot” Publishers

 Combine publishers come in two broad types:

 Type                                   Description                                                                     Example
 Cold publishers    Start their work when subscribed. Each subscriber gets its own independent execution.     URLSession.dataTaskPublisher,                                                                                                              Just, etc.
 Hot publishers     Continuously emit values, regardless of when subscribers attach.                          PassthroughSubject,                                                                                                                        CurrentValueSubject,                                                                                                                       Timer.publish, etc.

 A Subject is hot — it starts “sending” as soon as you call .send().
 If you call .send() before anyone subscribes, that value is lost (no buffering by default).
 */


/**
 🔵4. Performance Considerations
 Combine pipelines can get heavy if not managed properly. Here are some tips:

 🔘Use share() to avoid duplicate upstream work.
 🔘Prefer map over flatMap when possible (to reduce subscriptions).
 🔘Minimize usage of eraseToAnyPublisher unless abstraction is required (it adds a layer of indirection).
 🔘Be mindful of backpressure.
 
 🔵5. Memory Management in Combine
 One of the most common mistakes with Combine is memory leaks due to retained subscriptions.

 Best Practices:
 🔘Always store subscriptions in Set<AnyCancellable>
 🔘Use [weak self] in sinks to avoid reference cycles
 🔘Cancel subscriptions when not needed

 */

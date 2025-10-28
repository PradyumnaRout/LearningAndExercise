//
//  CustomPublisherAndSubscribers.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

import Foundation
import Combine

// Some Important points about publisher and subscribers - https://chatgpt.com/share/68c9003a-c4d4-800e-8e60-ed998ea15f51
/**
 ✅ 4️⃣ – Simplified Data Flow

 Publisher → Calls subscriber.receive(subscription: subscription)

 Subscriber → Calls subscription.request(_:) to specify how many values it wants.

 Subscription → Sends exactly that many values using subscriber.receive(value).

 Completion happens via subscriber.receive(completion:).

 ✅ Visualization
 Publisher --> [Subscription] <---> [Subscriber]
     ↑                                 ↑
     |                                request(.max(n))
  create subscription               receive(value) / receive(completion)
 */

// Custom Publisher
struct NumberPublisher: Publisher {
        
    typealias Output = Int
    typealias Failure = Never
    
    func receive<S>(subscriber: S) where S: Subscriber, NumberPublisher.Failure == S.Failure, NumberPublisher.Output == S.Input {
        let subscription = NumberSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

// Custom Subscriber
final class NumberSubscription<S: Subscriber>: Subscription where S.Input == Int, S.Failure == Never {
    
    private var subscriber: S?
    private var current = 1
    private let max = 5
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        // Loop and send values as long as demand allows
        var remainingDemand = demand
        while remainingDemand > 0 && current <= max {
            _ = subscriber?.receive(current)
            current += 1
            remainingDemand -= 1
        }
        
        // After sending all values, send completion
        if current > max {
            subscriber?.receive(completion: .finished)
        }
    }
    
    func cancel() {
        // Stop sending values and break retain cycle
        subscriber = nil
    }
}


// Example Usage
let publisher = NumberPublisher()

let cancellable = publisher.sink(
    receiveCompletion: { completion in
        print("Completed: \(completion)")
    },
    receiveValue: { value in
        print("Received value: \(value)")
    }
)


// ✅ Custom Publisher
protocol MyPublisher {
    associatedtype Output
    associatedtype Failure: Error
    
    func subscribe<S: MySubscriber>(_ subscriber: S) where S.Input == Output, S.Failure == Failure
}

// Custom Subscriber
protocol MySubscriber {
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(subscription: MySubscription)
    func receive(_ input: Input)
    func receive(completion: Subscribers.Completion<Failure>)
    
}

// Custom Subscription
protocol MySubscription {
    
    var inputValue: String { get set }
    
    func request(_ demand: String)
    func cancel()
}


// StirngPublisher
struct StringPublisher: MyPublisher {
    typealias Output = String
    typealias Failure = Never
    
    let inputValue: String
    
    func subscribe<S>(_ subscriber: S) where S : MySubscriber, Never == S.Failure, String == S.Input {
        let subscription = StringSubscription(subscriber: subscriber, inputValue: inputValue)
        subscriber.receive(subscription: subscription)
        
    }
}

// String Subscriber
final class StringSubscriber: MySubscriber {
    typealias Input = String
    typealias Failure = Never
    
    private var subscription: MySubscription?       // Optional if you want to cancel or to call other method outside the function

    func receive(subscription: MySubscription) {
        self.subscription = subscription
        
        if subscription.inputValue.count > 5 {
            subscription.request(subscription.inputValue)
        }
    }

    func receive(_ input: String) {
        print("Received value: \(input)")
//        subscription?.cancel()   // ✅ Cancel from subscriber logic
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("Completed: \(completion)")
    }
}

// Subscription
final class StringSubscription<S: MySubscriber>: MySubscription where S.Input == String, S.Failure == Never {
    var inputValue: String
    private var subscriber: S?
    private var isCancelled = false
    
    init(subscriber: S, inputValue: String) {
        self.subscriber = subscriber
        self.inputValue = inputValue
    }
    
    func request(_ demand: String) {
        guard !isCancelled else { return }
        
        if demand.contains("h") {
            subscriber?.receive("Allowed Value: \(demand)")
        } else {
            subscriber?.receive(completion: .finished)
        }
    }
    
    func cancel() {
        isCancelled = true
        subscriber = nil
    }
}

 


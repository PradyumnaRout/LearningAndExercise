//
//  CombinePartOne.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

/// https://blog.stackademic.com/mastering-combine-in-swift-part-1-introduction-to-combine-0a9ca1f4a9b1
/**
 Combine - Apple reactive framework, which allows you to define
 1. Define publisher that emits values over time.
 2. Define subscrbers that reacts those Values.
 3. Define operators to transform and manipulate data stream.
 
 Publisher -> Operator -> Subscriber
 
 Core Concept -  4 Key building blocks of combine -
 
 1. Publisher - Emits values over time.
 2. Subscriber - Receive and reacts to values.
 3. Operator - Transforms or filters the values between publisher and subscriber.
 4. Cancellable - A token to stop the subscription.
 
 
 There are two common types of publisher in Combine
 1. Cold Publisher - They start working only when someone listens. Each subscriber triggers the story from the beginning.
    Just
    URLSession.dataTaskPublisher
    Future
 
    example -
     let pub = Just("✨")

     pub.sink { print("A: \($0)") }
     pub.sink { print("B: \($0)") }
        
     A: ✨
     B: ✨
 
 
 2. Hot Publishers - They already shout information into the room. Subscribers only here what arrives after they join the party.
 
    PassthroughSubject
    CurrentValueSubject
    Timers
 
     let subject = PassthroughSubject<String, Never>()
     subject.send("First!") // Nobody hears this

     subject.sink { print("A: \($0)") }
     subject.send("Second!") // A hears this
 
 
 🔹 Key Takeaways from Part 1 ->
 Combine = Unified framework for handling asynchronous values.
 A publisher emits values → a subscriber consumes them.
 Operators allow transforming, filtering, and combining values.
 Everything in Combine is composable and declarative.
 
 */

import Combine

//First Example Just Publisher

class JustPublisher {
    // Cancellable
    var cancellable = Set<AnyCancellable>()
    
    // Publisher
    let publisher = Just("Hello Combine")   // A publisher that emits one string.
    
    // Subscriber
    func subscibeJust() {
        publisher
            .sink { value in    // A subscriber that prints the value
                print("Received value: \(value)")
            }
            .store(in: &cancellable)    // Keeps the subscription alive.
    }
}

// Example 2 - Transforming Data with an operator
// Here, numbers.publisher creates a publisher from an array. The map operator transforms each value before the subscriber receives it.
class DataTransformingWithOperator {
    var cancellable = Set<AnyCancellable>()
    let numbers = [1, 2, 3, 4, 5]
    
    func operateData() {
        numbers.publisher
            .map { $0 * 2 }
            .sink { value in
                print("Doubled Value: \(value)")
            }
            .store(in: &cancellable)
    }
}

// Example 3 - Handling Completion
/// Publisher can emit values and then complete or fail. Let's print both values and comletion status.
class CombineCompletion {
    var cancellable = Set<AnyCancellable>()
    let publisher = ["A", "B", "C"].publisher
    
    func handleCompletion() {
        publisher
            .sink { completion in
                print("Completed with: \(completion)")
            } receiveValue: { value in
                print("Received: \(value)")
            }
            .store(in: &cancellable)

    }
}

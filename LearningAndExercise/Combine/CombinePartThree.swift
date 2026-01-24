//
//  CombinePartThree.swift
//  LearningAndExercise
//
//  Created by hb on 28/10/25.
//

import Foundation
import Combine

// MARK:  🔷 Subscriber:
/*
➡ If a publisher is the "Speaker", then a subscriber is the "Listner". Without subscribers, no values flow in combine - the pipeline stays idle.
 
 🔵 A Subsciber is responsible for -
 ➡ Receiving values from a publisher.
 ➡ Handling Completion events(Success or Failure).
 ➡ Controlling how much demand it has for values.
 
 In other words subscribers decide what to do with data once it is published.
 
 Formally a Subscriber Conforms to the Subscriber Protocol.
 
     protocol Subscriber {
         associatedtype Input
         associatedtype Failure: Error
         
         func receive(subscription: Subscription)
         func receive(_ input: Input) -> Subscribers.Demand
         func receive(completion: Subscribers.Completion<Failure>)
     }
 
 
 🔹 Key Takeaways
         Subscribers consume values emitted by publishers.
         sink is the go-to subscriber for quick value handling.
         assign is perfect for directly binding values to object properties.
         Subscribers can control demand to manage how many values they want at once.
    
*/

// 🔹 Built-in Subscribers
// sink ::
/**
 The most commonly used subscriber.
 it lets you provide tow closure:
 
 ● One for handling values.
 ● One for handling completion (Success or Failure).
 */

class SinkSubscriber {
    var cancellable = Set<AnyCancellable>()
    let numbers = [1,2,3,4,5]
    
    func subscribe() {
        numbers.publisher
            .sink { completion in
                switch completion {
                case .finished:
                    print("Values fetched successfully")
                case .failure(let error):
                    print("Error occured: \(error)")
                }
            } receiveValue: { value in
                print("Value: \(value)")
            }
            .store(in: &cancellable)

    }
}

// assign ::
// A subscriber that automatically assigns received values to a property.
// 👉 assign is super useful for updating UI properties or model values directly.

class AssignSubscriber {
    var cancellable = Set<AnyCancellable>()
    var name: String = "" {
        didSet {
            print("User name updated to: \(name)")
        }
    }
    
    class Usage {
        func subscribe() {
            let user = AssignSubscriber()
            let namePublisher = ["Alice", "Bob", "Charlie"].publisher
            
            namePublisher
                .assign(to: \.name, on: user)
                .store(in: &user.cancellable)
        }

    }
    
    func subscribe() {
        let namePublisher = ["Alice", "Bob", "Charlie"].publisher
        
        namePublisher
            .assign(to: \.self.name, on: self)
            .store(in: &cancellable)
        
        /* Output - 
         User name updated to: Alice
         User name updated to: Bob
         User name updated to: Charlie
         */
    }
}

// 🔹 Demand and Backpressure ::
/**
 
 One unique aspect of combine is backpressure handling.
 Subscribers can control how many vlaues they want to receive at a time using demand.
 

 👉 Even though the publisher had 5 values, the subscriber only requested 2.
 This mechanism helps prevent overwhelming subscribers with too much data.
 */

final class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: any Subscription) {
        print("Subscribed")
//        subscription.request(.max(3))   // Request only 3 values.
        subscription.request(.none)     // won't produce any value.
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received \(input)")
//        return .none
        return .max(2)
        // “Every time I get a value, I can handle 2 more.
        // So demand never reaches zero.
        
        /**
         
         Key rule (keep this in mind)

         📌 Demand is cumulative

         Total demand =

         (what you requested before)

         (what you return from receive(_:))
         − (values already delivered)

         Step-by-step timeline
         🔹 Step 0 — Subscription happens
         subscription.request(.max(3))


         🧮 Demand = 3

         Publisher is now allowed to send up to 3 values.

         🔹 Step 1 — Publisher sends 1
         Received 1


         What happens internally:

         Demand was 3

         1 value delivered → demand becomes 2

         You return .max(2) → add 2

         🧮 New demand = 2 + 2 = 4

         🔹 Step 2 — Publisher sends 2
         Received 2


         Demand was 4

         1 delivered → 3

         You return .max(2)

         🧮 New demand = 3 + 2 = 5

         🔹 Step 3 — Publisher sends 3
         Received 3


         Demand was 5

         1 delivered → 4

         Return .max(2)

         🧮 New demand = 4 + 2 = 6

         🔹 Step 4 — Publisher sends 4
         Received 4


         Demand was 6

         1 delivered → 5

         Return .max(2)

         🧮 New demand = 7

         🚨 Important observation

         Even though you initially requested only 3 values,
         your subscriber is now saying:

         “Every time I get a value, I can handle 2 more.”

         So demand never reaches zero.

         This subscriber will receive infinite values.
         */
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completed")
    }
}

struct UseIntSubscriber {
    func callIntSubs() {
        let publisher = [10,20,30,40,50,60].publisher
        
        let filterPublisher = [10, 20, 30, 40, 50, 60].publisher
            .map { $0 * 2 }
            .filter { $0 > 40 }
        
        let subscriber = IntSubscriber()
        
        filterPublisher.subscribe(subscriber)       // Output - 60, 80, 100 (the first three which matched the condition)
    }
    
    // Can also use subjects (Passthrough/CurrentValue)
    func testPassThrough() {
        let subject = PassthroughSubject<Int, Never>()
        let subscriber = IntSubscriber()
        
        subject.subscribe(subscriber)
        
        subject.send(5)
        subject.send(10)
        subject.send(15)
        subject.send(20)
        subject.send(completion: .finished)
        
        /**
         Output -
                 Subscribed
                 Received 5
                 Received 10
                 Received 15
                 Completed
         */
    }
    
    func testCurrentValue() {
        let subject = CurrentValueSubject<Int, Never>(1)
        let subscriber = IntSubscriber()
        
        subject.subscribe(subscriber)
        
        subject.send(20)
        subject.send(30)
        subject.send(40)
        subject.send(50)
        subject.send(completion: .finished)
        
        /**
         Output -
                 Subscribed
                 Received 1
                 Received 20
                 Received 30
                 Completed
         */
    }
}


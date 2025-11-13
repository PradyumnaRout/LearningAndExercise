//
//  CustomPublisher&Subscriber.swift
//  LearningAndExercise
//
//  Created by hb on 30/10/25.
//

import Foundation
import Combine

struct Post {
    let id: String
    let title: String
    let caption: String
    let uploadTime: String
    let uploadedBy: String
}

// MARK: - 👉 Custom Publisher and subscription

/// 🔗 `Custom Cold Publisehr`

struct ColdPostPublisher: Publisher {
    typealias Output = Post
    typealias Failure = AppError
    
    let post: Post
    
    func receive<S>(subscriber: S) where S : Subscriber, AppError == S.Failure, Post == S.Input {
        let subscription = ColdPostSubscriptoin(subscriber: subscriber, post: post)
        subscriber.receive(subscription: subscription)
    }
}

// Custom Subscription
final class ColdPostSubscriptoin<S: Subscriber>: Subscription where S.Input == Post {
    
    private var subscriber: S?
    private var post: Post?
    
    init(subscriber: S, post: Post) {
        self.subscriber = subscriber
        self.post = post
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard let post else {
            subscriber?.receive(completion: .failure(AppError.self as! S.Failure))
            return
        }
        if post.id == "10" {
            let _ = subscriber?.receive(post)
        } else {
            print("Matched data not found")
            subscriber?.receive(completion: .finished)
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

class CallingColdCustomPublisher {
    var cancellable = Set<AnyCancellable>()
    
    func testCustomPublisher() {
        let post1 = Post(
            id: "10",
            title: "Sunset Over the Hills",
            caption: "Captured this amazing view during my hike 🌄",
            uploadTime: "2025-10-31T18:45:00Z",
            uploadedBy: "alex_w"
        )
        
        ColdPostPublisher(post: post1)
            .sink { completion in
                print("\(completion)")
            } receiveValue: { post in
                print("Post Id: \(post.id)")
            }
            .store(in: &cancellable)
    }
}


/// 🔗 `Custom HOT Publisher with no extra operation in "func request(_ demand: Subscribers.Demand)"`

// 🖍️ With Subscriber
final class CustomHotPublisher: Publisher {
    typealias Output = Post
    typealias Failure = AppError
    
    private var subscriber: AnySubscriber<Post, AppError>?
    private var isCompleted = false
    
    func receive<S>(subscriber: S) where S: Subscriber, AppError == S.Failure, Post == S.Input {
        // Store subscriber reference so that we can send the data
        self.subscriber = AnySubscriber(subscriber)
        
        // Cretae and send a custom subsciption
        let subscription = CustomHotSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
        // Calling through subscription , so it will call the request method of subscription and in that method again receive(_ value: Input) -> Subscribers.Demand will get called.
    }
    
    // Custom send method (manually push values)
    func send(_ post: Post) {
        guard !isCompleted else { return }
        let _ = self.subscriber?.receive(post)          // receive(_ value: Input) -> Subscribers.Demand
    }
    
    // Send a completion event
    func send(_ completion: Subscribers.Completion<AppError>) {
        isCompleted = true
        subscriber?.receive(completion: completion)
    }
}

//MARK: - Custom HOT Subscription
final class CustomHotSubscription<S: Subscriber>: Subscription where S.Input == Post, S.Failure == AppError {
    private var subscriber: S?
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        // We’re not limiting demand in this simple example
    }
    
    func cancel() {
        subscriber = nil
    }
}

// MARK: - Example Usage
class PostManager {
    private var cancellables = Set<AnyCancellable>()
    private var publisher = CustomHotPublisher()
    
    func testCustomPublisher() {
        // Subscribe Once
        publisher
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { post in
                print("📬 Received Post: \(post.title)")
            }
            .store(in: &cancellables)
        
        // Send multiple posts over time
        let post1 = Post(id: "001", title: "First Post", caption: "🌄", uploadTime: "2025-10-31", uploadedBy: "alex")
        let post2 = Post(id: "10", title: "Second Post", caption: "☕️", uploadTime: "2025-11-01", uploadedBy: "sophia")
        let post3 = Post(id: "11", title: "Third Post", caption: "💻", uploadTime: "2025-11-02", uploadedBy: "jane")
        
        publisher.send(post1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.publisher.send(post2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.publisher.send(post3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.publisher.send(.finished)
        }
    }
}

/// 🔗 `Custom HOT Publisher with extra operation in "func request(_ demand: Subscribers.Demand)"`
// 🖍️ With Subscriber
final class HotPublisher: Publisher {
    typealias Output = Post
    typealias Failure = AppError
    
    private var subscriber: AnySubscriber<Post, AppError>?
    private var isCompleted = false
    
    // subscription declaration for data cusotmization and forcefull error send.
    private var subscription: HotSubscription<AnySubscriber<Post, AppError>>?
    
    func receive<S>(subscriber: S) where S: Subscriber, AppError == S.Failure, Post == S.Input {
        // Store subscriber reference so that we can send the data
        let anySubscriber = AnySubscriber(subscriber)
        self.subscriber = anySubscriber
        
//         Cretae and send a custom subsciption
        let subscription = HotSubscription(subscriber: anySubscriber)
        self.subscription = subscription
        
        subscriber.receive(subscription: self.subscription ?? subscription)
    }
    
    // Custom send method (manually push values)
    func send(_ post: Post) {
        guard !isCompleted else { return }
        //let _ = self.subscriber?.receive(post)
        subscription?.receive(post)
    }
    
    // Send a completion event
    func send(_ completion: Subscribers.Completion<AppError>) {
        isCompleted = true
        subscriber?.receive(completion: completion)
        subscription?.cancel()
        subscription = nil
        subscriber = nil
    }
}

//MARK: - Custom HOT Subscription
final class HotSubscription<S: Subscriber>: Subscription where S.Input == Post, S.Failure == AppError {
    private var subscriber: S?
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        // We’re not limiting demand in this simple example
    }
    
    func receive(_ post: Post) {
        if post.id.isEmpty {
            subscriber?.receive(completion: .failure(AppError.other("Find empty in id")))
            print("Subscriber is nill now")
            self.cancel()
        } else {
            let _ = subscriber?.receive(post)
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

// MARK: - Example Usage
class AdvancePostManager {
    private var cancellables = Set<AnyCancellable>()
    private var publisher = HotPublisher()
    
    func testCustomPublisher() {
        // Subscribe Once
        publisher
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { post in
                print("📬 Received Post: \(post.title)")
            }
            .store(in: &cancellables)
        
        // Send multiple posts over time
        let post1 = Post(id: "001", title: "First Post", caption: "🌄", uploadTime: "2025-10-31", uploadedBy: "alex")
        let post2 = Post(id: "", title: "Second Post", caption: "☕️", uploadTime: "2025-11-01", uploadedBy: "sophia")
        let post3 = Post(id: "11", title: "Third Post", caption: "💻", uploadTime: "2025-11-02", uploadedBy: "jane")
        
        publisher.send(post1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.publisher.send(post2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.publisher.send(post3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.publisher.send(.finished)
        }
    }
}


// MARK: - NEXT EXAMPLE -
///    `Another Example of Custom Hot Publisher`
/*
 import Combine
 import Foundation

 // MARK: - Model
 struct Post {
     let id: String
     let title: String
     let caption: String
     let uploadTime: String
     let uploadedBy: String
 }

 // MARK: - Custom Error
 enum AppError: Error {
     case somethingWentWrong
 }

 // MARK: - Custom Publisher
 final class PostPublisher: Publisher {
     typealias Output = Post
     typealias Failure = AppError
     
     private var subscriptions = [PostSubscription<AnySubscriber<Post, AppError>>]()
     
     func receive<S>(subscriber: S) where S : Subscriber, AppError == S.Failure, Post == S.Input {
         let subscription = PostSubscription(subscriber: AnySubscriber(subscriber))
         subscriptions.append(subscription)
         subscriber.receive(subscription: subscription)
     }
     
     // Send new value to all active subscribers
     func send(_ post: Post) {
         for sub in subscriptions {
             sub.receive(post)
         }
     }
     
     // Send completion to all
     func send(completion: Subscribers.Completion<AppError>) {
         for sub in subscriptions {
             sub.receive(completion)
         }
         subscriptions.removeAll()
     }
 }

 // MARK: - Custom Subscription
 final class PostSubscription<S: Subscriber>: Subscription where S.Input == Post, S.Failure == AppError {
     
     private var subscriber: S?
     private var demand: Subscribers.Demand = .none
     private var buffer: [Post] = []
     private var completed = false
     
     init(subscriber: S) {
         self.subscriber = subscriber
     }
     
     func request(_ newDemand: Subscribers.Demand) {
         // Accumulate demand
         demand += newDemand
         
         // If there’s buffered data, deliver as much as demand allows
         while demand > 0 && !buffer.isEmpty {
             let next = buffer.removeFirst()
             _ = subscriber?.receive(next)
             demand -= 1
         }
     }
     
     func receive(_ post: Post) {
         guard !completed else { return }
         
         if demand > 0 {
             _ = subscriber?.receive(post)
             demand -= 1
         } else {
             // No demand yet → buffer it
             buffer.append(post)
         }
     }
     
     func receive(_ completion: Subscribers.Completion<AppError>) {
         completed = true
         subscriber?.receive(completion: completion)
         subscriber = nil
     }
     
     func cancel() {
         subscriber = nil
         buffer.removeAll()
     }
 }

 // MARK: - Example Usage
 final class PostManager {
     private var cancellables = Set<AnyCancellable>()
     private let publisher = PostPublisher()
     
     func testCustomPublisher() {
         // Subscriber #1
         publisher
             .sink { completion in
                 print("Completion: \(completion)")
             } receiveValue: { post in
                 print("📬 Received Post: \(post.title)")
             }
             .store(in: &cancellables)
         
         // Subscriber #2 (optional example)
         publisher
             .sink(receiveCompletion: { _ in },
                   receiveValue: { print("👀 Mirror Subscriber got: \($0.title)") })
             .store(in: &cancellables)
         
         // Send values
         let post1 = Post(id: "001", title: "First Post", caption: "🌄", uploadTime: "2025-10-31", uploadedBy: "alex")
         let post2 = Post(id: "10", title: "Second Post", caption: "☕️", uploadTime: "2025-11-01", uploadedBy: "sophia")
         let post3 = Post(id: "11", title: "Third Post", caption: "💻", uploadTime: "2025-11-02", uploadedBy: "jane")
         
         publisher.send(post1)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
             self.publisher.send(post2)
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
             self.publisher.send(post3)
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
             self.publisher.send(completion: .finished)
         }
     }
 }

 // MARK: - Run Example
 let manager = PostManager()
 manager.testCustomPublisher()

 */

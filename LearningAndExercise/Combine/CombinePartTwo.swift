//
//  CombinePartTwo.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

import Combine
import Foundation

// Subjects (publisher) - https://medium.com/bumble-tech/understanding-publishers-in-swiftui-and-combine-27806aa78ba1

// MARK:  PUBLISHER IN DEPTH

/// 🔹 What is a Publisher?
/**
  A publisher is an object that emits a sequency of values over time.
 
 It can emit:
 1. Values (one or many)
 2. A completion event (Finished or Failure)
 
 Formally Every publisher in combine must confirm to the Publisher Protocol:
 
 protocol Publisher {
    associatedType Output
    associatedType Failure: Error
 
     func receive<S>(subscriber: S)
        Where S: Subscriber,
              self.Failure == S.Failure
              self.Output == S.Input
 }
 
 
 Output - The type of value it publishes.
 Failure - The type of error it might publish (or Neve if it can not fail).
 
 🔹 LifeCycle of Publisher -  After either a regular finished event or a failure, the subject will pass no more values. This is due    to the lifecycle of a subject.
 
 🔹 Key Takeaways
     🔘Publishers emit values and completion events.
     🔘Just is for one-off values.
     🔘Future is for async, single-value work.
     🔘PassthroughSubject is for manual event broadcasting.
     🔘CurrentValueSubject holds onto the latest value.
     🔘Deferred creates publishers only when subscribed.
     🔘Collections can easily become publishers with .publisher.
 
 🔹 Key Takeaways
     🔘 Subjects are both Publishers and Subscribers.
     🔘 Use PassthroughSubject for event streams.
     🔘 Use CurrentValueSubject for state that should be retained and replayed.
     🔘 They are a great bridge for mixing imperative (manual) code with reactive Combine pipelines.
 */

// 🔹 Common Publishers in Combine
/// 1. Just - A publisher that emits an output to each subscriber just once, and then finishes.
/// Emits single value and then finishes. for example if you want to use it in a UISwitch everytime it chnages sate. You can not do that because it Fires once, then it's done. Your switch keeps flipping, but the publisher is silent.

class JustPub {
    var cancellable = Set<AnyCancellable>()
    let justPublisher = Just("Hello, World")
    let apiURL = URL(string: "http://api.example.com/current-temperature")
    
    struct TemperatureInfo: Codable {
        var city: String
        var temperature: Double
    }
    
    func subscribeJust() {
        justPublisher
            .sink(
                receiveCompletion: { print("Completion: \($0)") },
                receiveValue: { print("Value: \($0)") }
            )
            .store(in: &cancellable)
        
        /*
         Output -
         Value: Hello, World
         Completion: finished
         */
    }
    
    ///Another use case of Just publisher is often employed to initiate another single-run pipeline or to provide a placeholder response as a fallback response when a failure occurs.
    func asFailureError() {
        let temperaturePublisher = URLSession.shared.dataTaskPublisher(for: apiURL!)
        // The dataTaskPublisher output combination of
        // (data: Data, response: URLResponse)
            .map { inputTuple -> Data in
                return inputTuple.data
            }
            .decode(type: TemperatureInfo.self, decoder: JSONDecoder())
            .catch { error in
                // Default value in case of an error
                Just(TemperatureInfo(city: "Unknown", temperature: 72.0))
            }
            .eraseToAnyPublisher()
        
        
        temperaturePublisher.sink { temperatureInfo in
            print("City: \(temperatureInfo.city), Temperature: \(temperatureInfo.temperature)")
        }.store(in: &cancellable)
        
        /*
         Output -
         City: Unknown, Temperature: 72.0
         */
    }
}


/// 2. Future (Future<Output, Failure>)
/**
 A Future in combine is a publisher that eventually produces a single value or an error, facilitated by a Promise.
 The Promise wraps asynchronous operation within an escaping closure, which is called when the Future publisher is ready to emit an event
 
 Important:- When dealing with an asynchronous API that can potentially produce multiple values over time, using the Future publisher directly may not be the best choice, as it’s designed for a single value. Also you can’t use retry operator with it.
 */
/// A Future publisher has the same retirement plan as Just. It performs its work one time and then completes forever. No callbacks after that. No encore performance. In the land of switches that keep flipping, a Future behaves like:
/// “I heard the first toggle! Cool, my job is done. Goodbye.” (switch: keeps flipping wildly but Future is already in Hawaii)
/// Emits a single value in future (Usually async
/// Greate for wrapping asynchronous code (like network request)

class FuturePub {
    enum ProfileError: Error {
        case invalidRequestError(String)
        case decodingError(Error)
    }
    
    
    var cancellable = Set<AnyCancellable>()
    let futurePublisher = Future<String, Error> { promise in
        // Simulating async work
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            promise(.success("Data Loaded"))
        })
    }
    
    func subscribeFuture() {
        print("Future publisher called!")
        futurePublisher
            .sink(
                receiveCompletion: { print("Completion: \($0)") },
                receiveValue: { print("Value: \($0)") }
            )
            .store(in: &cancellable)
    }
    
    // Example - Future that performs a network request.
    func fetchDataFromServer() -> Future<String, Error> {
        return Future { promise in
            // SImulate a network request
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: URL(string: "https://example.com/data")!) {
                    let response = String(data: data, encoding: .utf8)
                    promise(.success(response ?? ""))
                } else {
                    promise(.failure(ProfileError.invalidRequestError("Invalid Request")))
                }
            }
        }
    }
    
    func subscribeDataFromServer() {
        fetchDataFromServer()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Received error: \(error)")
                }
            } receiveValue: { value in
                print("Received data: \(value)")
            }
            .store(in: &cancellable)

    }
}



// 3. Fail - A publisher that immediately terminates with the specified error.
// struct Fail<Output, Failure> where Failure: Error
// https://medium.com/@viveksehrawat36/combine-just-empty-fail-publisher-part-2-1-8dad225c75cc

class FailPub {
    enum ProfileError: Error {
        case invalidRequestError(String)
        case decodingError(Error)
    }
    struct Profile: Decodable {
        let firstName: String
    }
    
    func getProfilePublisher(userId: String) -> AnyPublisher<Profile, ProfileError> {
        guard let url = URL(string: "http://127.0.0.1:8080/profile/\(userId)") else {
            return Fail(error: ProfileError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Profile.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return ProfileError.decodingError(error)
                }
                return error as! FailPub.ProfileError
            }
            .eraseToAnyPublisher()
    }
}


// 3. Subjects
// https://medium.com/@chandresh.kanetiya/subject-in-swift-combine-framework-38ba41446482
// https://ahmadgsufi.medium.com/mastering-the-power-of-subjects-in-combine-a-comprehensive-guide-434ece579c2e (Must Read)
// https://medium.com/bumble-tech/understanding-publishers-in-swiftui-and-combine-27806aa78ba1

// CurrentValueSubject : “I always know the latest state.”
/**
 A subject that manually send values through.
 Think of it like an event emitter (Similar to NotificationCenter)
 
 - CurrentValueSubject : A subject that holds a current value and emits it to new subscribers immediately upon subscription.
     As name suggest this publisher emits and stores the current value of a property. Meaning that when a new value is assigned it will be sent to all the subscriber as expected, but it will also be stored so it can be requested later on for immediate use or requested by new subscribers attached after the value was emitted.
 
 */


class SubjectCurrentValue {
    
    /*
     * Let's create a new instance.
     * You might notice that the publishers need to define Result Types.
     * One for Success, which in our case is Int.
     * and one for Failure, which should represent an Error type but
     * for the purpose of our example we will just say errors Never happen.
     */
    var cancellable = Set<AnyCancellable>()
    let subject = CurrentValueSubject<Int, Never>(0)
    
    func subscribeSubject() {
        // We can consult the value stored right away
//        print("\(subject.value)")
        
        // We can subscribe using `sink` and that will also be called right away
        // and also when a new value is emitted.
        
        subject.sink { newValue in
            print("\(newValue)")
        }
        .store(in: &cancellable)
        
        // Let's update the Value
        subject.send(10)    // 0, 10
        
        subject.sink { newValue in
            print("New Subscriber: \(newValue)")    // New Subscriber: 10
        }
        .store(in: &cancellable)
        
    }
}

class UploaderCurrValSubject {
    enum State {
        case pending, uploading, finished
    }
    
    enum Error: Swift.Error {
        case uploadFailed
    }
    
    let subject = CurrentValueSubject<State, Error>(.pending)
    var cancellable = Set<AnyCancellable>()
    
    func startUploading() {
        subject.send(.uploading)
    }
    
    func finishUpload() {
        subject.value = .finished
        subject.send(completion: .finished)
    }
    
    func failUpload() {
        subject.send(completion: .failure(.uploadFailed))
    }
    
    func subscribe() {
        subject
            .sink { completion in
                switch completion {
                case .finished:
                    print("Received finished")
                case .failure(let error):
                    print("Received error: \(error)")
                }
            } receiveValue: { message in
                print("Received message: \(message)")
            }
            .store(in: &cancellable)
        
        
        self.startUploading()
        self.failUpload()
//        self.finishUpload()
        
        /* output -
         Received message: pending
         Received message: uploading
         Received error: uploadFailed
         */

    }
}


// PassThroughSubject - “I only care about events happening right now.”
/*
 This publisher is initialised with no initial value and can emit multiple values over time but won’t store any of them for future references. The subscriber is attached to the publisher and it will receive all values sent to the publisher using the send(_:) method. However, if a subscriber attaches after a value has been emitted, they won’t be notified. Let’s see this in code
 
 It’s important to note that PassthroughSubject does not buffer values that are sent when no subscribers are listening. If a value is sent and there are no subscribers, the value is simply discarded. If you need to ensure that subscribers receive all values, even those sent before they subscribe, you should use a type of subject that does buffer values, such as ReplaySubject or BehaviorSubject.
 
 */


class SubjectPassThrough {
    /*
     * Again, we are defining a new publisher with no error type
     * to keep the examples as simple as possible.
     * As you can see, this Publisher doesn't get an initial value
     */
    
    let subject = PassthroughSubject<Int, Never>()
    var cancellable = Set<AnyCancellable>()
    /*
     * It sends this value to any subscriber,
     * but because at this point in time it has none,
     * no one will ever know this happened.
     */
    
    func subscribe() {
        subject.send(0)
        
        /*
         * Now we listen for new values
         * But in contrast to CurrentValueSubject nothing will happen
         * at the time of subscribing because there's no value present
         */
        
        subject.sink { newValue in
            print("\(newValue)")
        }.store(in: &cancellable)
        
        subject.send(10) // print appears in console "10"
    }
}


struct ChatRoom {
    enum Error: Swift.Error {
        case missingConnection
    }
    let subject = PassthroughSubject<String, Error>()
    var cancellable = Set<AnyCancellable>()
    
    func simulateMessage() {
        subject.send("Hello!")
    }
    
    func simulateNetworkError() {
        subject.send(completion: .failure(.missingConnection))
    }
    
    func closeRoom() {
        subject.send("Chat room closed")
        subject.send(completion: .finished)
    }
    
    mutating func subscribe() {
        subject.sink { completion in
            switch completion {
            case .finished:
                print("Received finished")
            case .failure(let error):
                print("Received error: (error)")
            }
        } receiveValue: { message in
            print("Received message: (message)")
        }
        .store(in: &cancellable)
    }
    
}

// 4. Deferred: Nested Publisher (Publisher inside Publisher)
/*
 Waits until a subscriber is attached before creating its actual publisher.
 
 Useful when you don’t want the publisher to do work until needed.

 A Deferred publisher in Combine waits until it has a subscriber before initializing the underlying publisher. This delay in creation is useful for optimising performance by avoiding unnecessary work until there’s a demand for data. Additionally, it’s compatible with operators like retry
 */

class DeferredPub {
    var cancellable = Set<AnyCancellable>()
    func subscribe() {
        let deferredPublisher = Deferred {
            Future<String, Never> { promise in
                // Can do api calls and asynchonous work
                print("Creating value...")
                promise(.success("Hello from Deferred"))
            }
        }
        
        // ✅ Subscribe here
        let cancellable = deferredPublisher
            .sink { value in
                print("Received value: \(value)")
            }
        
        let future = Future<String, Never> { promise in
            print("Future started")
            promise(.success("Hi"))
        }

//        print("Before subscribing")
//        future.sink { print("Received:", $0) }
    }
    
    func foo() {
        print("Before creating Future")

        let future = Future<String, Never> { promise in
            print("Lets begin future publisher")
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                print("Here is the result")
                promise(.success("Success"))
            }
        }

        print("After creating Future")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            future
                .sink { value in
                    print("Finished")
                }
                .store(in: &self.cancellable)
        }
        
        /*
         Output -
         Before creating Future
         Lets begin future publisher
         After creating Future
         (2 seconds pass)
         (5 seconds from creation)
         Here is the result
         Finished

         
         What happens:

         The closure runs immediately when Future is created.
         ➡️ "Lets begin future publisher" prints right away.
         ➡️ The async work starts immediately.
         ➡️ Even if no one subscribes, the work still happens.
         ➡️ All subscribers get the same result.
         So this is eager — work starts at creation time.
         */
    }
    
    func foo2() {
        print("Before creating Deferred")

        let deferred = Deferred {
            Future<String, Never> { promise in
                print("Lets begin future publisher")
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    print("Here is the result")
                    promise(.success("Success"))
                }
            }
        }

        print("After creating Deferred")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            deferred
                .sink { _ in
                    print("Finished")
                }
                .store(in: &self.cancellable)
        }
        
        /*
         Output -
         Before creating Deferred
         After creating Deferred
         (2 seconds pass)
         Lets begin future publisher
         (5 seconds pass)
         Here is the result
         Finished

         
         What happens:

         Nothing happens at creation time.
         ➡️ The closure runs only when someone subscribes.
         ➡️ Each subscriber gets a new Future.
         ➡️ So the work starts per subscriber.
         
         Now you can clearly see:
         With Future alone → work starts at creation.
         With Deferred { Future } → work starts at subscription.
         */

    }
}


// 5. Publisher From Collections:
// You can turns an array, ranges and sequences into publishers.
class CollectionPub {
    var cancellable = Set<AnyCancellable>()
    let arrayOne = [1, 2, 3, 4, 5]
    
    func subscribeArray() {
        arrayOne.publisher
            .sink { print("Value: \($0)") }
            .store(in: &cancellable)
    }
}
// MARK: - Difference between defer and any other publisher
/*
 🧩 The core idea

 ✅ All Combine publishers are lazy — they only start producing values when subscribed to.

 So, at first glance, Deferred seems redundant.

 However, the key difference is when the publisher is created.

 ⚖️ Difference between Future and Deferred<Future>
 👉 Future

 A Future runs immediately upon creation, even before any subscriber appears.

 let future = Future<String, Never> { promise in
     print("Future started")
     promise(.success("Hi"))
 }

 print("Before subscribing")
 future.sink { print("Received:", $0) }


 🧩 Output:

 Future started
 Before subscribing
 Received: Hi


 💡 Notice: "Future started" printed before we subscribed!

 That’s because Future executes its closure immediately.

 👉 Deferred(Future)

 Deferred delays creating the Future until someone subscribes.

 let deferred = Deferred {
     Future<String, Never> { promise in
         print("Deferred Future started")
         promise(.success("Hi"))
     }
 }

 print("Before subscribing")
 deferred.sink { print("Received:", $0) }


 🧩 Output:

 Before subscribing
 Deferred Future started
 Received: Hi


 💡 Now, "Deferred Future started" happens only after subscription.
 
 
 
 ✅ Real-world example: API token refresh on demand

 Imagine an app that fetches a secure token from an API. You don’t want to fetch the token when defining the publisher — only when someone subscribes.

 ❌ Without Deferred (problematic)
 let tokenPublisher = URLSession.shared.dataTaskPublisher(for: tokenURL)
     .map(\.data)
     .eraseToAnyPublisher()


 This publisher is created immediately and may reuse stale state or be shared unintentionally.

 ✅ With Deferred (correct behavior)
 func fetchAuthToken() -> AnyPublisher<String, Error> {
     Deferred {
         URLSession.shared.dataTaskPublisher(for: tokenURL)
             .map(\.data)
             .decode(type: TokenResponse.self, decoder: JSONDecoder())
             .map(\.token)
             .eraseToAnyPublisher()
     }
     .eraseToAnyPublisher()
 }

 🔁 What this gives you

 Each subscriber triggers a fresh network request

 No token fetch happens until someone subscribes

 Perfect for authentication, retries, and lazy workflows

 🧠 Another real-world example: Database read
 func loadUserProfile() -> AnyPublisher<User, Error> {
     Deferred {
         Future { promise in
             database.loadUser { result in
                 promise(result)
             }
         }
     }
     .eraseToAnyPublisher()
 }


 Each subscription:

 Opens the DB read

 Fetches fresh data

 Doesn’t reuse old results

 🚫 When NOT to use Deferred

 When you want to share a single result across multiple subscribers → use .share() or .multicast() instead.
 */

/*
 🔹 Step 1: A publisher does nothing until someone subscribes

 This is true for all Combine publishers:

 let publisher = URLSession.shared.dataTaskPublisher(for: tokenURL)


 ➡️ No network call happens yet.
 ➡️ The call happens only when someone does:

 publisher.sink { _ in } receiveValue: { _ in }


 So you were right — it does not run early.

 🔹 Step 2: Then what does Deferred change?

 It changes when the publisher itself is created, not when it runs.

 Think of it like this:

 Without Deferred: you build the request once, then reuse it.

 With Deferred: you build the request each time someone subscribes.

 🔹 Step 3: Concrete example — token that changes

 Imagine this function:

 func buildTokenURL() -> URL {
     print("Building URL")
     return URL(string: "https://api.example.com/token?ts=\(Date().timeIntervalSince1970)")!
 }

 ❌ Without Deferred
 let tokenPublisher = URLSession.shared.dataTaskPublisher(for: buildTokenURL())


 What happens:

 buildTokenURL() runs immediately, right here.

 The URL is fixed forever.

 Even though the request runs later, it always uses that old URL.

 ✅ With Deferred
 let tokenPublisher = Deferred {
     URLSession.shared.dataTaskPublisher(for: buildTokenURL())
 }


 What happens:

 buildTokenURL() runs only when someone subscribes.

 Each subscriber gets a fresh URL.

 🧠 Final mental model
 Without Deferred    With Deferred
 “Create request now, run later”    “Create request when someone subscribes”
 Static    Dynamic
 Good for constants    Good for tokens, timestamps, auth, etc
 🧪 Tiny experiment you can run
 let pub = Deferred {
     print("Creating publisher")
     return Just(1)
 }

 print("Before subscribe")
 pub.sink { _ in }


 Output:

 Before subscribe
 Creating publisher


 Without Deferred, "Creating publisher" would print before "Before subscribe".
 
 
 
 🧠 yes understood. But one thing why we need everytime new instance
 
 🔹 Short answer:

 You need a new publisher instance when the work depends on changing state or must be independent per subscriber.

 🧠 Think of a publisher like a “job description”

 Creating the publisher = writing the job description

 Subscribing = actually doing the job

 If the job description depends on something that changes (token, timestamp, user ID, headers, file path), then:
 ➡️ You want to rewrite the job description each time → new publisher instance.

 🔍 Real-world reasons you need a new instance
 1️⃣ Dynamic data (most common)
 Deferred {
     URLSession.shared.dataTaskPublisher(for: buildRequestWithLatestToken())
 }


 If the token changes, each subscriber must use the latest token. Reusing the same publisher would reuse the old token.

 2️⃣ Independent retries or cancellations

 If two parts of your app subscribe:

 One cancels

 The other should continue unaffected

 That only works cleanly if each gets its own publisher instance.

 3️⃣ Side effects should happen per subscriber

 Example: logging, metrics, file writes, DB reads.

 Deferred {
     print("Starting download")
     return downloadPublisher()
 }


 You want "Starting download" to run per subscriber, not just once.

 🚫 When you don’t need a new instance

 If:

 The data is static

 You want all subscribers to share the same result

 Then you don’t use Deferred. You use:

 publisher.share()

 ✅ Final takeaway

 You need a new publisher instance when:
 ✔ The input changes
 ✔ The side effects must run per subscriber
 ✔ Each subscriber must be independent

 Otherwise, reuse and share.
 */



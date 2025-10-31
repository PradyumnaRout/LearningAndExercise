//
//  CombinePartFour.swift
//  LearningAndExercise
//
//  Created by hb on 28/10/25.
//

import Foundation
import Combine

// MARK:  🔹 Operators in Combine ::
// https://medium.com/@lucaspedrazoli/a-handy-list-of-swift-combine-operators-e7b5d640761c
/*
 
 Operators are the transformers in combine's pipeline. They allow you to modify, filter, combine and handle data as it travels from  Publisehr → Operator(s) → Subscriber.
 
 Operators are methods you apply to the publisher to transform or react to the emitted values.
 
 Think of them like the functions in a data pipelin
 
 ● A map operator can transform values
 ● A filter operator can drop unwanted values.
 ● A debounce operator can control the frequency of events.
 
 👉 Every operators returns a new Publisher, so you can chain them to create powerful pipelines.

 🔹 Categories of Operators
 Operators in Combine can be broadly divided into:
 
 ➡ Transforming Operators → Change the output values
 map, compactMap, replaceNil, scan, flatmap, collect
 
 ➡ Filtering Operators → Control which values are allowed to pass.
 filter, removeDuplicates, dropFirst, prefix
 
 ➡ Combining Operators → Merge a zip multiple publisher.
 merge, combineLatest, zip, switchToLatest
 
 ➡ Time-Based Operators → Handle delays and throttling.
 delay, debounce, throttle, timeout.
 
 ➡ Error-Handling Operators → Handle failures gracefully.
 catch, retry, replaceError
*/

// 🔹 Transforming Operators
/// 🔵 map
/**
 Map functions similarly to Swift’s standard, but with the distinction that it acts on values emitted from a publisher. Additionally, it offers the flexibility to map into one, two, or three properties of a value using key paths.
 */
class OperatorMap {
    
    struct User {
        let name: String
        let lastName: String
        let age: String
        let place: String
    }
    
    var cancellable = Set<AnyCancellable>()
    let number = [1,2,3,4,5].publisher
    let user = User(name: "Jhon", lastName: "Snow", age: "32", place: "GOT")
    let publisher = PassthroughSubject<User, Never>()
    
    
    func operate() {
        let cancellable = number
            .map { $0 * 10 }    // transform Values.
            .sink { print($0) }
    }
    
    func operateCustomObject() {
        publisher
            .map(\.age, \.name, \.lastName)         // Keypaths are the properties under the object. Max Keypath - 3
            .sink { (age, name, lastName) in
                print("name: \(name)")
                print("last name: \(lastName)")
                print("age: \(age)")
            }
            .store(in: &cancellable)
        
        publisher.send(user)
    }
}

/// 🔵 flatMap
/**
 FlatMap operates by flattening the output from all received publishers into a single publisher. It shares a similarity with Swift’s standard behavior, which flattens nested arrays
 */


class OperatorFlatMap {
    
    var cancellable = Set<AnyCancellable>()
    
    func standardBehaviour() {
        let nestedArray = [[1,2,3],[4,5],[6]]
        let flattened = nestedArray.flatMap { $0 }
        let mapped = nestedArray.map { $0 }
        
        print("mapped: \(mapped)") // [[1, 2, 3], [4, 5], [6]]
        print("flattened \(flattened)") // [1, 2, 3, 4, 5, 6]
    }
    
    func intoString(_ input: Int) -> AnyPublisher<String, Never> {
        return Just("Number: \(input)").eraseToAnyPublisher()
    }
    
    // Combine FlatMap can flat nested Publishers.
    func operateFaltMap() {
        let array = [1]
        
        array.publisher
            .map(intoString)
            .sink { publisher in
                print(publisher)    // AnyPublisher
            }
            .store(in: &cancellable)
        
        array.publisher
            .flatMap(intoString)
            .sink { string in
                print(string)   // number: 1
            }
            .store(in: &cancellable)
        
    }
}


/// 🔵 flatMap
/**
 What if some of your transformations might result in nil values? Instead of working with optionals, you can use compactMap to unwrap them safely and filter out the invalid ones.
 */

class OperatorCompactMap {
    var cancellable = Set<AnyCancellable>()
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    
    func operateCompactMap() {
        strings
            .compactMap { value in Float(value) }
            .sink { print($0) }
            .store(in: &cancellable)
    }
}


/// 🔵 Scan
/**
 It is similtar to Swift reduce. Provides a stream with accumulated values. The closure receives two parameters, the last value and the next.
 */

class OperatorScan {
    var cancellable = Set<AnyCancellable>()
    
    func operateScan() {
        ["Hel", "lo", " ", "Wor","ld", "!"]
            .publisher
            .scan("X ->") { latest, current in
                print("Latest: \(latest)")
                print("Current: \(current)")
                return "\(latest) + \(current)"
            }
            .sink { value in
                print("sink \(value)")
            }
            .store(in: &cancellable)
        
        /**
         // See below reduce function for differentiate between scan and reduce operator.
         Output -
                 Latest: X ->
                 Current: Hel
                 Latest: X -> + Hel
                 Current: lo
                 Latest: X -> + Hel + lo
                 Current:
                 Latest: X -> + Hel + lo +
                 Current: Wor
                 Latest: X -> + Hel + lo +   + Wor
                 Current: ld
                 Latest: X -> + Hel + lo +   + Wor + ld
                 Current: !
                 sink X -> + Hel
                 sink X -> + Hel + lo
                 sink X -> + Hel + lo +
                 sink X -> + Hel + lo +   + Wor
                 sink X -> + Hel + lo +   + Wor + ld
                 sink X -> + Hel + lo +   + Wor + ld + !
         */
    }
}


/// 🔵 Scan
// It is used to transform invidual values into an array.

class OperatorCollect {
    var cancellable = Set<AnyCancellable>()
    let publisher = PassthroughSubject<Int, Never>()
    
    func operateCollect() {
        publisher
            .collect()
            .sink(receiveValue: {
                print("all values as array: \($0)")         // After getting all vlaues
            })
            .store(in: &cancellable)
        
        publisher
            .collect(2)
            .sink(receiveValue: {
                print("array elements limited by 2: \($0)")
            }).store(in: &cancellable)
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        publisher.send(completion: .finished)
    }
}

/// 🔵 Replace nil and Replace Empty
// The title speaks for itself. Let’s proceed with the examples.

class OperatorReplaceNil {
    var cancellable = Set<AnyCancellable>()
    
    func operateReplaceNil() {
        ["A", nil, "C"].publisher
            .eraseToAnyPublisher()
            .replaceNil(with: "-")
            .sink(receiveValue: { print($0) }) // A - C
            .store(in: &cancellable)
    }
}


// 🔹 Filtering Operators
// 🔵 Filter
/**
 It is used to limit the values or events emitted by the publisher and only consume some of them.
 
 The filter operator takes a closure that returns a Bool, allowing only values that match the provided conditions to pass through.
 It enables you to control which values emitted by the upstream publisher are send downstream.
 */

class OperatorFilter {
    var cancellable = Set<AnyCancellable>()
    
    func operateFilter() {
        let numers = (1...10).publisher
        
        numers
            .filter { $0.isMultiple(of: 3) }
            .sink(receiveValue: { n in
                print("\(n) is a multiple of 3!")
            })
            .store(in: &cancellable)
    }
}

// 🔵 Remove duplicates
// It automatically works for any values conforming to Equatable, including String. It will not pass down identical values.

class OperatorRemoveDuplicate {
    var cancellable = Set<AnyCancellable>()
    
    func operateRemoveDuplicate() {
        ["a", "a", "b", "b", "c", "d", "e", "e", "e"]
            .publisher
            .removeDuplicates()
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
        
        
        let publisher = ["cat", "Cat", "dog", "dog", "DOG"].publisher
        publisher
            .removeDuplicates(by: { previous, current in
                previous.lowercased() == current.lowercased()
            })
            .sink { print($0) }
            .store(in: &cancellable)
    }
}


// 🔵 Ignoring
// When you don't care about the values themselves, and only want a completion event, ignoreOutput is your friend.

class OperatorIgonreOutput {
    var cancellable = Set<AnyCancellable>()
    
    func operateIgnoreOutput() {
        let numbers = (1...10_000).publisher
        numbers
            .ignoreOutput()
            .sink(receiveCompletion: { print("Completed with: \($0)") },
                  receiveValue: { print($0) })
            .store(in: &cancellable)
    }
}

// 🔵 Finding Values
/**
 Find and emit only the first or the last value matching the provided condition. Is another sort of filtering, where you can find the first or last values to match a provided predicate using first(where:) and last(where:), respectively.
 */

class OperatorFindingValues {
    var cancellable = Set<AnyCancellable>()
    
    func operateFindingFirst() {
        var subscriptions = Set<AnyCancellable>()

        let numbers = (1...9).publisher
        numbers
            .first(where: { $0 % 2 == 0 })
            .sink(receiveCompletion: { print("Completed with: \($0)") },
                  receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    func operateFindingLast() {
        var subscriptions = Set<AnyCancellable>()

        let numbers = (1...9).publisher
        numbers
            .last(where: { $0 % 2 == 0 })
            .sink(receiveCompletion: { print("Completed with: \($0)") },
                  receiveValue: { print($0) })
            .store(in: &subscriptions)
    }
}

// 🔵 Dropping values
/**
 We can use it when you want to ignore values from one publisher until a second one starts publishing, or if you want to ignore a specific amount of values at the start of the stream. It enable us to control how many values emitted by the upstream publisher are ignored before sending values downstream by using the drop family of operators.
 */

class OperatorDrop {
    var cancellable = Set<AnyCancellable>()
    
    // The dropFirst operator takes a count parameter and ignores the first count values emited by the publisher. Only values emitted after count values will be allowed through.
    func operateDropByCount() {
        let numbers = (1...10).publisher
        
        numbers
            .dropFirst(7)
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    // This is another variation that takes a predicate closure and ignores any values emitted by the publisher until the first time that predicate is met. As soon as the predicate is met, values begin to flow with the operator
    func operateDropByCondition() {
        let numbers = (1...10).publisher
        
        numbers
            .drop(while: { $0 % 5 != 0 })
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    // The prefix family of operators is similar to the drop family and provides prefix(_:), prefix(while:). However, instead of dropping values until some condition is met, the prefix operators take values until that condition is met.
    func operatePrefixByCount() {
        let numbers = (1...10).publisher
        
        numbers
            .prefix(2)
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    func operatePrefixByCondition() {
        let numbers = (1...10).publisher
        
        numbers
            .prefix(while: { $0 % 5 != 0 })
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
        
        /**
         Output -
             1
             2
             3
             4
         */
    }
}


// 🔹 Combining Operators
// This set of operators lets you combine events emitted by different publishers and create meaningful combinations of data in you Combine code.

// 🔵 Append & Prepend (Mostly used for collection)
// Allows us to add values that emit before/after any values from your original publisher. (Allows only same type)

class OperatorAppendAndPrepend {
    var cancellable = Set<AnyCancellable>()
    
    func operatePrepend() {
        let publisher = [6, 7, 8].publisher
        
        publisher
            .prepend([4, 5])
            .prepend(Set(1...3))
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
        
        let publisher1 = ["c", "d"].publisher
        let publisher2 = ["a", "b"].publisher
        
        publisher1
            .prepend(publisher2)
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    func operateAppend() {
        let publisher = [1].publisher
        
        publisher
            .append([2, 3])
            .append(4)
            .sink(receiveValue: { print($0) })
            .store(in: &cancellable)
    }
}

// 🔵 Switch To Latest
/**
 This operator is specifically designed for publisher that emit other publisher(Nested publishers), Where the parent publisher acts as a manager for the operations of the child publishers. As the name implies, this operator removes the current publisher operation and switches to the latest one that was emitted.
 */

class OperatorSwitchToLatest {
    var cancellable = Set<AnyCancellable>()
    
    let childPublisher1 = PassthroughSubject<Int, Never>()
    let childPublisher2 = PassthroughSubject<Int, Never>()
    let parentPublisher = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    
    func operateSwitchToLatest() {
        parentPublisher
            .switchToLatest()
            .sink(receiveCompletion: {
                    print("completion: \($0)")
                }, receiveValue: {
                    print("sink: \($0)")
                })
                .store(in: &cancellable)
        
        
        // Sending Values
        parentPublisher.send(childPublisher1)
        childPublisher1.send(1)
        parentPublisher.send(childPublisher2)   // removes the childPublisher1 subscription
        childPublisher1.send(2)                 // Will not be printed as it switched to latest publisher (childPublisher2)
        childPublisher2.send(3)
        childPublisher2.send(4)
    }
}

// 📝 Switching between asynchronous operations, such as a Network Request is a common use case for switchToLatest Operator.
class SwitchToLatestAsyncNetworkClass {
    
    var cancellable = Set<AnyCancellable>()
    
    let parentPublisher1 = PassthroughSubject<AnyPublisher<Int, Never>, Never>()
    let parentPublisher2 = PassthroughSubject<AnyPublisher<Int, Never>, Never>()
    
    // Rquesting Low Number
    func requestLowNumber() -> AnyPublisher<Int, Never> {
        let delay = 1.0
        let publisher = PassthroughSubject<Int, Never>()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let randomResult = Int.random(in: 1...10)
            
            print("Random words : \(randomResult.words.publisher)")
            print("Random description : \(randomResult.description.publisher)")
            
            publisher.send(randomResult)
        }
        return publisher.eraseToAnyPublisher()
    }
    
    // Requesting High Number
    func requestHighNumber() -> AnyPublisher<Int, Never> {
        let delay = 2.0
        let publisher = PassthroughSubject<Int, Never>()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let randomResult = Int.random(in: 1000...10000)
            publisher.send(randomResult)
        }
        return publisher.eraseToAnyPublisher()
    }
    
    func testPublisher() {
        parentPublisher1
            .switchToLatest()
            .sink { value in
                print("parentPublisher1: \(value)")
            }
            .store(in: &cancellable)
        
        parentPublisher2
            .switchToLatest()
            .sink(receiveValue: {
                print("ParentPublisher2: \($0)")
            })
            .store(in: &cancellable)
        
        
        // low and high value will be printed
        parentPublisher1.send(requestLowNumber()) // Needs to wait one second to be printed.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.parentPublisher1.send(self.requestHighNumber())
        }
        
        // Just high number will be printed
        parentPublisher2.send(requestLowNumber())  // will unsubscribe before the print operation finishes
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.parentPublisher2.send(self.requestHighNumber())
        }
    }
    
}

// 🔵 Merge
/**
 The merge operator allows us to simultaneously observe multiple publishers while maintaining the order of execution for each sent value. Thid operator makes it possible to combine different publisher.
 
 
 📝 It merge one publisher with other. Do not wait for all publisher to publish. subscribe immediately.
 📝 All publishers must have the same Output type and the same Failure type.
 */

class OperatorMerge {
    var cancellable = Set<AnyCancellable>()
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    func testMerge() {
        publisher1
            .merge(with: publisher2, publisher3)
//            .merge(with: publisher3)
            .sink(receiveValue: {
                print($0)
            })
            .store(in: &cancellable)
        
        publisher1.send(1)
        publisher2.send(2)
        publisher3.send(3)
        publisher1.send(1)
        publisher2.send(2)
        publisher2.send(2)
        publisher3.send(3)
        /**
         output - 1
         2
         3
         1
         2
         2
         3
         */
    }
    
    func testMergeTwo() {
        let publisherA = [1, 2, 3].publisher
        let publisherB = [10, 20].publisher

        let merged = publisherA.merge(with: publisherB)

        // 👉 The exact interleaving depends on timing.
        merged.sink { value in
            print("Received: \(value)")
        }
        /**
         Output -
                 Received: 1
                 Received: 2
                 Received: 3
                 Received: 10
                 Received: 20
         
         May differ sometimes.
         */
    }
    
    // Real world example :
    /**
     Imagine you have:
     ✅ Network request for new messages
     ✅ Local notifications from a database
     
     You can merge them to update UI from both sources instantly while still preserving each source's internal order.
     */
    
    func realWorldUse() {
        let incomingMessages = PassthroughSubject<String, Never>()
        let localDrafts = PassthroughSubject<String, Never>()

        let mergedPublisher = incomingMessages.merge(with: localDrafts)
        
        mergedPublisher.sink {
            print("UI update: new message -> \($0)")
        }
        .store(in: &cancellable)
        
        incomingMessages.send("Server: Hello")
        localDrafts.send("Draft: Hi")
        incomingMessages.send("Server: How are you?")
        
        /**
         output -
                 UI update: new message -> Server: Hello
                 UI update: new message -> Draft: Hi
                 UI update: new message -> Server: How are you?
         */
    }
}


// 🔵 Combine Latest
/**
 
 📕 Used for combining publisher of different types.
 
 This operator allows us to combine publishers of different value types by emitting tuple with the latest values of all publisher. Every publisher passed to combineLatest, including the origin publisher,
 📕 Must emit at least one value to fire the downstream. Additionally,
 📕 For the first time, it waits for all publishers to emit a value. Once that happens, it emits a new value every time any one of the publishers emits.
 📝 To finish the origin publisher subscription, every publisher passed to combineLatest must complete.
 */

class OperatorCombineLatest {
    
    var cancellable = Set<AnyCancellable>()
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    let publisher3 = PassthroughSubject<URL, Never>()
    let publisher4 = PassthroughSubject<Bool, Never>()
    let publisher5 = PassthroughSubject<Float, Never>()
    
    func testCombineLatest() {
        // Simple CombineLatest
        publisher1
            .combineLatest(publisher2)
            .combineLatest(publisher3)
            .combineLatest(publisher4)
            .combineLatest(publisher5)
            .sink(receiveCompletion: { completion in
                print("completion: \(completion)")
            }, receiveValue: manipulateData(_:))
            .store(in: &cancellable)
        
        // CombineLatest With Transform
        /**
         📕 This is a version of combineLatest that:
         
         Combines the current publisher with one more publisher
         Lets you transform the combined output into a custom output type
         */
        publisher1
            .combineLatest(publisher2)
            .combineLatest(publisher3)
            .combineLatest(publisher4)
            .combineLatest(publisher5) { combinedTuple, floatValue in
                let (((value1, value2), value3), value4) = combinedTuple
                return (value1, value2, value3, value4, floatValue)
            }
            .sink(receiveCompletion: { completion in
                print("Completion: \(completion)")
            }, receiveValue: (manipulateTransferData))
            .store(in: &cancellable)


        
        publisher1.send(1)
        publisher1.send(2)
        publisher2.send("a")
        publisher2.send("b")
        publisher1.send(3)
        publisher2.send("c")
        publisher3.send(URL(string: "www.apple.com")!)
        publisher4.send(true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // it will wait the last publisher emit a value
            self.publisher5.send(10.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            // it will wait the last publisher emit a value
            self.publisher2.send("Hello World")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
            // finish the origin publisher
            self.publisher1.send(completion: .finished)
            self.publisher2.send(completion: .finished)
            self.publisher3.send(completion: .finished)
            self.publisher4.send(completion: .finished)
            self.publisher5.send(completion: .finished)
        }

    }
    
    func testCombineLatestWith2() {
        let stringPublisher = PassthroughSubject<String, Never>()
        let intPublisher = PassthroughSubject<Int, Never>()
        
        stringPublisher
            .combineLatest(intPublisher)
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { value in
                print("String Value: \(value.0)")
                print("Int Value: \(value.1)")
            }
            .store(in: &cancellable)
        
        stringPublisher.send("First String")
        intPublisher.send(100)
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            intPublisher.send(10000)
        }
        
    }
    
    func manipulateData(_ value: ((((intVlaue: Int, stringValue: String), urlValue: URL), boolValue: Bool), floatValue: Float)) {
        print("Int Value: \(value.0.0.0.intVlaue)")
        print("String Value: \(value.0.0.0.stringValue)")
        print("URL Value: \(value.0.0.urlValue)")
        print("Bool Value: \(value.0.boolValue)")
        print("Float Value: \(value.floatValue)")
    }
    
    func manipulateTransferData(_ intVlaue: Int, _ stringValue: String, _ urlValue: URL, _ boolValue: Bool, _ floatValue: Float) {
        print("Int Value: \(intVlaue)")
        print("String Value: \(stringValue)")
        print("URL Value: \(urlValue)")
        print("Bool Value: \(boolValue)")
        print("Float Value: \(floatValue)")
    }
}

// 🔵 Zip
/**
 It waits for each publisher to emit an item, then emits a tuple. If we are zipping two publishers, we will get a single tuple emitted every time both publishers emit a value.
 */

class OperatorZip {
    var subscriptions = Set<AnyCancellable>()

    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    func testZip() {
        publisher1
            .zip(publisher2)
            .sink(receiveCompletion: { _ in
                print("Completed")
            }, receiveValue: {
                print("P1: \($0), P2: \($1)")
            })
            .store(in: &subscriptions)
        
        publisher1.send(1)
        publisher1.send(2)
        publisher2.send("a")
        publisher2.send("b")
        publisher1.send(3)
        publisher2.send("c")
        publisher2.send("d") // it will not be printed
        
        publisher1.send(completion: .finished)
        publisher2.send(completion: .finished)
    }
}


// 🔹 Time Manipulation
//🔵 Delay
// It keeps the emitted value for a while then emits it after the delay you asked for.
class OperatorDelay {
    var subscriptions = Set<AnyCancellable>()
    let sourcePublisher = PassthroughSubject<Bool, Never>()
    
    func testDelay() {
        sourcePublisher
            .delay(for: 5, scheduler: DispatchQueue.main)
            .sink(receiveValue: { value in
                print("received: \(value)")
            })
            .store(in: &subscriptions)
        
        sourcePublisher.send(true)
    }
}


//🔵 Collect byTime or Count
/**
 This operator is employed to gather values emitted by a publisher at specified intervals or based on the number of times values were sent.. It transforms all values in an Array by default.
 */

// Can be used for textfield input.
class OperatorCollectByTime {
    var subscriptions = Set<AnyCancellable>()
    let sourcePublisher = PassthroughSubject<String, Never>()
    
    func testCollectByTimeCount() {
        sourcePublisher
            .collect(.byTimeOrCount(DispatchQueue.main, .seconds(5), 2))        // It will wait for 5 second if it will not get the count.
            .sink { value in
                print("Vlaue: \(value)")
            }
            .store(in: &subscriptions)
        
        sourcePublisher
            .collect(.byTimeOrCount(DispatchQueue.main, .seconds(5), 1))    //will not wait the interval as count is one.
            
            .sink { value in
                print("Vlaue do not wait: \(value)")
            }
            .store(in: &subscriptions)
        
        sourcePublisher.send("Hello")
        sourcePublisher.send("world")
        sourcePublisher.send("Again")
    }
}


//🔵 Debounce
/**
 It waits for one second on emissions from subject. Then, it will send the last value sent in that one-second interval, if any. This has the effect of allowing a max of one value per second.
 
 🧭 What debounce does

 Wait until values stop coming for 1 second.
 Then emit only the "last" value received during that time.
 
 🔄 Timeline of your events
 Time    Event    What debounce does    Output
 0.0s    "a" is sent                        Timer starts (1 sec countdown)    ❌ No output yet
 0.1s    "b"                                Timer resets                      ❌
 0.2s    "c"                                Timer resets                      ❌
 0.3s    "d"                                Timer resets                      ❌
 1.3s    1 second has passed since "d"      Emits "d"                         ✅ d
 1.3s    "e" scheduled later                Timer starts again                ❌
 2.3s    1 sec of silence                   Emits "e"                         ✅ e
 
 */

class OperatorDebounce {
    var subscriptions = Set<AnyCancellable>()
    let sourcePublisher = PassthroughSubject<String, Never>()

    func testDebounce() {
        sourcePublisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { value in
                print("value: \(value)")
            })
            .store(in: &subscriptions)

        sourcePublisher.send("a")
        sourcePublisher.send("b")
        sourcePublisher.send("c")
        sourcePublisher.send("d")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.sourcePublisher.send("e")
        }
        
        /**
         output -
                 value: d
                 value: e
         */
    }
}

//🔵 Throttle
/**
 It is close to debounce. It publishes the most-recent element in the specified time interval. When the subject emits its first value, throttle immediately relays it. Then, it starts throttling the output.
 
 🔐 Key setting:
     latest: false ✅ → emit the first value in each 1-second window
     (Instead of the last like debounce does)
 
 🔄 Timeline Breakdown
     Time    Event                  What throttle does                          Output
     0.0s    "a"                    First event → immediately output            ✅ a
     0.1s    "b"                    Ignore (still inside throttle window)       ❌
     0.2s    "c"                    Ignore                                      ❌
     0.3s    "d"                    Ignore                                      ❌
     1.0s    Throttle window ends   Ready for new events    —
     1.0s    "e" arrives            New window → output immediately             ✅ e
 */
class OperatorThrottle {
    var subscriptions = Set<AnyCancellable>()
    let sourcePublisher = PassthroughSubject<String, Never>()

    func testThrottle() {
        sourcePublisher
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .sink(receiveValue: { value in
                print("value: \(value)")
            })
            .store(in: &subscriptions)
        
        sourcePublisher.send("a")
        sourcePublisher.send("b")
        sourcePublisher.send("c")
        sourcePublisher.send("d")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.sourcePublisher.send("e")
        }
        
        /**
         Output -
                 value: a
                 value: e
         */
    }
}


/**
 ✅ Throttle vs Debounce

 (with real examples & visuals)

 🔹 throttle

 Send at most ONE value every X seconds
 It sends periodically, even if values are still coming.

 📌 Useful when:

 You want regular updates

 You want to limit frequency, not eliminate too much data

 Example:

 User is dragging a slider → send updates no more than once per second

 🔹 debounce

 Wait until input STOPS for X seconds, then send the last value

 📌 Useful when:

 You want to wait for user to finish typing

 Avoid unnecessary operations (like network calls)

 👀 Visual Timeline Example
 Event Stream

 User emits values quickly:

 A    B   C            D
 0.0s 0.2s 0.4s        1.5s

 Using throttle(1 second)
 A ---- 1s ---- C ---- 1s ---- D


 ✅ Emits periodically
 ✅ One per second max
 ✅ It doesn’t wait for silence

 Using debounce(1 second)
 (wait)...C    (wait)...D


 ✅ Emits ONLY after silence of 1s
 ❌ Drops A and B entirely
 ✅ Waits before sending
 */


// 🔵 Timeout
// It forces a publisher completion after a time interval
/**
 🔹 Timeout

 Detects inactivity and fails if values don’t arrive in time.

 ➡️ Think of timeout as “Are you alive?” check.

 📌 Example:

 publisher
     .timeout(.seconds(2), scheduler: RunLoop.main, customError: { .timeoutError })


 If no value comes for 2 seconds →
 ❌ publisher fails with error
 🔚 subscription stops
 
 */

class OperatorTimeout {
    var subscriptions = Set<AnyCancellable>()
    let sourcePublisher = PassthroughSubject<String, Never>()

    func testTimeout() {
        sourcePublisher
            .timeout(.seconds(2), scheduler: DispatchQueue.main, customError: nil)
            .sink(receiveCompletion: {
                print("completion time: \($0)")
            }, receiveValue: {
                print("time sent: \($0)")
            })
            .store(in: &subscriptions)

        sourcePublisher.send("hello")       // If I do not send value for 2 minutes it will finish the subscription with failure.
    }
}


/*
 
 ✅ Timeout vs Delay in Combine
 🔹 Delay

 Waits before delivering values
 It always sends the values — just later.

 ➡️ Think of delay as holding messages temporarily.

 📌 Example:

 publisher
     .delay(for: .seconds(2), scheduler: RunLoop.main)


 If the publisher sends "A" at time 0s → the subscriber receives it at 2s.

 ✅ Values still arrive
 ⌛ Just later than originally emitted
 ❌ Doesn’t cause errors

 🔹 Timeout

 Detects inactivity and fails if values don’t arrive in time.

 ➡️ Think of timeout as “Are you alive?” check.

 📌 Example:

 publisher
     .timeout(.seconds(2), scheduler: RunLoop.main, customError: { .timeoutError })


 If no value comes for 2 seconds →
 ❌ publisher fails with error
 🔚 subscription stops

 👀 Side-by-Side Comparison
 Feature                                  Delay                                               Timeout
 Purpose                            Slow down output                                    Ensure timely output
 If value doesn’t arrive in time    Still succeeds later                                Error + cancels subscription
 When used                          UI animations, spacing events                       Detect stuck network or long waits
 Affects all values?                Yes                                                 Only when too late / not coming
 
 */



// 🔹 Sequence Operators
// These operators operate on the collection of values emitted by a publisher, handling the sequence as a whole rather than individual values.
//🔵 Min/Max
class OperatorMinMax {
    var subscriptions = Set<AnyCancellable>()
    let publisher = [1, -50, 246, 0].publisher

    func testMinMax() {
        publisher
            .min()
            .sink(receiveValue: { print("Lowest value: \($0)") })
                .store(in: &subscriptions)
                
        publisher
            .max()
            .sink(receiveValue: { print("Highest value: \($0)") })
            .store(in: &subscriptions)
    }
}

// 🔵 First/Last
class OperatorFirstLast {
    var subscriptions = Set<AnyCancellable>()
    let publisher = ["A", "B", "C"].publisher

    func testFirstLast() {
        publisher
            .first()
            .sink(receiveValue: { print("First value: \($0)") })
            .store(in: &subscriptions)
            
        publisher
            .last()
            .sink(receiveValue: { print("Last value: \($0)") })
            .store(in: &subscriptions)
    }
}

// 🔵 Output at/in
// Will only let values through if they are emitted by the upstream publisher at the specified indices.

class OperatorOutputAtIn {
    var subscriptions = Set<AnyCancellable>()
    let publisher = ["A", "B", "C", "D", "E"].publisher

    func testOutput() {
        publisher
            .output(at: 1)
            .sink(receiveValue: { print("Value at index 1 is \($0)") })
            .store(in: &subscriptions)

        publisher
            .output(in: 2...4)
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { print("Value in range: \($0)") })
            .store(in: &subscriptions)
    }
}


//🔷 Querying Operators
// They don't produce any specific values that it emits. Instead, these operators emit a different value representing some query on the publisher as a whole
// 🔵 Count
class OperatorCount {
    var subscriptions = Set<AnyCancellable>()
    let publisher = ["A", "B", "C"].publisher

    func testCount() {
        publisher
            .count()
            .sink(receiveValue: { print("I have \($0) items") })
            .store(in: &subscriptions)
    }
}

// 🔵 Contains
class OperatorContains {
    var subscriptions = Set<AnyCancellable>()
    let publisher = ["A", "B", "C", "D", "E"].publisher

    func testContains() {
        publisher
            .contains("C")
            .sink(receiveValue: { contains in
                print("Publisher emitted C? \(contains)")       // Output - Bool value
            })
            .store(in: &subscriptions)

        publisher
            .contains("Z")
            .sink(receiveValue: { contains in
                print("Publisher emitted Z? \(contains)")       // Output - Bool value
            })
            .store(in: &subscriptions)
    }
}


// 🔵 All Satisfy
class OperatorAllSatisfy {
    var subscriptions = Set<AnyCancellable>()
    let publisher = [2, 4, 6, 8, 10, 12].publisher
    
    func testAllSatisfy() {
        publisher
            .allSatisfy { $0 % 2 == 0 }
            .sink(receiveValue: { allEven in
                print(allEven ? "All numbers are even" : "Something is odd...")         // output - Bool value
            })
            .store(in: &subscriptions)
    }
}

// 🔵 Reduce
class OperatorReduce {
    var subscriptions = Set<AnyCancellable>()
    let publisher = ["Hel", "lo", " ", "Wor","ld", "!"].publisher
    
    func testReduce() {publisher
        .reduce("->") { accumulator, value in
            print("accumulator: \(accumulator)")
            return accumulator + value
        }
        .sink(receiveValue: { print("Reduced into: \($0)") })
        .store(in: &subscriptions)
        
        /**
         Output -
                 accumulator: ->
                 accumulator: ->Hel
                 accumulator: ->Hello
                 accumulator: ->Hello
                 accumulator: ->Hello Wor
                 accumulator: ->Hello World
                 Reduced into: ->Hello World!
         */
    }
}

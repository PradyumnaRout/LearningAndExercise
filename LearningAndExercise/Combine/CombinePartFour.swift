//
//  CombinePartFour.swift
//  LearningAndExercise
//
//  Created by hb on 28/10/25.
//

import Foundation
import Combine

// 🔹 Operators in Combine ::
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
        ["a", "b", "c"]
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
        childPublisher1.send(2)     // Will not be printed
        childPublisher2.send(3)
        childPublisher2.send(4)
    }
}

// 📝 Switching between asynchronous operations, such as a Network Request is a common use case for switchToLatest Operator.

//
//  Generics.swift
//  LearningAndExercise
//
//  Created by hb on 26/11/25.
//

// https://www.avanderlee.com/swift/generics-constraints/
// https://medium.com/swift-india/power-of-swift-generics-part-1-ab722a030dc2
// https://medium.com/swift-india/power-of-generics-part2-b39f412a1d54

import Foundation

/**
 ✅✅✅`Generics in swift`✅✅✅
 
 • Generics allow you to write flexible, reusable, and type-safe code without repeating the same logic for different data types.
 
 `1️⃣ What are generics

 • Generics are the way to write functions, type, and data structure that can work with any type.
 • You define your code once and it works for Int, String, Double, or any custom type.
 
 Example:
 var numbers: Array<Int> = [1, 2, 3]
 var names: Array<String> = ["A", "B", "c"]
 
 Here array works for any type because its generic.
 
 `2️⃣ Generics remove duplication:`
 
 Lets write a swap function that works for all types
 
 func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
     let temp = a
     a = b
     b = temp
 }
 
 • T is a placeholder type, meaning "any type"
 • Both parameters must be the same type T, because swappint different types make no sense.
 • Swift replaces T with the acutal type at the compile time.
 
 
`🌟 1. Generic Functions`
 
 • A generic function can work with any data type, not just a specific one.
 • Instead of repeating the same logic for Int, String, Double, etc., One generic function handle all.
 
 Example:
 func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
     let temp = a
     a = b
     b = temp
 }
 
 • Instead of a real type (Int), the generic version uses a type placeholder (T).
 • T means: “Use whatever type is passed, but both must be the same type.”
 • The <T> after the function name tells Swift: T is a placeholder type, not a real type.
 
 
 `🌟 2. Type Parameters`
 
 • They are placeholder type names used in generics.
 • Example: T in <T> is a type parameter.
 
 
 🙋 Where can you use type parameters?

 • Once created, you can use the type parameter:
 • As a parameter type
 • As a return type
 • Inside the function body
 
 func duplicateValue<T>(_ value: T) -> (T, T) {
     return (value, value)
 }
 
 ➡️ T is replaced with:

 • Int when passing an Int
 • String when passing a String
 • Custom type when passing a custom type
 
 
 `Multiple type parameters` You can have more than one:
 
 func makePair<A, B>(_ a: A, _ b: B) -> (A, B) { ... }
 
 
 `🌟 3. Naming Type Parameters`:
 
 • In most cases, type parameters have descriptive names, such as Key and Value in Dictionary<Key, Value> and Element in Array<Element>, which tells the reader about the relationship between the type parameter and the generic type or function it’s used in. However, when there isn’t a meaningful relationship between them, it’s traditional to name them using single letters such as T, U, and V, such as T in the swapTwoValues(_:_:) function above.
 
 
 `🌟 4. Generic Types`:
 
 • Generics are not only for functions - they works for types too
 
 Swift lets you create:
 • Generic classes
 • Generic structures
 • Generic enumerations
 
 
 🔷 Example: Stack (non-generic): Non-generic version (works only with Int):
 
 // Limitation: Work only with Int.
 struct IntStack {
     var items: [Int] = []
     
     mutating func push(_ item: Int) {
         items.append(item)
     }
     
     mutating func pop(_ item: Int) {
         items.removeLast()
     }
 }
 
 
 🔷 Generic Stack: Generic version using <Element>:
 
 // Now Stack works for any type.
 struct Stack<Element> {
     var items: [Element] = []
     
     mutating func push(_ item: Element) {
         items.append(item)
     }
     
     mutating func pop(_ item: Element) {
         items.removeLast()
     }
 }
 
 Example: Stack of Strings
 var stackOfStrings = Stack<String>()
 stackOfStrings.push("uno")
 stackOfStrings.push("dos")
 stackOfStrings.push("tres")
 stackOfStrings.push("cuatro")
 
 */

class GenericsPractice {
    
    func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
        let temp = a
        a = b
        b = temp
    }
}


// Limitation: Work only with Int.
struct IntStack {
    var items: [Int] = []
    
    mutating func push(_ item: Int) {
        items.append(item)
    }
    
    mutating func pop(_ item: Int) {
        items.removeLast()
    }
}


// Now Stack works for any type.
struct Stack<Element> {
    var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop(_ item: Element) {
        items.removeLast()
    }
}


/**
 ✅✅✅ Type Constraints in Generic ✅✅✅
 
 Generic code normally works with any type, but sometimes we need to ensure the type.
 • Inherit form a specific class
 • Or conforms to a protocol (e.g, Hashable, Equatable)
 
 Example: Dictionary key type must be Hashable, because a dictionary needs to know
 • If a key already exists
 • Where to store the key/value pair
 • How to retrive values
 
 To do this efficiently, the key type must be able to compute a unique hash value.
 All basic types like Int, String, Double, Bool are Hashable by default.
 
 You can create your own constraints when creating a generic function or type, you can require
 • The type conforms to a protocol
 • Or inherits from a specific class.
 
 
 🌟 2. Type Constraint Syntax
 func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U) {
    // Body
 }
 
 T must be subclass of SomeClass
 U must be conforms to SomeProtocol
 
 
 🌟 3. Type Constraints in Action
 
 func findIndex<T>(of valueToFind: T, in array: [T]) -> Int? {
     for (index, value) in array.enumerated() {
         if value == valueToFind {
             return index
         }
     }
     return nil
 }
 
 This will fail, because
 • Not every type support ==
 • Swift cannot assume equality exist for every possible T.
 • Your custom class may not have equality defined.
 • Thus the code cannot compile.
 
 
 🌟 4. Fixing it with the Equatable constraint
 • Swift has a protocol called Equatable
 • provides == and !=
 • Required for comparing values
 • To use ==, we must ensure that T is Equatable.
 
 So correct generic version
 func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
     for (index, value) in array.enumerated() {
         if value == valueToFind {
             return index
         }
     }
     return nil
 }
 Now this function works with any Equatable type.
 
 */

// 🌟 3. Type Constraints in Action

func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

// Error without constraint : Binary operator '==' cannot be applied to two 'T' operands


/**
 ✅✅✅ Extensions Can Add Constraints ✅✅✅
 
 • Just like generic functions and types can have constraints, extensions can also specify requirements. You can use constraint in extension to say
 
 ➡️ Only add this feature when the generic type meets a certail condition.
 
 Syntax:
 extension SomeType where T: SomeProtocol {
    // new functionality here
 }
 
 ✅ Here, the extension only applies when the type parameter T conforms to a protocol.
 
 
 // Example
 struct CustomStack<Element> {
     var items = [Element]()
     mutating func push(_ item: Element) { items.append(item) }
     mutating func pop(_ item: Element) { items.removeLast() }
 }

 // Now we add functionality only when element is Equatable:
 extension CustomStack where Element: Equatable {
     func isTop(_ item: Element) -> Bool {
         return items.last == item
     }
 }

 
 ✅ What does this mean?
 • isTop(_:) will only be available if the stack stores Equatable elemets
 • This avoids forcing all stack types to support equality.
 
 
 Usage Example
 Valid: Stack of Strings (String is Equatable)

 var stringStack = Stack<String>()
 stringStack.push("A")
 print(stringStack.isTop("A"))  // true
 
 Why is this useful?
 It allows:

• Adding methods only when logically valid
• Better type safety
• Cleaner code
• No unnecessary restrictions on the generic type
 */

// Example
struct CustomStack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop(_ item: Element) { items.removeLast() }
}

// Now we add functionality only when element is Equatable:
extension CustomStack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        return items.last == item
    }
}

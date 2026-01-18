//
//  ProtocolSwift.swift
//  LearningAndExercise
//
//  Created by hb on 01/12/25.
//

import Foundation


/**
 PROTOCOL :
 
 • A protocol defines a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality.
 • A protocol can be adopted by a class, structure, or enumeration to provide an actual implementation of those requirements.
 

 `🧩 Understanding Property Requirements in Protocols (Swift)
 
 ✅ 1. What a protocol can require
 
 A protocol can tell a conforming type (struct/class/enum) that it must have a property with a certain:

 - name
 - type
 
 protocol P {
     var a: Int { get }
 }
 Here, any type conforming to protocol must have a property a of type Int.

 ✅ 2. Protocol doesn’t care whether the property is:
 • stored property
 • computed property

 As long as it matches the requirement.
 
 var a: Int     // stored
 var a: Int {   // computed
    return 5
 }

 
 ✅ 3. Gettable vs Settable

 A protocol can require:
 • { get } : only reading allowed (read-only)
 • { get set } : reading and writing allowed

 If protocol requires get+set:  var value: Int { get set }
 
 Then this CAN’T be implemented using:
 • let value (constant)
 • read-only computed property

 Because it must support both read and write.
 
 
 Example:
 protocol Test {
     var x: Int { get set }
     var y: Int { get }
 }


 Possible implementation:
 struct Demo: Test {
     var x: Int = 10     // OK (get + set)
     var y: Int {        // OK (get only)
         return 20
     }
 }
 
 
 ❌ Wrong implementation example
 struct Demo: Test {
     let x: Int = 10  // ❌ cannot be let, must set
     var y: Int { return 20 }
 }
 
 `🏷 Type properties must use static in the protocol
 Even if a class later uses class or static.

 Example:

 protocol Example {
     static var count: Int { get set }          // Behaves same as class and struct.
 }
 
 
 `✅ 1. Method Requirements in Protocols

 A protocol can say:
 “Any type that conforms must have these methods.”

 Example:
 protocol RandomNumberGenerator {
     func random() -> Double
 }


 This means:

 • conforming type MUST have a method named random
 • return Double
 • protocol doesn’t care how random is generated

 ✔ Important points:
 ✔ (1) Method is declared without body

 Only signature:
 func random() -> Double


 No implementation.
 ✔ (2) Conforming type must implement it

 Example:

 class Generator: RandomNumberGenerator {
     func random() -> Double {
         return 0.5
     }
 }

 ✔ (3) Type Method Requirement uses static
 When defining in protocol:

 protocol P {
     static func someMethod()
 }


 When class implements:
 • can use static or class

 class Example: P {
     class func someMethod() { }
 }
 
 
 🟢 2. Mutating Method Requirements

 This part is very important and often confusing for beginners.

 ❗Value Types (struct, enum) cannot normally change self inside functions.
 To change, we must write:
 mutating func ...


 Example:

 struct Counter {
     mutating func increment() { ... }
 }

 ✔ Protocol can require a mutating method
 protocol Togglable {
     mutating func toggle()
 }


 Meaning:

 • conforming types must implement a method that changes their state.

 ✔ Struct/Enum MUST add mutating
 enum Switch: Togglable {
     mutating func toggle() { ... }
 }

 ✔ Classes do NOT need mutating
 Because classes are reference types and can always change their properties.

 💡 Example of mutating requirement from text
 enum OnOffSwitch: Togglable {
     case on, off
     mutating func toggle() {
         self = (self == .on ? .off : .on)
     }
 }

Mutating function in class:- 
class Fan: Togglable {
    var isOn = false

    func toggle() {
        isOn.toggle()
    }
}

 
 `🧩 3. Initializer Requirements

 A protocol can require an initializer:
 protocol SomeProtocol {
     init(number: Int)
 }


 Meaning:- Any conforming type must provide this initializer.

 Example:
 struct Test: SomeProtocol {
     init(number: Int) { }
 }

 `⚠ VERY IMPORTANT EXTRA RULE (not covered in text)
 If a class adopts a protocol with an initializer requirement:

 `You must write required keyword.
 Example:

 class MyClass: SomeProtocol {
     required init(number: Int) { }
 }

 Why?
 Because subclasses must also implement it.
 
 
 ✔️ Final mini-example combining everything
 protocol Machine {
     static func startFactory()
     func run()
     mutating func reset()
     init(id: Int)
 }


 Conforming struct:-

 struct Robot: Machine {
     static func startFactory() {}
     func run() {}
     mutating func reset() {}
     init(id: Int) {}
 }


 Conforming class:-

 class Car: Machine {
     class func startFactory() {}
     func run() {}
     func reset() {} // no mutating needed
     required init(id: Int) {}
 }

 
 ✅✅✅`⭐ What is a “Protocol with Only Semantic Requirements”? ✅✅✅

 Some protocols do NOT require:
• no methods
• no properties
• no initializers

 Example:
 protocol P {}

 
 So why do they exist?

• Because these protocols describe: behavior or capability, not code.

 These are called semantic requirements.
 
 
 `🧠 What is a “semantic requirement”?
 It means:

 • The type must behave in a certain way, even though the protocol doesn’t force you to write any code.

 Example from Swift:

 | Protocol        | Meaning                            |
 | --------------- | ---------------------------------- |
 | Sendable        | Can safely cross thread boundaries |
 | Copyable        | Values can be copied               |
 | BitwiseCopyable | Values can be copied bit-by-bit    |


 These protocols do not define any function or variable.

 🧩 Example from the text:
 struct MyStruct: Copyable {
     var counter = 12
 }


 Here:

 Copyable does not require you to write anything
 So the struct conforms without code.

 ✔ Another example:
 extension MyStruct: BitwiseCopyable { }

 Again, no code required.

 🔥 Why does Swift have such protocols?

 Because the requirement is about meaning, not implementation.

 Example difference:
 | Normal protocol         | Semantic protocol            |
 | ----------------------- | ---------------------------- |
 | must implement methods  | must behave in a certain way |
 | compiler checks methods | compiler checks type rules   |


 Semantic protocol checks happen at compile time.
 
 
 ✅✅✅ `Adding Protocol Conformance with an Extension  ✅✅✅
 
 • You can extend an existing type to adopt and conform to a new protocol, even if you don’t have access to the source code for the existing type.
 • Extensions can add new properties, methods, and subscripts to an existing type, and are therefore able to add any requirements that a protocol may demand.
 
 Because you can adopt a protocol:

 • without modifying the original source code
 • even if you don’t own the type
 
 Example :
 protocol TextRepresentable {
    var textualDescriptoin: String { get }
 }
 
 Originally Dice class doesn't conform to the protocol. so we extend it later.
 extension Dice: TextRepresentable {
    var textualDescription: String {
        return "A \(sides)-sided dice"
    }
 }
 
 Now all Dice object gain this ability:
 
 let d12 = Dice(...)
 print(d12.textualDescription)
 
 🔥 Key benefit:

 • Change happens to the type, not the instance.
 • Existing instances magically conform automatically.
 
 
 `🧠 First: what does “existing instance” mean?

 Suppose you have already created an object:
 let d12 = Dice(sides: 12, generator: ...)


 At this moment in the program, Dice does not yet conform to a protocol. The instance exists already.

 🟡 Now you add an extension that makes the type conform:
 extension Dice: TextRepresentable {
     var textualDescription: String {
         "A \(sides)-sided dice"
     }
 }


 You didn't touch d12.
 You didn’t recreate it.

 But now:
 print(d12.textualDescription)   works immediately!

 🎯 Why?
 • Because the conformance is attached to the TYPE, not the INSTANCE.
 • Swift treats protocol conformance as a capability of the whole type:
 • Dice conforms to TextRepresentable Not A new Dice instance conforms

 ⚡ So the magic is:

` When a type starts conforming to a protocol,
` all its existing and future objects gain that protocol's behavior instantly.

 🧩 Example showing this in action:
 Step 1: create instance first
 let dog = Dog(name: "Bolt")

 Step 2: add protocol later
 extension Dog: TextRepresentable {
     var textualDescription: String { "Dog \(name)" }
 }

 Step 3: instance works even though it was created earlier
 print(dog.textualDescription)


 You don’t need to write:
 dog = Dog(...)  // ❌ not required

 ✔ Real-world analogy

 Imagine you have a bunch of employees already working.
 Then the company gives them a new rule / policy.

 You don’t need to hire them again.

 They automatically obey the policy because
 they belong to the company.
 
 
 
 `✨ IMPORTANT FACT

 No matter where you declare protocol conformance:

 in the type declaration

 struct A: P { }

 or

 in an extension

 extension A: P { }

 • The result is always the same:
 • Protocol conformance attaches to the TYPE, not the instance.
 • So the rule does not change.

 🧠 Why?

` • Because protocol conformance is a type-level capability.
  • It is never stored inside an individual object.

 ✔ Example 1: Conforming in declaration
 struct Dog: TextRepresentable {
     var name: String
     var textualDescription: String { "Dog named \(name)" }
 }

 let d1 = Dog(name: "Bolt")
 print(d1.textualDescription)

 ✔ Example 2: Conforming in extension
 struct Dog {
     var name: String
 }

 extension Dog: TextRepresentable {
     var textualDescription: String { "Dog named \(name)" }
 }

 let d2 = Dog(name: "Bolt")
 print(d2.textualDescription)


 • Both behave exactly the same.
 • There is NO difference for instance behavior.
 
 🧩 So what changes?

 • Only where you write the code. Not the meaning.

 Whether you put conformance:

 Option A: With the type: struct Dog: TextRepresentable { ... }

 Option B: In an extension: extension Dog: TextRepresentable { ... }

 Swift applies it at the type level.
 💡 Very important clarification:
 ❌ Protocol conformance is never attached to an instance.

 Instances don’t store:
 • conformance
 • methods
 • properties

 They only store data.

 All behavior is determined by the type.

 ✔ So what happens if instances already exist?

 Example:

 let cat = Cat()  // created before extension


 Then later:

 extension Cat: P { ... }


 You do NOT need to recreate cat.

 The conformance is applied to Cat type,
 so cat automatically gains it.
 
 
 
 
 ⚠️ One special rule (important!)

 If you adopt a protocol and you need stored properties, you CANNOT add stored properties in an extension. Because store property require memory instance and extension can not do that.

 Example ❌ (not allowed):

 extension Dog: P {
     var age: Int   // ❌ stored property not allowed here
 }


 Extensions can only add:

 • computed properties ✔
 • methods ✔
 • subscripts ✔
 So if property requirement is “stored property like behavior,” you must still write it as computed property if implementing in extension.
 
 
 `✔ If you implement protocol conformance IN THE TYPE (declaration)

 You can freely use a stored property OR computed property to satisfy the requirement.

 Example:
 protocol P {
     var name: String { get }
 }


 You implement it inside the type:
 struct Person: P {
     var name: String   // stored property allowed
 }

• This works ✔ because inside the type declaration, you are allowed to make stored properties.

 `✔ If you implement protocol conformance IN AN EXTENSION
 
 Swift does NOT allow you to add stored properties to extensions.

 So you must use a computed property:
 extension Person: P {
     var name: String { return "John" } // computed property
 }
 
 
 `❓ Why does Swift restrict stored properties in extensions?

 Because stored properties require:

 • memory layout change
 • instance storage change
 
 And Swift doesn’t want extensions to change the type’s memory layout.

 Example of invalid code:
 struct Cat { }

 extension Cat {
     var age: Int // ❌ Not allowed
 }
 
 
 
 ✅✅✅ PART 2: Conditionally Conforming to a Protocol  ✅✅✅

 • Sometimes a generic type should only conform to a protocol in specific situations.

 Example:
 Array should only conform when its elements do.

 So Swift allows conditional conformance:

 extension Array: TextRepresentable
     where Element: TextRepresentable
 {
     var textualDescription: String {
         let items = self.map { $0.textualDescription }
         return "[" + items.joined(separator: ", ") + "]"
     }
 }


 Now this works:

 let myDice = [d6, d12]
 print(myDice.textualDescription)

 Important rule:

 • The conformance only works if the element also conforms.
 
 
 
 
 ✅✅✅⭐ Collections of Protocol Types  ✅✅✅

 You can store protocol types in collections like:

 let things: [TextRepresentable] = [game, d12, simonTheHamster]


 This means the array stores values whose type is the protocol, not the original class/struct.

 Even though they come from different types:

 • SnakesAndLadders
 • Dice
 • Hamster

 they all conform to: TextRepresentable

 ✔️ Why does this work?

 Because the protocol guarantees:
 var textualDescription: String { get }

 So Swift knows every element in this array has that property.

 Example of iteration:
 for thing in things {
     print(thing.textualDescription)
 }


 It prints the property for each item.

 ⚠️ Important Concept:
 Inside the loop: thing is NOT Dice or Hamster. Its type is only: TextRepresentable

 So you can only access the protocol’s properties. This is protocol as a type.
 
 
 ✅✅✅ Protocol Inheritance ✅✅✅

 A protocol can inherit from other protocols:

 protocol PrettyTextRepresentable: TextRepresentable


 This means:

 PrettyTextRepresentable requires: textualDescription (from TextRepresentable) plus its own requirements

 var prettyTextualDescription: String { get }

 Example implementation:
 extension SnakesAndLadders: PrettyTextRepresentable {
     var prettyTextualDescription: String {
         ...
     }
 }

 So anything conforming to PrettyTextRepresentable automatically conforms to TextRepresentable.
 
 
 Important Example:
 
 protocol One {
     var firstProperty: String { get }
 }

 protocol Two: One {
     var secondProperty: String { get }
 }
 
 
 so protocol Two now means:
  protocol Two {
     var firstProperty: String { get }  // inherited
     var secondProperty: String { get } // own
 }
 
 
 ✅✅✅ Class-Only Protocols ✅✅✅

 To restrict conformance only to classes:
 
 protocol SomeClassOnly: AnyObject { }


 Now structs and enums CANNOT conform.

 Why?

 Because some behaviors require reference semantics only found in classes.

 Example:

 • weak references
 • shared state
 
 
 ✅✅✅ Protocol Composition ✅✅✅

 • Sometimes you want the type to conform to multiple protocols.
 • Instead of making a new protocol, you combine:

 Named & Aged

 Used like this:

 func wishHappyBirthday(to celebrator: Named & Aged)


 So function only accepts values that conform to both:

 • Named
 • Aged

 Doesn’t matter if it's a class or struct, as long as it satisfies both protocols.
 
 
 ✅✅✅ Protocol Extensions (IMPORTANT!) ✅✅✅
 
 • Protocol extensions allow you to add methods/properties to protocol itself.
 
 Example:

 extension RandomNumberGenerator {
     func randomBool() -> Bool {
         return random() > 0.5
     }
 }


 Now EVERY conforming type gets randomBool() for free:

 generator.randomBool()
 
 
 ❓`Why protocol extensions are powerful? ❓

 Because we can write behavior once, not in every type.

 Without protocol extensions:

 struct A: P { // must write same code here }
 struct B: P { // must write same code again }


 With extension:

 extension P {
     func helperMethod() { }
 }


 All P conforming types now get helperMethod()
 
 📌 VERY IMPORTANT:

Protocol extensions CAN:
• add default method implementations
• add computed properties
• add helper functions

Protocol extensions CANNOT:
• add stored properties
• change protocol inheritance
 
 
 ✔ Simple example that shows everything
 protocol Foo {
     func sayHello()
 }

 extension Foo {
     func sayHello() {
         print("Hello from extension!")
     }
 }

 struct Person: Foo { }

 let p = Person()
 p.sayHello()
 // prints: Hello from extension!


 ➡️ Person didn’t implement sayHello(), but still works because extension provided implementation.

 ✅✅ Example of protocol Extension - 
protocol Flyable {
    func fly()  // Requirement
}

extension Flyable {
    func fly() {      // Default Implementation.
        print("Flying...")
    }
}

Question : Here can I wtire fly() in both requirement and extension

You can declare fly() in the protocol and provide its default implementation in the protocol extension.

What does that menas : - 
- Any type that conforms to Flyable automatically gets this fly() behavior.
- A conforming type may override it with its own implementation.

Example override:
struct Bird: Flyable {
    func fly() {
        print("Bird flying 🐦")
    }
}


Default Use - 
struct Plane: Flyable { }  // uses default fly()

So yes — you write it in both places:
Protocol → declares what must exist
Extension → defines how it works by default

✅ So it is not mandatory for a class (or struct) to redeclare the method if the protocol provides a default implementation in an extension.
And by using this you can make your protocol method optional like objective c, Because now you do not need to add the declare the mentod
in the conforming type. But you can if you want, so in other word you can say it otpional method.

 ✅✅✅ First: What does “dispatch” mean? ✅✅✅

 Dispatch = how Swift decides which function to call at runtime.

 There are 2 types:

 ✔ Static Dispatch (compile-time dispatch)

 Swift decides which function to call at compile time.
 • It is Fast, no dynamic checks.

 ✔ Dynamic Dispatch (runtime dispatch)
 
 • Swift waits until runtime to decide which implementation to call.
 Used by:
 
 • method overriding in classes
 • protocol requirements

 ⭐ RULE #1
 If a method comes from a protocol requirement, Swift uses DYNAMIC dispatch.

 Example:

 protocol P {
     func doSomething()
 }

 extension P {
     func helper() { }
 }


 If a conforming type implements doSomething(), calling through protocol type uses dynamic dispatch.

 ⭐ RULE #2
 If a method is ONLY in a protocol extension and NOT a requirement…

 Swift uses STATIC dispatch.

 Example:

 protocol P { }

 extension P {
     func foo() {
         print("protocol extension")
     }
 }


 Calling foo() is static dispatch
 
 */


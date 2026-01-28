//
//  TypeErasureAndOpaqueType.swift
//  LearningAndExercise
//
//  Created by hb on 17/12/25.
//

import Foundation
import SwiftUI

// MARK: here’s a clean, real example of using any with a protocol 👇

/*
 🔹 Define a protocol
 protocol Animal {
     func makeSound()
 }

 🔹 Use any Protocol
 var pet: any Animal

 pet = Dog()
 pet.makeSound()

 pet = Cat()
 pet.makeSound()

 🔹 Concrete types
 struct Dog: Animal {
     func makeSound() {
         print("Woof")
     }
 }

 struct Cat: Animal {
     func makeSound() {
         print("Meow")
     }
 }


 Here:

 var pet: any Animal

 means:

 “pet can hold any concrete type that conforms to Animal,
 but I don’t know which one at compile time.”

 That is an existential type.

 Compare with generics (important difference)
 Using generics:
 func play<T: Animal>(with animal: T) {
     animal.makeSound()
 }


 This means:

 “One specific type chosen at compile time.”

 Using any Animal:
 func play(with animal: any Animal) {
     animal.makeSound()
 }


 This means:

 “Type erased to Animal, dynamic dispatch.”

 Another example with properties
 protocol Vehicle {
     var wheels: Int { get }
 }

 struct Bike: Vehicle {
     let wheels = 2
 }

 struct Car: Vehicle {
     let wheels = 4
 }

 class Garage {
     var vehicle: any Vehicle

     init(vehicle: any Vehicle) {
         self.vehicle = vehicle
     }
 }


 Usage:

 let g1 = Garage(vehicle: Bike())
 let g2 = Garage(vehicle: Car())
 print(g1.vehicle.wheels)
 print(g2.vehicle.wheels)

 Why Swift introduced any

 Before Swift 5.7, you wrote:

 var pet: Animal


 But that hid the fact that this was an existential.

 Now Swift forces clarity:

 var pet: any Animal


 So you know:

 “I am losing the concrete type here.”

 Key rule

 any can ONLY be used with:
 ✔️ protocols
 ❌ structs
 ❌ classes
 ❌ enums

 So this is invalid:

 var x: any String ❌


 But this is valid:

 var x: any CustomStringConvertible = "Hello"
 */


/*
 🧠 Give me an example how should I explain the intervier about the type erasure and opaque type in swift

 Perfect interview question — this is exactly the kind of thing interviewers love because it shows concept + communication skill.

 Here’s a ready-to-say interview-style answer with examples.

 🗣️ How to explain Opaque Types (some)

 “In Swift, an opaque type using some Protocol means I return a specific concrete type that conforms to a protocol, but I hide the actual type from the caller.
 The compiler still knows the concrete type, so it keeps full type safety and performance.”

 Example:
 protocol Shape {
     func draw()
 }

 struct Circle: Shape {
     func draw() { print("Circle") }
 }

 func makeShape() -> some Shape {
     return Circle()
 }


 What I’d say:

 “Here, makeShape always returns a Circle, but the caller only sees it as some Shape.
 The important part is: it must always return the same concrete type.
 This allows abstraction without losing static type checking.”

 🗣️ How to explain Type Erasure (any / AnyX)

 “Type erasure is used when I want to store or pass different concrete types that conform to the same protocol, but I don’t care about their concrete type anymore.
 I erase the type information and work with a common interface.”

 Example:
 protocol Animal {
     func sound()
 }

 struct Dog: Animal {
     func sound() { print("Woof") }
 }

 struct Cat: Animal {
     func sound() { print("Meow") }
 }

 let animals: [any Animal] = [Dog(), Cat()]

 for a in animals {
     a.sound()
 }


 What I’d say:

 “Here, any Animal erases whether the object is a Dog or Cat.
 We only know it conforms to Animal.
 This allows heterogenous collections but loses concrete type information and may use dynamic dispatch.”

 🧠 Best interview contrast (this is gold)

 You can say:

 “Opaque types (some) hide the type from the caller but the compiler still knows it.
 Type erasure (any or AnyX) hides the type even from the compiler.
 So some keeps compile-time type safety, while any uses runtime polymorphism.”

 One-liner definitions (interview-friendly)

 Opaque type (some)

 “I know the concrete type, but I don’t expose it.”

 Type erasure (any)

 “I don’t know or care about the concrete type anymore.”
 
 =========================================================
 
 
 Nice, this is a great thing to prep — here’s a polished 2-minute interview answer you can almost say verbatim:

 “In Swift, opaque types and type erasure both help us abstract over concrete types, but they solve slightly different problems.

 Opaque types use the keyword some. When I return some Protocol, it means the function returns one specific concrete type that conforms to that protocol, but the caller doesn’t know which type it is. The important point is that the compiler does know the concrete type, so we still get compile-time type safety and good performance.

 For example:

 protocol Shape {
     func draw()
 }

 struct Circle: Shape {
     func draw() { print("Circle") }

 func makeShape() -> some Shape {
     Circle()
 }


 Here, makeShape always returns a Circle, but the caller only sees it as some Shape. This allows the API to hide implementation details while keeping static typing. SwiftUI uses this pattern heavily, for example var body: some View, so the framework can change the underlying view types without breaking user code.

 Type erasure, on the other hand, is used when I want to work with values of different concrete types that conform to the same protocol, but I don’t want to expose or depend on their concrete types anymore. In Swift 5.7+, this is written as any Protocol, which creates an existential type.

 For example:

 protocol Animal {
     func sound()
 }

 struct Dog: Animal {
     func sound() { print("Woof") }
 }

 struct Cat: Animal {
     func sound() { print("Meow") }
 }

 let animals: [any Animal] = [Dog(), Cat()]


 Here, any Animal erases whether the value is a Dog or Cat. We only know it conforms to Animal, which lets us store different concrete types in the same collection. The tradeoff is that we lose compile-time knowledge of the concrete type and rely on dynamic dispatch at runtime.

 So the key difference is that opaque types hide the type from the caller but not from the compiler, while type erasure hides the type even from the compiler. I use some when I always return the same concrete type and want maximum type safety and performance, and I use any or a type-erased wrapper when I truly need to handle multiple different conforming types dynamically.”
 */

// Example of opaque type and type erasure in SwiftUI

struct OpaqueTypeAndTypeErasure: View {
    @State private var isTrue: Bool = true
    var body: some View {
        VStack {
            customViewOne
        }
    }
    
    
    var customViewOne: some View {
        if isTrue {
            VStack {
                Text("Hello")
                Text("World")
            }
        } else {
            VStack {
                Text("Hello")
                Text("World")
//                Text("OpaqueType")
                // Uncommenting the third text will give error because compiler knows the return type. So it must be of same type.
                // “I must return one single concrete type.”
            }
        }
    }
        
    var customView2: AnyView {
        // “I don’t care what the concrete view type is anymore, just treat it as a View.”
            if isTrue {
                return AnyView(
                    VStack {
                        Text("Hello")
                        Text("World")
                    }
                )
            } else {
                return AnyView(
                    VStack {
                        Text("Hello")
                        Text("World")
                        Text("OpaqueType")
                    }
                )
            }
        }
}
/*
 
 🧠 So  both are type erasure?
 
 
 Yes — you’re absolutely right 👍
 Both any and AnyView are forms of type erasure.
 They just operate at different layers of Swift.

 Think of it like this:

 Type erasure = “hide the concrete type.”
 Both of them do that.
 The difference is where and how they do it.

 1️⃣ any = language-level type erasure (for protocols)
 var animal: any Animal = Dog()


 What gets erased?

 Dog  →  any Animal


 You lose:
 ✔️ knowledge that it’s a Dog
 You keep:
 ✔️ only what Animal guarantees

 So:

 any erases the concrete type into a protocol existential.

 2️⃣ AnyView = framework-level type erasure (for SwiftUI views)
 let v = AnyView(Text("Hello"))


 What gets erased?

 Text  →  AnyView


 You lose:
 ✔️ the real view type (Text, VStack, etc.)
 You keep:
 ✔️ just “this is a View”

 So:

 AnyView erases a concrete View into a boxed wrapper.
 */






// MARK: CUSTOM TYPE ERASURE AND OPAQUE TYPE
// ✅✅✅ Type Erasure ✅✅✅
/**
 
➡️ Type erasaure hides a concrete type from the compiler and the caller by wrapping it in a non-genericc type.
➡️ But in case of associated type we wrap it using generic type.
 
 ⭐️ You use it when
 ➡️ You want to store different concrete type that conform to the same protocol.
 ➡️ The protocol may have associated type or Self requirement.
 ➡️ You  need heterogeneous collection
 
 */


protocol ProtoTypeOne {
    func foo1()
}

var array: [ProtoTypeOne] = []

protocol ProtoTypeWithAssociated {
    associatedtype Output
    func draw()
}

//var arrObj: [ProtoTypeWithAssociated] = []  // Error: Protocol with associated type


protocol ShapeCustom {
    associatedtype Output
    func draw() -> Output
}

struct CircleCustom: ShapeCustom {
    func draw() -> String {
        "Circle"
    }
}

struct SquareCustom: ShapeCustom {
    func draw() -> String {
        "Square"
    }
}




// MARK: Type-erased wrapper example

struct AnyShapeCustom<Output>: ShapeCustom {
    private let _draw: () -> Output
    
    init<S: ShapeCustom>(_ shape: S) where S.Output == Output {
        _draw = shape.draw
    }
    
    func draw() -> Output {
        _draw()
    }
}

class ExampleExecution {
    func foo1() {
        let shapes: [any ShapeCustom] = [
            CircleCustom(),
            SquareCustom()
        ]

        let shape: any ShapeCustom = CircleCustom()
        let resutl: String = shape.draw() as? String ?? ""
        
        print("\(resutl)")
        
        // If you won't cast the shape.draw() it will show error like -  Cannot convert value of type 'Any' to specified type 'String', Because the output type is not mentioned here. And result1 is not a string here.
        // So you can call the method but you cannot do anything menaingfull with the returned value unless you bind the associated type. Now type erasure comes into picture.

    }
    
    func foo2() {
        let customShapes: [AnyShapeCustom<String>] = [
            AnyShapeCustom(CircleCustom()),
            AnyShapeCustom(SquareCustom())
        ]
        
        let value: String = customShapes.first?.draw() ?? ""
        print(customShapes.first?.draw() ?? "")
        
        // Here no error will occure as the type is known.
        // Here caller does not know the concrete type.
        
    }
    
    func foo3() {
        let printers: [AnyPrinter<String>] = [
            AnyPrinter(StringPrinter()),     // You explicitly choose Output = String
            //AnyPrinter(IntPrinter()) // ❌ ERROR because IntPrinter.Output == Int and  String != Int
        ]
    }
}

//MARK:  Example 2:

// Protocol with associated type.
protocol Printer {
    associatedtype Output
    func printValue() -> Output
}

// Two Concret Types

struct StringPrinter: Printer {
    func printValue() -> String {
        "Hello"
    }
    //StringPrinter.Output == String
}

struct IntPrinter: Printer {
    func printValue() -> Int {
        45
    }
    //IntPrinter.Output == Int
}

// Why we need type erasure
//let printers: [Printer] = []
// Because the above line is illegal, but we can use [any Printer] here, but again we have to casting the type while using the results and if the some casting will be wrong then it will crash.

// MARK: Type-erasure
struct AnyPrinter<Output>: Printer {
    private let _printValue: () -> Output
    
    init<P: Printer>(_ printer: P) where P.Output == Output {
        _printValue = printer.printValue
    }
    // This means “You can wrap any Printer, as long as its Output is the same as this AnyPrinter’s Output.”
    
    func printValue() -> Output {
        _printValue()
    }
}





//MARK:  Some Questions
/**
 So if we don not create type erasure here, then we have to specify the  associated type in each conforming type. right?
 
 Ans :
 👉 Yes — implicitly or explicitly, every conforming type must choose an associated type.
 
 • Associated type means “Every conforming type must decide what Output is.”
 
 ➡️ implicitly :
 struct CircleCustom: ShapeCustom {
     func draw() -> String { "Circle" }
 }
 
 Here, Swift infers: CircleCustom.Output == String
 
 ➡️ explicitly:
 struct CircleCustom: ShapeCustom {
     typealias Output = String
     func draw() -> String { "Circle" }
 }


 And Second question is after implementing type erasure, the type is now open to compiler because compiler now know the type. If compiler does not know then tell me how compiler does not know the type now. Because if the compiler knows the type now, then the definition of type erasure is not satisfied.
 
 Ans:
 What type erasure actually erases:
 
 • Type erasure erases this: CircleCustom / SquareCustom
 • It does NOT erase:  Output == String
 
 ➡️ Step-by-step with type erasure
 
 1. Concrete type (before erasure)
 
 let circle = CircleCustom()
 
 Compilter Knows:
 • concrete Type: CircleCustom
 • Associated Type: String
 
 2. Wrap it
 let shape = AnyShape<String>(circle)
 
 Now:
 • ❌ CircleCustom is gone
 • ✅ AnyShape<String> is the only visible type
 
 3. What the compiler knows now
 •  shape.draw() -> String
 
 The compiler does not know:

 • whether it was a CircleCustom
 • whether it was a SquareCustom
 • what other methods existed
 
 This information is erased.
 */


// MARK: Non-generic type erasure

/**
 Question:
 Type erasure hides a concrete type from the compiler and the caller by wrapping it in a non-generic type. But struct AnyShape<Output>: Shape {} is a generic.
 
 Ans -
 Type erasure does NOT erase all types.
 It erases the conforming type, not the associated type.
 
 Non-generic type erasure:
 
 */

protocol Drawable {
    func draw()
}

struct AnyDrawable: Drawable {
    private let _draw: () -> ()
    
    init<D: Drawable>(_ d: D) {
        _draw = d.draw
    }
    
    func draw() {
        _draw()
    }
}


// MARK: Opaque Type:
 
/**
 Opaque types hides the concrete type form the caller, but compiler still knows it.
 
 Use it when:
 • You want to hide the implement detail
 • You want static dispatch and performance
 • You return one specific type that conforms to a protocol
 
 protocol Shape {
     func draw() -> String
 }

 struct Circle: Shape {
     func draw() -> String { "Circle" }
 }

 func makeShape() -> some Shape {
     Circle()
 }
 
 The caller:
 
 let shape = makeShape()
 // shape is "some Shape", but compiler knows it's Circle
 
 func makeShape(_ flag: Bool) -> some Shape {
     if flag {
         return Circle()
     } else {
         return Square() // ❌ Not allowed
     }
 }
 Opaque types must return exactly one concrete type.
 
 
 
 | Feature                      | Opaque (`some`) | Type erasure (`Any…`) |
 | ---------------------------- | --------------- | --------------------- |
 | Compiler knows concrete type | ✅               | ❌                     |
 | Caller knows concrete type   | ❌               | ❌                     |
 | Dispatch                     | Static          | Dynamic               |
 | Performance                  | Fast            | Slower                |
 | Heterogeneous values         | ❌               | ✅                     |
 | Boilerplate                  | Low             | High                  |

 */

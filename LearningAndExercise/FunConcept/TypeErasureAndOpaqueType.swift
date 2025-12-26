//
//  TypeErasureAndOpaqueType.swift
//  LearningAndExercise
//
//  Created by hb on 17/12/25.
//

import Foundation
import SwiftUI
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

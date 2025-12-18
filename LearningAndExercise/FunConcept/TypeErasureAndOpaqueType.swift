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


protocol Shape1 {
    associatedtype Output
    func draw() -> Output
}

struct Circle1: Shape1 {
    func draw() -> String {
        "Circle"
    }
}

struct Square1: Shape1 {
    func draw() -> String {
        "Circle"
    }
}

let shapes: [any Shape1] = [
    Circle1(),
    Square1()
]

let shape: any Shape1 = Circle1()
let resutl = shape.draw()

//print(resutl)

//
//  EquatableComparableAndHashable.swift
//  LearningAndExercise
//
//  Created by hb on 18/02/26.
//

import Foundation
import SwiftUI

// Equatable
// In case of struct, to check the two objects are similar, it needs to conform Equatable protocol. In struct it default includes == method like designated init in struct. So you do not need to add the == method yourself. But yes if you want to equate on a specific key, then you must need to add the == method.
struct EquatableStruct: Equatable {
    var name: String
    var marks: Double
    
    // Add Only if you want to equate based on particular key
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}


// Like struct in class also, to check the two objects are similar, it needs to conform Equatable. But the only different is unlike struct class needs to add the == method compulsory for equating two object.
// Another difference is in case of class you need to write class name instead of Self
class EquatableClass: Equatable {
    var name: String
    var marks: Double
    
    init(name: String, marks: Double) {
        self.name = name
        self.marks = marks
    }
    
    static func == (lhs: EquatableClass, rhs: EquatableClass) -> Bool {
        return lhs.name == rhs.name && lhs.marks == rhs.marks
    }
}


// Comparable Protocol
// For comparing the object with operators like >, <, >=, <=, it needs to conform comparable protocol.
// Unlike Equatable protocol in struct, in case of comparable it needs to add one of the method, from the four methods >, <, >=, <=
struct ComparableStruct: Comparable {
    var name: String
    var marks: Double
    

    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.marks < rhs.marks
    }
}


// In case of class even if you comform to comparable it will ask you to conform equatable, because Comparable conform Equatable by default. And as we discuss above that,when a class conforms to Equatable it needs to add the == method. So here also we need to add the == method
class ComparableClass: Comparable {
    var name: String
    var marks: Double
    
    init(name: String, marks: Double) {
        self.name = name
        self.marks = marks
    }

    static func < (lhs: ComparableClass, rhs: ComparableClass) -> Bool {
        return lhs.marks < rhs.marks
    }
    
    static func == (lhs: ComparableClass, rhs: ComparableClass) -> Bool {
        return lhs.name == rhs.name && lhs.marks == rhs.marks
    }
}


// Hashable
// Hashable gives intiger value to each object. If the two object are same then the has value will be same. But one thing is every time you run, you get new hash value.
// Another points to remember in case of hash is, if you want to create a set, or dictionary of a custom object, You need to conform the custom object to Hashable, because set and dictionary depend on hash value. Without hash value they will throw eror.
struct HashableStruct: Hashable {
    var name: String
    var marks: Double
    
    // It can be evalute on specific key
    func hash(into hasher: inout Hasher) {
        // Here if only marks are same, they will get same hash value.
        hasher.combine(marks)
    }
}



class Execution {
    func equatableExecution() {
        // Equatble in Struct
//        let obj1 = EquatableStruct(name: "pradyumna", marks: 90)
//        let obj2 = EquatableStruct(name: "pradyumna", marks: 100)
//        
//        if obj1 == obj2 {
//            print("Both are identical!")
//        } else {
//            print("Not same")
//        }
        
        // Equatable in Class
//        let obj1 = EquatableClass(name: "pradyumna", marks: 90)
//        let obj2 = EquatableClass(name: "pradyumna", marks: 100)
//        
//        if obj1 == obj2 {
//            print("Both are identical!")
//        } else {
//            print("Not are not same")
//        }
        
        // Comparable in struct
//        let obj1 = ComparableStruct(name: "pradyumna", marks: 90)
//        let obj2 = ComparableStruct(name: "pradyumna", marks: 100)
//        
//        if obj1 > obj2 {
//            print("Obj1 is greater than obj2")
//        } else {
//            print("Nooooooo!")
//        }
        
        // Comparable in Class
//        let obj1 = ComparableClass(name: "pradyumna", marks: 90)
//        let obj2 = ComparableClass(name: "Kanha", marks: 100)
//        
//        if obj1 > obj2 {
//            print("Obj1 is greater than obj2")
//        } else {
//            print("Nooooooo!")
//        }
        
        // Hashable
        let obj1 = HashableStruct(name: "pradyumna", marks: 90)
        let obj2 = HashableStruct(name: "hello", marks: 90)
        
        print(obj1.hashValue)
        print(obj2.hashValue)
    }
}

struct ExecutionView: View {
    var exeObj = Execution()
    
    var body: some View {
        Text("Hello World")
            .onAppear {
                exeObj.equatableExecution()
            }
    }
}

#Preview {
    ExecutionView()
}

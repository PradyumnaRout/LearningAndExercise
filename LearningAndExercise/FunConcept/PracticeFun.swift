//
//  PracticeFun.swift
//  LearningAndExercise
//
//  Created by Rahul Kiumar on 24/01/26.
//

import SwiftUI

struct PracticeFun: View {
    @State var obj = ClassVsStruct()
    
    var body: some View {
        Button {
            obj.executeARC()
        } label: {
            Text("Update")
        }
        .buttonStyle(.bordered)

    }
}

#Preview {
    PracticeFun()
}

// MARK: - Any and AnyObject in Swift

/*
Any - Any can represents an instance of any type at all,
including function type and optional type

AnyObject - AnyObject can represents an instance of any
class type. Not to value type.

So we can say Any is a supreset which includes AnyObject
also.

 //var name: any
 name = "Pradyumns"      // print - Pradyumna
 name = 1                // will print 1
 // Because any can be any type.


 // But let's declare a variable of type AnyObject
 var country: AnyObject
 // country = "India"
 // It will throw error becasue any
 // object must be an instance of class type


 // Let's create a class
 class Employee {
     var name: String?
 }
 var emp: AnyObject
 emp = Employee()

 name = Employee()

 Here we can also assign the class type to the name
 variable which is of type any. So then why we need
 AnyObject then.

 Before any apple has lunched AnyObject in swift3,
 but it only supports for class type, but as swift
 is more value type language, so apple introduced
 any in swift3

*/




// MARK: CLASS VS STRUCT
// MARK: Differences
/*
 1. Classes are reference type while Structs are value type
 2. Class has deinit while Sturct do not.
 3. Struct has default designated initializer while Class don't have any.
 4. Class supports inheritance but Sturct do not. But we can apply inheritance in struct using protocol.
 5. Struct is faster than Class because Structs are stored in stack memory while Classes in heap.
     This sounds nice… but Swift is way smarter than that.

     🚫 Reality:

     Swift does NOT guarantee:
     structs → stack
     classes → heap
     Instead, Swift uses ARC + compiler optimizations and decides:
     “Where should I store this to be fastest & safest?”
 
    So struct do not have ARC and Class have. And sometimes they both are faster than other, depending upon usages.
 */
// Let's undestand with the below example
class ClassVsStruct {
    func executeStruct() {
        // Value types only copy values not address
        var employee1 = EmployeeStruct(name: "Hello")       // address - 123, Name = "Hello"
        
        let employee2 = employee1                           // address of employee2 - 999, Name = "Hello"
        employee1.name = "Pradyumna"                        // changed the name of employee1 to "Pradyumna"
        
        print("Employee1 Name: \(employee1.name)")
        print("Employee2 Name: \(employee2.name)")
        
        /*
         Output -
         Employee1 Name: Pradyumna
         Employee2 Name: Hello
         */
        
        
        // Reference type copy reference and value both
        let employee3 = EmployeeClass(name: "Hello")       // address - 123, Name = "Hello"
        
        let employee4 = employee3                           // address of employee4 - 123, Name = "Hello"
        employee3.name = "Pradyumna"                        // changed the name of employee3 to "Pradyumna" and also the name of employee4 will also chnaged to Pradyumna
        
        print("Employee3 Name: \(employee3.name)")
        print("Employee4 Name: \(employee4.name)")
        
        /*
         Output -
         Employee3 Name: Pradyumna
         Employee4 Name: Pradyumna
         */
    }
    
    func executeARC() {
        var parent: Parent? = Parent()               // Parent - 1, Child - 0
        var child: Child? = Child(parent: parent!)   // Parent - 2, Child - 1
        parent?.child = child!                       // Parent - 2, Child - 2
        
        
        // with this
//        parent?.child = nil                 // Parent - 2, Child - 1
//        parent = nil                        // Parent - 1, Child - 1
//        child = nil                         // Parent - 0, Child - 0 and in the next step parent will also be zero by ARC.
        
        
        // without parent?.child = nil
        parent = nil                        // Parent - 1, Child - 1
        child = nil                         // Parent - 1, Child - 1        to make deinit call make one of the property to weak.
        
        /*
         In case of weak child property inside parent
         var parent: Parent? = Parent()               // Parent - 1, Child - 0
         var child: Child? = Child(parent: parent!)   // Parent - 2, Child - 1
         parent?.child = child!                       // Parent - 2, Child - 1
         
         parent = nil                        // Parent - 1, Child - 1
         child = nil                         // Parent - 0, Child - 0, as child is weak property of parent
         */
        
    }
    
    
}

struct EmployeeStruct {
    // Stuct has default designated initializer while class does not have any default designated initializer.
    // In case of struct compiler creates a default initializer.
    var name: String
}

class EmployeeClass {
    var name: String
    
    // Class do not have any default designated initializer. So we have to create init ourselfs.
    init(name: String) {
        self.name = name
    }
    
    deinit {
        // Class supports deinit, but struct do not.
    }
}


// MARK: ARC IN CLASS AND STRUCT
class Parent {
    weak var child: Child?
    init() {}
    
    deinit {
        print("Parent class get deinit")
    }
}

class Child {
    var parent: Parent?
    init(parent: Parent) {
        self.parent = parent
    }
    
    deinit {
        print("Child class get deinit")
    }
}


// MARK: Struct containing variable of another struct and vice versa:
/*
 struct Parent {
     var child: Child
 }

 struct Child {
     var parent: Parent
 }

 
 The above will cause  error because
 struct is a value type.
 That means Swift must know its exact size in memory at compile time.
 
 Now look at the layout:

 Parent contains → Child
 Child contains → Parent
 Parent contains → Child
 Child contains → Parent
 … 🔁 infinite loop

 So Swift asks: How big is Parent?
 */









// MARK: Wrapped value and Wrapper itself difference:
struct WrappedValueDifference: View {
    @State var currentValue: String
    
    init(currentValue: String) {
        _currentValue = State(initialValue: currentValue)
        
        /*
         var currentValue: String          // the wrappedValue
         This assigns to the wrapped value (wrappedValue).
         
         It's like - self._currentValue.wrappedValue = currentValue
         
         
         
         
         var _currentValue: State<String>  // the wrapper itself
         This assigns to the property wrapper itself.
         Swift rewrite it as - _currentValue = State(initialValue: currentValue)

         
         | Line                               | What it sets          | Meaning                |
         | ---------------------------------- | --------------------- | ---------------------- |
         | `self.currentValue = currentValue` | `wrappedValue`        | Mutating the state     |
         | `_currentValue = currentValue`     | the wrapper (`State`) | Initializing the state |

         
         Think of it like:
         currentValue → the value
         _currentValue → the box that holds the value
         
         🧠 Correct way to init
         @State var currentValue: String

         init(currentValue: String) {
             _currentValue = State(initialValue: currentValue)
         }
         
         self.currentValue = currentValue // ❌ not correct for @State in init

         */
    }

    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

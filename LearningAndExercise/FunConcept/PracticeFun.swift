//
//  PracticeFun.swift
//  LearningAndExercise
//
//  Created by Rahul Kiumar on 24/01/26.
//

import SwiftUI

struct PracticeFun: View {
    var obj = DispatchQueueOutput()
    
    var body: some View {
        Button {
            obj.execution3()
        } label: {
            Text("Update")
        }
        .buttonStyle(.bordered)

    }
}

#Preview {
    PracticeFun()
}


// MARK: DispatachQueue Output Questions
class DispatchQueueOutput {
    func execution1() {
        // Main Thread is a serial queue
        // You will see, if you run this it will get crash. As the main thread is serial so here we are blocking the main thread and it will create a deadlock like situation.
        DispatchQueue.main.sync {
            print("Step 1")
        }
//        print("Step 2")
    }
    
    func execution2() {
        print("Step 1")
        
        DispatchQueue.main.async {
            print("Step 2")
        }
        
        print("Step 3")
        
        /*
         Output -
         Step 1
         Step 3
         Step 2
         
         Because the step2 will not block the current thread.
         */
    }
    
    func execution3() {
        for i in 0...5 {
            print("Step: \(i)")
        }
        
        DispatchQueue.main.async {
            for i in 6...10 {
                print("Step: \(i)")
            }
        }
        
        for i in 11...15 {
            print("Step: \(i)")
        }
        
        /*
         Output -
         Step: 0
         Step: 1
         Step: 2
         Step: 3
         Step: 4
         Step: 5
         Step: 11
         Step: 12
         Step: 13
         Step: 14
         Step: 15
         Step: 6
         Step: 7
         Step: 8
         Step: 9
         Step: 10
         */
    }
    
    func execution4() {
        DispatchQueue.main.async {
            DispatchQueue.main.sync {       // I will block the main thread
                print("Step 1")
            }
            
            print("Step 2")         // I am waiting for the main thread to be free
        }
        
        // SO it will crash.
    }
    
    func execution5() {
        print("Step 0")
        
        DispatchQueue.main.async {
            DispatchQueue.global().sync {
                print("Step 3")
            }
            print("Step 4")
        }
        print("Step 5")
        
        // Output - 0 -- 5 -- 3 -- 4
    }
}









// MARK: == VS ===  (Equality VS Identity) Operator.
/*
 ==  -> Equality    -- Equality operator checks for values
 === -> Identity    -- Identity operator only checks for reference. It compares the address. So it will only work for                   Reference Type.
 
 
 
 
 */

class EqualityVSIdentity {
    let x = 5
    let y = 5
    
    func experiment() {
        //MARK: Execution: 1
        if x == y {
            print("Yes")
        }
        
        //MARK: Execution: 2
        /*
        if x === y {
            print("Identity")
        }
         Error - Argument type 'Int' expected to be an instance of a class or class-constrained type
         The error shows that the identity operator will only works for Class Type / Reference Type.
         */
        
        //MARK: Execution: 3 - Let use a struct type to cross verify it
        /*
        let emp1 = EmployeeStruct(name: "iOS")
        let emp2 = EmployeeStruct(name: "Android")
        
        if emp1 === emp2 {
            print("Identity")
        }
         Error - Argument type 'EmployeeStruct' expected to be an instance of a class or class-constrained type
         This will also give the same error as executino: 2 as struct is also a value type.
         
         */
        
        //MARK: Execution: 4  Equality operator on struct
        let person1 = ComparePerson(name: "iOS", country: "India")
        let person2 = ComparePerson(name: "iOS", country: "China")
        
        if person1 == person2 {
            print("Both are same!")
        }
        
        // Error - Binary operator '==' cannot be applied to two 'ComparePerson' operands
        // Here in sturct also equality opertor will show error, because it does not know what to compare,
        // Which property it needs to compare.
        // In this case we need to conform the struct to Equatable protocol to make the struct comparable
        // Internally the Equatable protocol creates method to compare to struct object.
        // We can also create custom equatable function like we need to compare two struct object based on some specific property.
        
        
        //MARK: Execution: 5
        let classPerson1 = ComparePersonClass(name: "iOS", country: "India")
        let classPerson2 = ComparePersonClass(name: "iOS", country: "India")
        
        // Without conforming to Equatable protocol, we can not compare, because equatable operator does not know what to compare.
        if classPerson1 == classPerson2 {
            print("They are same.")
        }
        
        
        //MARK: Execution: 5 -- Identity operator in class.
        var personID1 = ComparePersonClass(name: "iOS", country: "India")
        var personID2 = ComparePersonClass(name: "iOS", country: "India")
        
        // Compare personID1 and personID2
        // This will go for the else block because the address of personID1 and personID2 are different.
        // Because they are two different objects
        if personID1 === personID2 {
            print("personID1 & personID2 Are Same")
        } else {
            print("personID1 & personID2 Are Not Same")
        }
        
        
        // Now lets assing the personID1 to a variable and compare them
        // Here it will print "personID1 & personID3 Are Same" because in case of class/reference type when we copy object, actually we copy the reference of the object.
        var personID3 = personID1
        if personID1 == personID3 {
            print("personID1 & personID3 Are Same")
        } else {
            print("personID1 & personID3 Are Same")
        }
        
        
        //MARK: Execution: 6
        var personObj1 = ComparePersonClass(name: "iOS", country: "India")
        var personObj2 = personObj1
        // Lets print the address of personObj1 and personObj1 and it will print the same value as you know.
        print("personObj1 address: \(Unmanaged.passUnretained(personObj1).toOpaque())")
        print("personObj2 address: \(Unmanaged.passUnretained(personObj2).toOpaque())")
        
        
        // Now change the country of personObj2
        personObj2.country = "United Kingdom"
        print("\n*******************")
        print("value of personObj1: \(personObj1.name) and \(personObj1.country)")
        print("personObj1 address: \(Unmanaged.passUnretained(personObj1).toOpaque())")
        print("personObj2 address: \(Unmanaged.passUnretained(personObj2).toOpaque())")
        // You can see in console the country of personObj1 will also change, as the address is same. The two object is also just two pointer referencing the same address. And the value is available in the address.
        // And the output will be "personObj1 & personObj2 are same"
        
        
        // Now lets change the country of personObj1
        personObj1.country = "United States"
        print("\n*******************")
        print("value of personObj2: \(personObj2.name) and \(personObj2.country)")
        print("personObj1 address: \(Unmanaged.passUnretained(personObj1).toOpaque())")
        print("personObj2 address: \(Unmanaged.passUnretained(personObj2).toOpaque())")
        // In this case also the address will be same and the values also.
        
        
        // Now assign a new object to personObj1 and check
        personObj1 = ComparePersonClass(name: "React", country: "China")
        print("\n*******************")
        print("personObj1 address: \(Unmanaged.passUnretained(personObj1).toOpaque())")
        print("personObj2 address: \(Unmanaged.passUnretained(personObj2).toOpaque())")
        // Now here you will see the address will be different and the else block will execute in identity operator.
        // Because now we are not chnaging the value in that object, but we are assigning a new object to personObj1
        // which will have a new memeory address.

        
        
        if personObj1 === personObj2 {
            print("personObj1 & personObj2 are same")
        } else {
            print("personObj1 & personObj2 are not same")
        }
        
    }
}

struct ComparePerson: Equatable{
    var name: String
    var country: String
    
    // Here equality will happen only based on name property.
    static func ==(lhs: ComparePerson, rhs: ComparePerson) -> Bool {
        return lhs.name == rhs.name
    }
}


class ComparePersonClass: Equatable {
    var name: String
    var country: String
    
    init(name: String, country: String) {
        self.name = name
        self.country = country
    }
    
    
    // In case of class if you confrom to Equatable protocol, it is mandatory to implement the == method otherwise it will give error
    // Error - Type 'ComparePersonClass' does not conform to protocol 'Equatable'
    static func ==(lhs: ComparePersonClass, rhs: ComparePersonClass) -> Bool {
        return lhs.name == rhs.name && lhs.country == rhs.country
    }
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

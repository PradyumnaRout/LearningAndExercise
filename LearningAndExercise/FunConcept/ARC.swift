//
//  ARC.swift
//  LearningAndExercise
//
//  Created by hb on 23/12/25.
//

import Foundation
// MARK: ✅✅✅ ARC ✅✅✅
/**
 
 ➡️ What is ARC?
 
 • Automatic Reference Counting
 • Object deallocated when reference count reaches zero.
 • Compile-time ARC Insertion and Runtime ARC Execution
 • ARC in swift doesn't manages memory at compile time. It is runtime memory management, with compile-time analysis used to insert      ARC code.
 
 ➡️ How ARC in Swift actually works?
 
 1️⃣ Compile-time: ARC Insertion:
 At compile time, the Swift compiler:
 • Analyses object lifetimes using static analysis.
 • Automatically insert
    • retain
    • release
 These calls are not executed yet - they're just placed into the generated code.
 
 2️⃣ Runtime: ARC Execution:
 At runtime:
 • Each object has a reference count
 • retain increments the count.
 • release decrements the count.
 • When the count reaches to zero, the object is deallocated immediately.
 • This happens when the program runs.
 
 ➡️ Why people get confused?
 • ARC is often described as "Compile-time" because,
 • You never manually write retain/release
 • The compiler decides where to put them.
 • There is no runtime garbage collection cycle.
 
 But the decisions are made at compile time, while the effects happen at runtime.
 
 ✅ Swift ARC performs static analysis at compile time to insert retain/relase calls, but actual memory management happens at runtime via reference counting.
 
 🔹🔹🔹
 
 ➡️ Why ARC can cause retain cycles?
 
 What ARC guarentees
 ARC only does one thing:
 
 🛠️ 🛠️
 `• Deallocate an object when its reference count becomes zero.
 `• ARC does not understand ownership intent, relationship, or object graph.
 `• Where will be the retain / release happen is managed by the compiler at compile time.
 
 ➡️ What a retain cycle is?
 A retain cycle happens when two or more objects strongly reference each other, so none of them ever reach a reference count of zero.
 
 Example:

 class A {
    var b: B?       // strong reference by default
 }
 
 class B {
    var a: A?       // strong reference by default
 }
 
 let a = A()
 // RC(A) = 1
 // Reason: 'a' is a strong reference to the A instance
 
 
 let b = B()
 // RC(B) = 1
 // Reason: 'b' is a strong reference to the B instance
 
 
 a.b = b
 // RC(B) = 2
 // Reason:
 // 1) 'b' variable → B
 // 2) 'a.b' property → B (strong by default)
 
 
 b.a = a
 // RC(A) = 2
 // Reason:
 // 1) 'a' variable → A
 // 2) 'b.a' property → A (strong by default)
 
 ➡️ What happens when scope ends?
 // 'a' variable goes out of scope
 // RC(A) = 1   (still retained by B.a)

 // 'b' variable goes out of scope
 // RC(B) = 1   (still retained by A.b)
 
 
 
 Reference Graph:
 A ──strong──▶ B
 ▲            │
 └──strong────┘
 
 Even if a and b go out of scope:
 • A keeps B alive
 • B keeps A alive
 • Reference count never hits zero -> No Deallocation
 
 ARC can't break this automatically, because
 • Both reference are valid.
 • Removing either one could break program logic.
 
 👉 That's why Swift requires weak or unowned reference.
 
 ✅ Correct fix:
 
 class A {
     var b: B?          // A OWNS B
 }

 class B {
     weak var a: A?     // B does NOT own A
 }
 
 let a = A()      // RC(A) = 1
 let b = B()      // RC(B) = 1

 a.b = b          // RC(B) = 2  (a → b)
 b.a = a          // RC(A) stays 1 (weak does NOT increase RC)
 
 ➡️ When scope ends:
 // 'a' released → RC(A) = 0 → deinit A
 // 'b' released → RC(B) = 1
 // A releases B → RC(B) = 0 →  → deinit B
 
 
` ➡️ Classic real-world retail cycle cases
 • Closure capturing self
 • Delegate marked Strong
 • Parent <-> Child object graph
 • ViewController <-> ViewModel Reference
 
 Example:
 class MyClass {
    var closure: (()->(Void))?
 
    func setup() {
        closure = {
         // RC(closure) = 1
         // Reason: 'closure' property strongly retains the closure object
 
            self.doSomething()
             // RC(MyClass) = 2
             // Reason:
             // 1) 'obj' variable → MyClass
             // 2) closure CAPTURES 'self' strongly by default
        }
        // closure now strongly retains 'self'
    }
 }
 
 let obj = MyClass()
 // RC(MyClass) = 1
 // Reason: 'obj' variable holds a strong reference
 
 • When obj goes out of scope
 // 'obj' variable goes out of scope
 // RC(MyClass) = 1   (still retained by closure)
 
 Here:
 • Self -> owns Closure
 • closure -> strongly captures self.
 • This create reatain cycle.
 
 ✅ How breaking the cycle changes the counts?
 ➡️ Using weak self in the closure
 
 closure = { [weak self] in
     self?.doSomething()
 }
 // closure captures 'self' weakly
 // RC(MyClass) does NOT increase
 
 ➡️ Final counts when obj goes out of scope:
 // RC(MyClass) = 0 → deinit called
 // RC(closure) = 0 → deallocated
 
 ✅✅ Reference count increases whenever a new strong reference is created.
 
 
 🔹🔹🔹
 
 
 `➡️ ARC is automatic — but who actually inserts retain and release calls?
 
 • During the compilation, the Swift compiler perofrms static lifetime analysis and automatically insert retain and release.
 • You never see these in Swift source code, but they are present in the generated machine code.
 • ARC itself is not a runtime system, it's compile time feature implemented by the compiler.
 
 ➡️ What happens after insertion?

 Once inserted, these calls are:

 • Compiled down to runtime functions
 • Executed at runtime
 • Used to increment/decrement reference counts
 
 | Phase            | Responsibility                                   |
 | ---------------- | ------------------------------------------------ |
 | **Compile time** | Swift compiler decides *where* to retain/release |
 | **Runtime**      | Reference counting actually happens              |
 | **ARC**          | The *strategy*, not a runtime engine             |

 
 Why ARC feels “automatic”

 • You never write retain / release
 • The compiler inserts them deterministically
 • Deallocation happens immediately at RC = 0
 
 🔹🔹🔹
 
 `➡️ Where is the reference count stored?
 
 Short Answer:
 • The reference count is stored in the object's heap metadata, not in the variable and not in the reference itself.
 • Every class instance in Swift has a small runtime-managed header in memory that includes the reference count.
 
 ➡️ Where exactly is it stored?
 
 When you create a class instance, Swift allocates memory on the heap that looks conceptually like this:
 ┌──────────────────────────┐
 │ Heap Object Header       │
 │ ──────────────────────  │
 │ • Reference count        │ ◀── stored here
 │ • Type metadata pointer │
 │ • Runtime flags         │
 ├──────────────────────────┤
 │ Stored properties       │
 │ (your class fields)     │
 └──────────────────────────┘

 🔑 Key point
 • The reference count lives inside the heap object.
 • All references(a, b, properites, closures) points to the same object.
 • They all increment/decrement the same counter.
 
 ➡️ What is not storing the reference?
 
 ❌ The variable
 
 let a = MyClass()      // 'a' is just a pointer which stores address only. Variables just store addresses, not counts.
 
 ❌ The reference itself
 ❌ The stack frame
 ❌ The compiler symbol.
 
 Stack vs Heap (important distinction)
 | Type     | Stored where   | Reference counting |
 | -------- | -------------- | ------------------ |
 | `class`  | Heap           | ✅ Yes              |
 | `struct` | Stack / inline | ❌ No               |
 | `enum`   | Stack / inline | ❌ No               |

 
 `➡️ Is the reference count part of the Swift object itself, or part of some external structure managed by the runtime?
 
 • Swift stores strong and unowned reference counts inside the object’s heap header, while weak references are managed via an external side table created and maintained by the runtime.
 
 Object Header
    │
    ├── strong RC
    ├── unowned RC
    └── weak table pointer ───▶ Weak Side Table
                                • weak ref #1
                                • weak ref #2
 
 🔹🔹🔹
 
 
` ➡️ What happens when you assign a strong reference inside a function? Walk me through it step by step.”
 
 
 class MyClass {
     deinit {
         print("deinit")
     }
 }

 func foo() {
     let a = MyClass()
     let b = a
 }

 
Step 0: Before function is called
 • No MyClass instace exists
 • Reference count = 0 (Conceptually object is not allocated yet)
 
 Step 1: foo() is called
 • A stack frame is created for foo
 • Space is reserved for local variable a and b
 • These variables will hold pointers, not objects
 
 Stack (foo)
 ┌───────────┐
 │ a : ptr   │
 │ b : ptr   │
 └───────────┘

 Step 2: let a = MyClass()
 What the compiler-generated code does
 1. Allocate heap memory for MyClass
 2. Initialize object header
    • Strong RC = 1
 3. Stores pointer to the object in a
 
 Heap
 ┌────────────────────┐
 │ MyClass instance   │
 │ RC = 1 ◀────────┐ │
 └────────────────────┘
                     │
 Stack (foo)          │
 ┌───────────┐        │
 │ a ────────┼────────┘
 │ b         │
 └───────────┘
 ✔️ Reference count increased to 1

 Step 3: let b = a
 1. Copy pointer value from a to b
 2. Call Swift_retain on the object
 3. Increment strong RC from 1 -> 2
 
 Heap
 ┌────────────────────┐
 │ MyClass instance   │
 │ RC = 2 ◀───────┐  │
 └────────────────────┘
                   │
 Stack (foo)        │
 ┌───────────┐      │
 │ a ────────┼──────┘
 │ b ────────┼──────┐
 └───────────┘      │
                    └── both point to same object

 ✔️ Reference count increased to 2
 
 Step 4: End of function scope
 When foo() returns, the compiler generated code does
 
 4.1 Release b
 • swift_release(object)
 • RC: 2 -> 1
 
 4.2 Release a
 • swift_release(object)
 • RC: 1 -> 0
 
 Step 5: Deinitilaization and deallocation
 Whne RC hits zero:
 1. deinit is called
 2. Stored properties are released.
 3. Weak reference are zeroed.
 4. Heap memory is free.

 🔹🔹🔹
 
 
 `1️⃣ What is an autoreleasepool?

 An autoreleasepool is a scope that temporarily holds objects that are marked for delayed release, and then releases all of them at once when the scope ends.

 In Swift:
 autoreleasepool {
     // objects created here
 }
 // autoreleased objects are released here

 
 2️⃣ Why does this exist if ARC is automatic?

 Because ARC is automatic, but not everything is released immediately.
 ARC has two release strategies:

 • Immediate release → normal ARC behavior
 • Deferred release → via autorelease pools
 • autoreleasepool exists to manage deferred releases.
 
 🔹🔹🔹
 
 `➡️ If ARC is compile-time, why do memory leaks still happen at runtime?
 
 Ans - `Memory leaks still happens at runtime because ARC only insert retain and release calls at compile time, while the actual object graph and reference relationship are formed dynamically at runtime, and ARC can not infer or break logical ownership cycle.
 
 1️⃣ First, clear the misconception

 ARC being compile-time does not mean:

 • The compiler knows your runtime object graph
 • The compiler can predict all execution paths
 • The compiler can break reference cycles safely

 What compile-time ARC actually means is:

•  The compiler inserts retain/release instructions, but the program’s behavior still depends on runtime object relationships.

 2️⃣ What the compiler knows vs what it doesn’t
 ✅ What the compiler knows

 • Where variables go in and out of scope
 • Where references are assigned
 • Which references are strong, weak, or unowned
 • Local lifetimes in straight-line code

 ❌ What the compiler cannot know

 • Runtime control flow (loops, async, callbacks)
 • Object graphs formed dynamically
 • Ownership intent
 • Whether two objects should own each other
 • How long a closure or singleton will live
 
 3️⃣ Why leaks are a runtime phenomenon

 🔹 A memory leak under ARC is not: “Memory was forgotten”
 🔹 It is: Memory is still correctly retained at runtime.

 ARC is doing its job perfectly — the reference count never reaches zero.
 
 
 4️⃣ Concrete retain-cycle example
 class A {
     var b: B?
 }

 class B {
     var a: A?
 }

 let a = A()
 let b = B()
 a.b = b
 b.a = a

 What the compiler inserts
 retain(a)
 retain(b)
 retain(b)  // a.b
 retain(a)  // b.a


 At runtime:
     • A RC = 2
     • B RC = 2

 When scope ends:
    • Only local references are released
    • Cycle remains → RC never reaches zero=
 ➡️ Deterministic leak

 5️⃣ Why the compiler can’t “fix” this

 • Because both references are valid:
 • Removing either retain could cause:
        • Dangling pointer
        • Use-after-free
        • Crash

 The compiler cannot guess intent:

 • Is A the owner?
 • Is B the owner?
 • Are they peers?

 So Swift requires explicit ownership annotations (weak, unowned).
 
 6️⃣ Another runtime-only leak source: closures
 class MyClass {
     var closure: (() -> Void)?
     func setup() {
         closure = {
             self.doSomething()
         }
     }
 }


 • Closure lifetime depends on runtime execution
 • Compiler cannot know how long closure will live
 • Strong capture of self is valid
 ➡️ Leak appears only if closure outlives self
 
 
 🔹🔹🔹
 
 
 `➡️ If you were designing ARC from scratch, what tradeoffs do you think Apple made?
 
 Tradeoff #1: Determinism vs Automation
 Choice Apple made

 ✅ Deterministic reference counting

 What they gained
 • Immediate deinit
 • Predictable resource cleanup
 • Smooth UI (no stop-the-world GC)
 • Easy mental model for system programming

 What they gave up
 ❌ Automatic cycle detection
 ❌ “Fire-and-forget” memory safety

 Apple chose predictability over convenience.
 
 
 Tradeoff #2: Compile-time ARC vs Runtime GC
 Choice Apple made

 ✅ Compiler-inserted retain/release

 What they gained

 • Zero runtime graph scanning
 • No background threads
 • ARC calls can be optimized away
 • Very low overhead
 
 What they gave up

 ❌ Runtime awareness of object graphs
 ❌ Ability to fix leaks automatically

 ARC knows where references change, not what your program means.
 
 • Use weak → when the reference can disappear (nil) logically.
 • Use unowned → when the reference is mandatory and will always exist as long as this object exists.
 */




// MARK: https://medium.com/@anjali09july1999/arc-in-swift-everything-you-need-to-know-for-interviews-eda4fe2bd213

class PersonClass {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Deinitialized")
    }
}

func execute() {
    var person1: PersonClass? = PersonClass(name: "Anjali")   // retain count = 1
    var person2 = person1                       // retain count = 2

    person1 = nil       // retain count = 1
    person2 = nil       // retain count = 0
}


class A {
    var b: B?
}

class B {
    var a: A?
}

func execute2() {
    var a = A()     // strong reference, RAC of A = 1
    var b = B()     // strong reference, RAC of B = 1
    
    a.b = b         // strong reference, RAC of B = 2
    b.a = a         // strong reference, RAC of A = 2
}



class Customer {
    let name: String
    var card: CreditCard?
    
    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer

    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }

    deinit {
        print("Card #\(number) is being deinitialized")
    }
}

func executeCard() {
    var john: Customer? = Customer(name: "John")
    john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)

    john = nil
}
// Prints: "John is being deinitialized" and then "Card #1234567890123456 is being deinitialized"

// MARK: UNOWNED
/**
 🚨 Crash Scenario 1: Another strong owner keeps the card alive
 var leakedCard: CreditCard?

 do {
     let john = Customer(name: "John")
     let card = CreditCard(number: 1234_5678_9012_3456, customer: john)
     john.card = card

     leakedCard = card   // 👈 another strong reference
 } // john goes out of scope here

 What happens:

 • john is deallocated
 • leakedCard keeps CreditCard alive
 • CreditCard.customer is now a dangling reference

 Now this line:

 print(leakedCard!.customer.name)

 💥 CRASH

 Error (typical):
 Fatal error: Attempted to read an unowned reference but object was already deallocated

 🚨 Crash Scenario 2: Asynchronous access after customer is gone
 var card: CreditCard?

 do {
     let john = Customer(name: "John")
     card = CreditCard(number: 1234_5678_9012_3456, customer: john)
     john.card = card

     DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
         print(card!.customer.name) // 💥 crash
     }
 }
 // john deallocated immediately

 Why it crashes:

•  The async block runs after john is deallocated
•  card is still alive
•  Accessing customer hits an invalid pointer

 🚨 Crash Scenario 3: Escaping closure stored by the card
 class CreditCard {
     let number: UInt64
     unowned let customer: Customer
     var onUse: (() -> Void)?

     init(number: UInt64, customer: Customer) {
         self.number = number
         self.customer = customer
         self.onUse = {
             print(customer.name) // 💥 unowned access later
         }
     }
 }


 Later:

 var card: CreditCard?

 do {
     let john = Customer(name: "John")
     card = CreditCard(number: 1234, customer: john)
 } // john deallocated

 card?.onUse?() // 💥 crash

 🧠 Rule of Thumb

 • Use unowned ONLY when both are true:
 • The referenced object must outlive the owner
 • You can prove it structurally, not just logically

 If either is uncertain → use weak.
 */



class Department {
    var name: String
    var manager: Employee?  // strong reference (+1 when set)
    
    init(name: String) {
        self.name = name
    }

    deinit {
        print("Department is being deinitialized")
    }
}

class Employee {
    var name: String
    weak var department: Department?    // weak reference (0)

    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Employee is being deinitialized")
    }
}

class ExecutionARC {
    func executeDepartment() {
        var department: Department? = Department(name: "R&D")
        // Department ARC = 1  (held by variable `department`)
        
        var manager: Employee? = Employee(name: "Ramesh")
        // Employee ARC = 1  (held by variable `manager`)

        department?.manager = manager
        // Department ARC = 1  (unchanged)
        // Employee ARC = 2  (manager variable + department.manager)
        
        manager?.department = department
        // Employee ARC = 2  (unchanged)
        // Department ARC = 1  (weak reference adds 0)

        department = nil
        // Department ARC: 1 → 0 ? ❌ NO     department still exist in memory because
        // The variable department is gone
        // BUT Department.manager still strongly holds Employee
        // AND Employee is still strongly held by manager variable

        
        print(manager?.department?.name)
        manager = nil
        // manager variable released
        // Employee ARC: 2 → 1
        
        // ARC releases Department.manager, department?.manager = manager this one released now.
        // Because Employee.department is weak
        // When Employee is about to deinit, ARC clears weak refs
        // Employee ARC: 1 → 0 ✅
        
        // employee.department = nil   // automatic
    }
    
    /**
     If I comment the manager = nil then also I will get the output like
     
     Department is being deinitialized
     nil
     Employee is being deinitialized
     
     because the function ends its scope.
     And the reason of printing nil because, deparatment is nil, the main object of department is nil, so we can not get the name. And the program will not crash because of weak variable.
     */

}



/**
 What's the difference between weak and unowned?
 Both prevent retain cycles, but:

 weak: Optional, automatically set to nil when object deallocates.
 unowned: Non-optional, assumes object will always exist. Crashes if accessed after deallocation.
 */



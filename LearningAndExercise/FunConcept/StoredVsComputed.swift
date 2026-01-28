//
//  StoredVsComputed.swift
//  LearningAndExercise
//
//  Created by hb on 28/10/25.
//

import Foundation

/// https://stackoverflow.com/questions/31515805/difference-between-computed-property-and-property-set-with-closure
/// https://chatgpt.com/share/69019975-6898-800e-8101-f2c56f57fdd7

// MARK: - 🏠 Stored Property
/*
 A stored property actually holds data in memory.
 It's a box with something inside
 
 🖍️ Stored properties only live in structs and classes. Only static stored property can live inside enum.
 */

struct Player {
    var score: Int  // stored property
    lazy var bigData = [String]()  // only created when needed Lazy stored property.
}

/**
 Every Player instance literally has a chunk of memory reserved for score.

 They can be:
 • var (mutable)
 • let (constant once set)
 • Have default values
 • Or be lazy (loaded on first use)
 */



// MARK: - 🍱 2) Stored Property Initialized with a Closure
// This does store a value.
// The closure runs once at initialization and the resulting value is stored.
// A property observer is a Swift feature that lets you run code automatically when the value of a stored property changes.

struct Person {
    var firstName: String {
        didSet {
            firstName = firstName.uppercased()
        }
    }
    
    var greeting: String = {
        print("Calculating...")
        return "Hello John"
    }()
    
    /**
     The closure executes immediately during initialization.
     After that, greeting is just a value in memory.
     
     ✅ Evaluated once
     ✅ Value persists
     ❌ Won’t update automatically when related values change
     */
    
    // 🚀 Lazy version
    lazy var data: [String] = {
        print("Loading big data...")
        return ["A", "B", "C"]
    }()
    /**
     Lazy means:
     • The closure runs on first access
     • Then its result is stored forever
     */
    
    /// `🧩 willSet / didSet → Stored Property Observers
    // Used with stored properties to watch changes after Swift has already handled storage.
    // In Swift, property observers (willSet / didSet) do not run when properties are set inside init.
    // 📌 Property observers only run after initialization, when the property is mutated later.
    class ExampleOne {
        var name: String
        var score: Int = 30 {
            // Will only run when assign except init.
            willSet {
                print("Score will become \(newValue)")
            }
            didSet {
                print("Score was \(oldValue), now \(score)")
            }
        }
        
        init(name: String, score: Int) {
            self.name = name
            self.score = score
        }
        
        func updateScore() {
            self.score = 100
        }
    }
    
    var score: Int = 0 {
        willSet {
            print("Score will become \(newValue)")
        }
        didSet {
            print("Score was \(oldValue), now \(score)")
        }
    }
    /**
     • willSet triggers before the value changes
     • Default parameter name: newValue
     • didSet triggers after the value changes
     • Default parameter name: oldValue
     • 🖍️ Can modify value before saving?

     Great for reacting to changes, updating UI, validating, or logging
     */
}




// MARK: - 🧮 Computed Property
// A computed property is a property that does not store a value itself but instead calculates (or transforms) its value every time it is accessed or modified, using get and/or set.
// A computed property does not store data.
// It performs a little calculation every time you ask for it.
// get / set can not have a initial value. If you want to give initial value it will cause error.

struct Rectangle {
    var width: Double
    var height: Double
    var internalScore: Int
    
    var area: Double {          // Computed Property
        width * height
    }
    
    var perimeter: Double {
        get { 2 * (width + height) }
        set(newValue) {
            width = newValue / 4
            height = newValue / 4
        }
    }
    /**
     ✅ Do get / set of a computed property run in init?
     🔹 set → YES
     🔹 get → YES

     But only when they are accessed or assigned, not automatically.
     
     🔍 Why computed properties work during init
     
     Computed properties do not store values. They execute code whenever:

     🔹 get → the property is read
     🔹 set → the property is written
     
     This is true even inside init.


     🖍️ No memory box for area.
     It’s like a chef who cooks your meal fresh every time you order.

     🖍️ They can have:
     • Just a getter (read-only)
     • Or getter + setter (read/write)
     • `Can not be lazy.
     
     🖍️ Computed properties can appear in:
     • Structs
     • Classes
     • Enums
     • Protocols (requirements)
     
     ✅ Recalculated repeatedly
     ✅ Can react to other properties changing
     ❌ No persistent memory for its own value
     
     ➡️ A tiny metaphor

     Stored property:   A fridge full of food already prepared.
     Computed property: You ask the chef and they whip up something on demand.

     Both delicious, just different strategies.
     */
    
    
    /// `🎚 get / set → Computed Property Accessors
    /// Used when your property does not store a value directly, or when you want custom logic whenever it’s read or written.
    var score: Int {
        get { internalScore }
        set { internalScore = newValue }
    }
    /**
     • get runs whenever the value is read
     • set runs whenever the value is changed
     • You can transform or calculate values inside
     • No automatic storage required (unless you back it with another property)
     
     Shortcut: If only get exists, you skip the keyword.
        var doubled: Int { number * 2 }
     */
}

// MARK: Important quesion on computed property
/**
 struct Student {
     private var _firstName: String

     var firstName: String {
         get {
             return _firstName
         }
         set {
             _firstName = newValue.uppercased()
         }
     }
 }


 in the above if I do not create private var _firstName: String and directly return firstName and also assing new value to firstName then why compiler giving error of may cause recursion. Why?
 
 
 Ans -
 
 ❓ Why does the compiler say “may cause recursion”?

 Because firstName would be calling itself.

 When you write a computed property, the property name refers to the computed property itself, not to some hidden storage.
 
 struct Student {
     var firstName: String {
         get {
             return firstName   // ❌ refers to itself
         }
         set {
             firstName = newValue.uppercased() // ❌ refers to itself
         }
     }
 }

 
 // so always use another variable
 ✅ Correct Pattern (Why _firstName Exists)
 
 struct Student {
     private var _firstName: String

     var firstName: String {
         get {
             return _firstName
         }
         set {
             _firstName = newValue.uppercased()
         }
     }
 }
 */



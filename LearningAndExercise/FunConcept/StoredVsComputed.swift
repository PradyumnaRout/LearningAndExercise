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
    lazy var bigData = [String]()  // only created when needed
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

struct Person {
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
// A computed property does not store data.
// It performs a little calculation every time you ask for it.

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



class TestProperty {
    
    var name: String = "Santanu"
    var lastName: String = "Sahoo"
    
    lazy var fullName: String = {
        let wholeName = name + lastName
        return wholeName
    }()
    
    func testProperty() {
        name = "Manmath"
        let wholeName = fullName
        print(wholeName)
    }
}

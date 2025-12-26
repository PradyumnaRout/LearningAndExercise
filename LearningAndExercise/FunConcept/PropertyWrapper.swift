//
//  PropertyWrapper.swift
//  LearningAndExercise
//
//  Created by hb on 26/12/25.
//

import Foundation
import SwiftUI

// https://medium.com/@sagar.ajudiya/property-wrappers-in-swift-ui-e352c07e5845
// https://medium.com/@EvangelistApps/property-wrappers-in-swift-51cee87e2c32

// MARK: Property Wrapper
/**
 
 A property wrapper is a struct or class or enum marked by @propertyWrapper that creates a layer of abstraction over the property which manages hwo a property is stored or accessed.
 
 It reduce bilerplate code and improves redability.
 */

// MARK: ➡️ When should you use Property Wrapper?


// Let's take the below example of struct Student that returns and prints out the name in all caps.
struct  Student {
    var firstName: String
    var lastName: String
}

// Instead of applying the uppercased() wherever we needs to convert it. There are couple of effective ways we can achieve it in swift. They are

// 1. Property Observer (willSet, didSet) -> (Stored Properties)
// 2. Computed Properties (get, set)

//➡️ Using Property Observeers to Capitalize the names:
// A property observer is a Swift feature that lets you run code automatically when the value of a stored property changes.
struct StudentPropertyObserver {
    var firstName: String {
        didSet {
            print("First Name Assigned")
            firstName = firstName.uppercased()
        }
    }
    
    var lastName: String {
        didSet {
            print("Last Name Assigned")
            lastName = lastName.uppercased()
        }
    }
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        
        // In Swift, property observers (willSet / didSet) do not run when properties are set inside init.
        // 📌 Property observers only run after initialization, when the property is mutated later.
        
        // so "First Name Assigned" or "Last Name Assigned" won't be printed during inititalization.
        // So output will be - FistName: ramesh, LastName: bharadwaj
    }
}


//➡️ Using Computed Property to capitalize the names, get/set.
// A computed property is a property that does not store a value itself but instead calculates (or transforms) its value every time it is accessed or modified, using get and/or set.

/**
 ✅ Do get / set of a computed property run in init?
 🔹 set → YES
 🔹 get → YES

 But only when they are accessed or assigned, not automatically.
 
 🔍 Why computed properties work during init
 
 Computed properties do not store values. They execute code whenever:

 🖍️ No memory box for area.
 🔹 get → the property is read
 🔹 set → the property is written
 
 This is true even inside init.
 */

struct StudentComputedProperty {
    private var _firstName: String = ""
    private var _lastName: String = ""
    
    var firstName: String {
        get {
            return _firstName
        } set {
            _firstName = newValue.uppercased()
        }
    }
    
    var lastName: String {
        get {
            return _lastName
        } set {
            _lastName = newValue.uppercased()
        }
    }
    
    init(_firstName: String, _lastName: String) {
        self.firstName = _firstName
        self.lastName = _lastName
    }
}


class PropertyWrapperExecution {
    
    // Property Observer:
//    var student: StudentPropertyObserver
//    
//    init(student: StudentPropertyObserver) {
//        self.student = student
//    }
    
    // Computed Property:
//    var studentComputed: StudentComputedProperty
//    init(studentComputed: StudentComputedProperty) {
//        self.studentComputed = studentComputed
//    }
    
    // Property Wrapper
    @AllCapsComputed var firstName: String
    @AllCapsComputed var lastName: String
    @InRange var score: Int
    
    init(firstName: String, lastName: String, score: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.score = score
    }

}

/**
 
 In both of these approaches we have some drawbacks i.e if there are N number of variables in the struct to be capitalized, this would lead to applying the logic to all the variables resulting in a lot of redundant code. This is where Property Wrapper comes for a rescure and a perfet place to avoid the redundant / biolerplate code.
 
 // HOW TO CREATE CUSTOM PROPERTY WRAPPER?
 
 To define a property wrapper, we have to decorate the class, struct and enum type with the @PropertyWrapper keyword and then have to implement a property called wrappedValue in it.
 */

// Lets create a new type called AllCaps property observer to always return name in capitalized

// MARK: Property Wrapper Property Observer Approach.
@propertyWrapper
struct AllCaps {
    var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.uppercased()
        }
    }
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.uppercased()
    }
}

/**
 We added the @propertyWrapper in fornt of the struct AllCaps and added a wrappedValue property in it. On the wrappedValue, we added the property observer to apply the capitalized logic.
 
 on the property declaration, we have to decorate the property with the @AllCaps Keyword which is a property observer. We just need to add @AllCaps keyword to the properties that return the property in capitalized letters.
 
 @AllCaps var name: String = "Steve Jobs"
 
 Now when we try to access the property it will always return the string in capitalized letters.
 
 ➡️ In this property observer approach, we have to apply the logic in init, because didSet observers are not called when the property is first initialized so we have to add the logic in init.
 
 So we are going to use an alternate approach computed property in the property wrapper.
 */


// MARK: Property Wrapper Computed Property Approach.
// In this approach, we are applying the logic only in the getter instead of applying it twice like the property obserever approach.

@propertyWrapper
struct AllCapsComputed {
    private var name: String
    
    var wrappedValue: String {
        get {
            return name.uppercased()
        } set {
            name = newValue
        }
    }
    
    init(wrappedValue: String) {
        self.name = wrappedValue
    }
}

// lets add another property in student called score which is always in the range between 0 to 100. So let's create another property wrapper called InRange which will allow the property to be in between the range 0 to 100



@propertyWrapper
struct InRange {
    private var mark: Int
    
    var wrappedValue: Int {
        get {
            return max(0, min(mark, 100))
        } set {
            mark = newValue
        }
    }
    
    init(wrappedValue: Int) {
        self.mark = wrappedValue
    }
}



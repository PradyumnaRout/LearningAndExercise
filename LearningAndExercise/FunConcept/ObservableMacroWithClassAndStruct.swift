//
//  ObservableMacroWithClassAndStruct.swift
//  LearningAndExercise
//
//  Created by hb on 09/02/26.
//

import Foundation
import SwiftUI

// MARK: Scenario 1: UserDetail is a Class
class UserDetailOBSMacro1 {
    var age: Int
    var name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

@Observable
class UserViewModelOBSMacro1 {
    var user = UserDetailOBSMacro1(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
    }
}

struct ContentViewOBSMacro1: View {
    var vm = UserViewModelOBSMacro1()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGOne") {
    ContentViewOBSMacro1()
    /**
     Result: The view will NOT update ❌
     Why? Because user is a reference type (class). When you change user.age, you're modifying the contents of the object, but the user property itself (the reference/pointer) hasn't changed. The @Observable macro tracks changes to the user property, not changes within the object it points to.
     */
}

// MARK: Scenario 2: UserDetail is a Struct
struct UserDetailOBSMacro2 {
    var age: Int
    var name: String
}

@Observable
class UserViewModelOBSMacro2 {
    var user = UserDetailOBSMacro2(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
    }
}

struct ContentViewOBSMacro2: View {
    var vm = UserViewModelOBSMacro2()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGTwo") {
    ContentViewOBSMacro2()
    /**
     Result: The view WILL update ✅
     Why? Because user is a value type (struct). When you change user.age, Swift creates a new copy of the struct with the updated value and assigns it back to user. This means the user property itself changes, which the @Observable macro detects and triggers a view update.
     */
}



// MARK: Solutions for Class-based UserDetail
// If you need UserDetail to be a class, here are your options:
//Option 1: Make UserDetail also @Observable

@Observable
class UserDetailOBSMacro3 {
    var age: Int
    var name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

@Observable
class UserViewModelOBSMacro3 {
    var user = UserDetailOBSMacro3(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
        user = user     // Force reassignment to trigger observation
    }
}

struct ContentViewOBSMacro3: View {
    var vm = UserViewModelOBSMacro3()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGThree") {
    ContentViewOBSMacro2()
}


// MARK: Solutions for Class-based UserDetail - is there any other solution
/*
 Option 3: Manually trigger observation with withObservationTracking
 Actually, the simpler approach is to reassign the user property after mutation:
 swiftclass UserDetail {
     var age: Int
     var name: String
     
     init(age: Int, name: String) {
         self.age = age
         self.name = name
     }
 }

 @Observable
 class UserViewModel {
     var user = UserDetail(age: 20, name: "Pradyumna")
     
     func increaseAge() {
         user.age += 1
         // Trigger change by reassigning - but this is awkward
         let temp = user
         user = temp
     }
 }
 But this is clunky. Here's a better pattern:

 Option 4: Use a computed property wrapper
 swiftclass UserDetail {
     var age: Int
     var name: String
     
     init(age: Int, name: String) {
         self.age = age
         self.name = name
     }
 }

 @Observable
 class UserViewModel {
     private var _user = UserDetail(age: 20, name: "Pradyumna")
     
     var user: UserDetail {
         get { _user }
         set { _user = newValue }
     }
     
     func increaseAge() {
         _user.age += 1
         user = _user  // Trigger observation through setter
     }
 }

 Option 5: Keep individual properties in ViewModel (flatten the model)
 
 @Observable
 class UserViewModel {
     var age: Int = 20
     var name: String = "Pradyumna"
     
     func increaseAge() {
         age += 1
     }
 }

 struct ContentView: View {
     var vm = UserViewModel()
     
     var body: some View {
         VStack {
             Text("Age: \(vm.age)")
             
             Button("Increase Age") {
                 vm.increaseAge()
             }
         }
     }
 }
 This works perfectly and is often the cleanest approach! ✅

 Option 6: Use @ObservationIgnored + manual notification
 
 @Observable
 class UserViewModel {
     @ObservationIgnored private var _user = UserDetail(age: 20, name: "Pradyumna")
     
     var user: UserDetail {
         @storageRestrictions(initializes: _user)
         init(initialValue) {
             _user = initialValue
         }
         get {
             access(keyPath: \.user)
             return _user
         }
         set {
             withMutation(keyPath: \.user) {
                 _user = newValue
             }
         }
     }
     
     func increaseAge() {
         withMutation(keyPath: \.user) {
             _user.age += 1
         }
     }
 }

 My Recommendation:
 For your scenario, the best solutions are:

 Make UserDetail a struct (simplest and most idiomatic)
 Make UserDetail also @Observable (if it needs to be a class)
 Flatten the properties into the ViewModel directly (Option 5)
 */

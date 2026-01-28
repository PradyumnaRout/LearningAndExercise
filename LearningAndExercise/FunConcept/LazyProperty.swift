//
//  LazyProperty.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

import Foundation

class UserDetail {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}


class TestProperty {
    
    var name: String = "Santanu"
    var lastName: String = "Sahoo"
    
    var user = UserDetail(firstName: "Pradyumna", lastName: "Rout")
    
    lazy var fullName: String = {
        let wholeName = name + lastName
        return wholeName
    }()
    
    lazy var exampleRef1: UserDetail = {
        return UserDetail(firstName: name, lastName: lastName)
    }()
    
    func testProperty() {
        print("====== Value Types =======")
        print("First: \(fullName)")
        name = "Manmath "
        print("Second: \(fullName)")
        
        print("\n====== Reference Types =======")
        print("First: \(exampleRef1.firstName) \(exampleRef1.lastName)")
        name = "Harish"
        print("Second: \(exampleRef1.firstName) \(exampleRef1.lastName)")
        
        
        print("\n==== Now chnage the name in the lazy property itself ====")
        exampleRef1.firstName = "Samar"
        print("First: \(exampleRef1.firstName) \(exampleRef1.lastName)")
    }
}

/*
 Output - when TestProperty is a class -
 ====== Value Types =======
 First: SantanuSahoo
 Second: SantanuSahoo

 ====== Reference Types =======
 First: Manmath  Sahoo
 Second: Manmath  Sahoo
 
 ==== Now chnage the name in the lazy property itself ====
 First: Samar Sahoo
 
 Output - when TestProperty is a struct -
 ====== Value Types =======
 First: SantanuSahoo
 Second: SantanuSahoo

 ====== Reference Types =======
 First: Manmath  Sahoo
 Second: Manmath  Sahoo
 
 ==== Now chnage the name in the lazy property itself ====
 First: Samar Sahoo
 

 So the output totally depens upon what you are updating the object or the property from which you are calculating lazy property. But lazy property always run once.
 So changing name will not affect lazy here.
 
 🧠 So no matter the type -
 lazy initializer runs ONCE
 result is stored
 never auto-recomputed
 
 */

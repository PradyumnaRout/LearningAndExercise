//
//  LazyProperty.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

import Foundation

class User: Comparable {
    var name: String
    init(name: String) { self.name = name }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}


/**
 - Lazy property of value types does no update on something change in propery.
 - But in case of referecen proerty it updates.
 
 
 SO the final verdict is that lazy porperty only update if it is of reference type. If the variable is of value type, it does not update.
 */

class UserViewModel {
    
    // Raw data (might come from API or DB)
    var valueTypeUsers: [String] = [
        "Alice Johnson",
        "Bob Smith",
        "Charlie Williams",
        "Diana Ross",
        "Edward Norton"
    ]
    
    var refTypeUsers: User = User(name: "Alice")
    var valueTypeUserName: String = "Samir"
    
    // Lazy property: computed only when accessed the first time
    lazy var sortedValueTypeUsers: [String] = {
        print("Sorting users...") // just to demonstrate when it runs
        return valueTypeUsers.sorted()
    }()
    
    lazy var valueTypeUsersCountText: String = {
        return "Total users: \(valueTypeUsers.count)"
    }()
    
    lazy var changeValueUserName: String = {
        return valueTypeUserName
    }()
    
    lazy var changeRefUser: User = {
        refTypeUsers.name = "Bob"
        return refTypeUsers
    }()
        
    
    func testLazyProperty() {
        // At this point, sortedUsers has NOT been computed yet
        print("Before accessing sortedUsers")

        print("------- Value Types --------")
//        // First access triggers computation
//        print(self.sortedValueTypeUsers)
//        // Console: "Sorting users..."
//        // ["Alice Johnson", "Bob Smith", "Charlie Williams", "Diana Ross", "Edward Norton"]
//
//        // Accessing again will NOT recompute, it reuses the stored as it stores value types in it.
//        print(self.sortedValueTypeUsers)
        

        // Lazy property for count text
//        print(self.valueTypeUsersCountText) // "Total users: 5"
        
        print(self.changeValueUserName)
        
        print("------- Reference Types --------")
        
        print(self.changeRefUser.name)
    }
    
    func addNewOne() {
//        valueTypeUsers.append("Chamela Struat")
//        print("After addition :: \(self.sortedValueTypeUsers)")
//        print("After addition :: \(self.valueTypeUsersCountText)")
        valueTypeUserName = "Gautam"
        print("After addition :: \(self.valueTypeUserName)")
        print("After addition changed value type user name :: \(self.changeValueUserName)")
        
        
        refTypeUsers.name = "Berlin"
        print("After addition :: \(self.refTypeUsers.name)")
    }
}


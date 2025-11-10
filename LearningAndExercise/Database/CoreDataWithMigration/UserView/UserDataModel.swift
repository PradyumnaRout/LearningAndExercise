//
//  UserDataModel.swift
//  LearningAndExercise
//
//  Created by hb on 07/11/25.
//

import Foundation

struct UserDataModel: Identifiable {
    let id = UUID().uuidString
    var firstName: String?
    var lastName: String?
    var age: Int32?
    var email: String?
    var profilePic: String?
    var place: String?
    
    var fullName: String {
        "\(firstName ?? "") \(lastName ?? "")"
    }
}


extension UserDataModel {
    
    init(user: User) {
        self.firstName = user.firstName
        self.lastName = user.familyName
        self.age = user.age
        self.email = user.email
        self.profilePic = user.profilePic
        self.place = user.place
    }
    
}

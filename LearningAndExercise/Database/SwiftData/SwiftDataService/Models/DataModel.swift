//
//  DataModel.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftData

@Model
class AppUser {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \UserPost.user)
    var post: [UserPost] = []
    
    init(name: String) {
        self.name = name
    }
}

@Model
class UserPost {
    var title: String
    var user: AppUser?
    
    init(title: String, user: AppUser? = nil) {
        self.title = title
        self.user = user
    }
}

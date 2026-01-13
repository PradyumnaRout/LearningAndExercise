//
//  SwiftDataService.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftData
import Foundation

@Observable
final class SwiftDataService {
    private let container: ModelContainer
    private let context: ModelContext
    
    init() {
        let schema = Schema([AppUser.self, UserPost.self])
        let configuration = ModelConfiguration("UserModel", schema: schema)
        
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
            context = ModelContext(container)
        } catch {
            fatalError("Coudn't create model container!!")
        }
    }
    
    // MARK: - Create
    func createUser(name: String) async throws -> AppUser {
        let user = AppUser(name: name)
        context.insert(user)
        
        try context.save()
        return user
    }
    
    func createPost(title: String, for user: AppUser) throws {
        let post = UserPost(title: title, user: user)
        context.insert(post)
        try context.save()
    }
    
    // MARK: Fetch
    func fetchUser() throws -> [AppUser] {
        let descriptor = FetchDescriptor<AppUser>()
        return try context.fetch(descriptor)
    }
    
    func fetchPosts() throws -> [UserPost] {
        let descriptor = FetchDescriptor<UserPost>()
        return try context.fetch(descriptor)
    }
    
    // persistentModelID is SwiftData’s unique, permanent identifier for a model object.
    //Think of it like a primary key in a database.
    //Every @Model object has one:
//    func updateUser(id: PersistentIdentifier, newName: String) throws {
//        let descriptor = FetchDescriptor<AppUser>(
//            predicate: #Predicate { $0.persistentModelID == id }
//        )
//
//        guard let user = try context.fetch(descriptor).first else {
//            throw NSError(domain: "UserNotFound", code: 404)
//        }
//
//        user.name = newName
//        try context.save()
//    }
    
    func updateUser(_ user: AppUser, newName: String) throws {
        user.name = newName
        try context.save()
    }
    
    func updatePost(_ post: UserPost, newTitle: String) throws {
        post.title = newTitle
        try context.save()
    }

}

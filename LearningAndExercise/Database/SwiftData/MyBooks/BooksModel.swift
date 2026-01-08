//
//  BooksModel.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import Foundation
import SwiftUI
import SwiftData

//MARK: Important about migration
/// If you want to add a new optional attribute by asigning nil as default value, just add it in the model, it will automatically reflect in the db table, as SwiftData will handle it automatically.
/// But if you add a non optional with a default value / empty string the application will crash. And db willnot be updated automatically.
/// Because we are asigning an default value in the initializer, which will only run when we create an Book Object but when our app run, when it wants to ccreate a container, it does not know the default value of the new attribute. So to handle this we need to add default value to it at the time of declaration. Now if you check the db after the app run you will see empty string in each data row.

@Model
class Book {
    var title: String
    var author: String
    var dateAdded: Date
    var dateStarted: Date
    var dateCompleted: Date
    @Attribute(originalName: "summary")         // Renaming Attribute Name
    var synopsis: String
    var rating: Int?
    var status: Status.RawValue
    var recommendedBy: String = ""
    
    // Some Other important attributes, if you add, SwiftData will handle its migration automatically.
//    @Attribute(.externalStorage)
//    var avatar: Data
//    
//    @Attribute(.allowsCloudEncryption)
//    var sin: String
//    
//    @Attribute(.unique)
//    var title: String
    
//    @Relationship(.deleteRule: .cascade)
//    var quotes: [Quote]?
    
    init(
        title: String,
        author: String,
        dateAdded: Date = Date.now,
        dateStarted: Date = Date.distantPast,
        dateCompleted: Date = Date.distantPast,
        synopsis: String = "",
        rating: Int? = nil,
        status: Status = .onShelf,
        recommendedBy: String = ""
    ) {
        self.title = title
        self.author = author
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.synopsis = synopsis
        self.rating = rating
        self.status = status.rawValue
        self.recommendedBy = recommendedBy
    }
    
    // Computed property are not stored in the database so there is no change in db.
    var icon: Image {
        switch Status(rawValue: status)! {
        case .onShelf:
            Image(systemName: "checkmark.diamond.fill")
        case .inProgress:
            Image(systemName: "book.fill")
        case .completed:
            Image(systemName: "books.vertical.fill")
        }
    }
}


enum Status: Int, Codable, Identifiable, CaseIterable {
    case onShelf, inProgress, completed
    
    var id: Self {
        self
    }
    
    var desc: String {
        switch self {
        case .onShelf: "On Shelf"
        case .inProgress: "In Progress"
        case .completed: "Completed"
        }
    }
}

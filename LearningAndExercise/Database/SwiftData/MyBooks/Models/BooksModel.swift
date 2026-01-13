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
//    #Index<Book>([\.title], [\.genres])
//    #Unique<Book>([\.title, \.author])        //“Do not allow two books with the same title AND author.”
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
    @Relationship(deleteRule: .cascade)  // For deleting relation ship datas.
    var quotes: [Quote]?
    @Relationship(inverse: \Genre.books)
    var genres: [Genre]?
    
    // MARK: If you store all of your data for all of your book images directly in your sqlite database that used for swiftData, it won't be long before your data store gets bloated. And likely things will start to slow down and you might run into issues. Well both swiftData and Core data have an option that let you store the object as a reference only and then it stores the actual image locally in some hidden folder. All we have to do enable that is to provide an attribute .extenalStore for the property. Similarly in core data Enable "Allows External Storage" in the inspectore in the core data model. It will also store it in your cloudKit repo as well as an asset.
    
    // To see the uploaded data go to the folder location (Application Support) and type CMD + Shift + Period(.) to show hidden folder. There you can find the uploaded data.
    @Attribute(.externalStorage)
    var bookCover: Data?
    
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
    
    var desc: LocalizedStringResource {
        switch self {
        case .onShelf: "On Shelf"
        case .inProgress: "In Progress"
        case .completed: "Completed"
        }
    }
}

/**
 What is #Index<Book>([\.title], [\.genres]) ?
 
 It tells SwiftData: “Please make searching by title and genres fast for Book objects.”
 
 Why is that useful?
 
 Imagine you have 10,000 books. If you search for:
 Find all books with title = "Dune"
 
 Without an index → SwiftData checks every single book 😴
 With an index → SwiftData jumps directly to matching books ⚡️
 
 Real-world analogy

 Think of a phone book 📖
 Without an index → you flip through every page
 With an index (alphabetical tabs) → you jump straight to "D"
 That’s exactly what an index does.

 
 How it looks in code
 @Model
 #Index<Book>([\.title], [\.genres])
 class Book {
     var title: String
     var genres: [String]
 }


 This means:

 You store books
 You often search by title or genres
 SwiftData should optimize for that
 
 
 What is #Unique<Book>([\.title, \.author])?
 It tells SwiftData:  “Do not allow two books with the same title AND author.”
 
 So this is allowed:

 "Dune" by Frank Herbert
 "Dune" by Someone Else

 But this is NOT allowed:

 "Dune" by Frank Herbert
 "Dune" by Frank Herbert ❌ duplicate
 
 SwiftData will throw an error when saving:
 let book = Book(title: "Dune", author: "Frank Herbert")
 context.insert(book)
 try context.save() // ❌ error if duplicate exists

 */

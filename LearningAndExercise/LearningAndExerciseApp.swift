//
//  LearningAndExerciseApp.swift
//  LearningAndExercise
//
//  Created by hb on 17/10/25.
//

import SwiftUI
import SwiftData

@main
struct LearningAndExerciseApp: App {
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            BookListView()
        }
        .modelContainer(container)
//        .modelContainer(for: Book.self)
//        .modelContainer(for: [User.self, Company.self])   // can also allow multiple model.
    }
    
    init() {
        
        //MARK:  🧠 You may thing that, as we are introducing relation ship, we have to add the new model to the modelContainer, schema in the app entry point. But actually we don't need to add this beccause SwiftData is smart enough to identify it as it has relationship with the Book model. Now after run you can check out db has the quote model in it automatically
        
        // Using Schema (Used for migration)
        let schema = Schema([Book.self])
        let config = ModelConfiguration("MyBooks", schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not configure the container")
        }
        
        /// Inside Document directory:
//        let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "MyBooks.store"))   // Container Location.
//        do {
//            container = try ModelContainer(for: Book.self, configurations: config)
//        } catch {
//            fatalError("Could not configure the container")
//        }
//        print(URL.documentsDirectory.path())
        
        print("Data Location:: \(URL.applicationSupportDirectory.path(percentEncoded: false))")
    }
}

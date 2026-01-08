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

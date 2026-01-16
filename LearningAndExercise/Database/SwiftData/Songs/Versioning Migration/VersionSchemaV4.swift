//
//  VersionSchemaV4.swift
//  LearningAndExercise
//
//  Created by hb on 16/01/26.
//

import Foundation
import SwiftData

enum MySchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 1, 1)

    static var models: [any PersistentModel.Type] {
        [Song.self, Book.self]
    }
}

extension MySchemaV4 {
    @Model
    class Song {
        var title: String
        @Attribute(originalName: "albumName")
        var album: String
        var runTime: String
        var runTimeInFloat: Float = 0.0
        var releaseYear: String
        var singer: String = ""    // Always assing a value or make it nil when you add new property for migration.

        init(title: String, album: String, runTime: String, releaseYear: String) {
            self.title = title
            self.album = album
            self.runTime = runTime
            self.releaseYear = releaseYear
        }
    }
}



enum MySchemaV5: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 1, 1)

    static var models: [any PersistentModel.Type] {
        [Song.self, Book.self]
    }
}

extension MySchemaV5 {
    @Model
    class Song {
        var title: String
        @Attribute(originalName: "albumName")
        var album: String
        var runTimeInFloat: Float = 0.0
        var releaseYear: String
        var singer: String = ""    // Always assing a value or make it nil when you add new property for migration.

        init(title: String, album: String, runTime: Float, releaseYear: String) {
            self.title = title
            self.album = album
            self.runTimeInFloat = runTime
            self.releaseYear = releaseYear
        }
    }
}

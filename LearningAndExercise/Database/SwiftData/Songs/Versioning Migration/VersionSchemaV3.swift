//
//  VersionSchemaV3.swift
//  LearningAndExercise
//
//  Created by hb on 16/01/26.
//

import Foundation
import SwiftData


// Major, Minor, Patch
// Major chnage(Heavy weight), Minor(New Functionality), Patch(Small Chnages) (like rename)
// Here I want to new property so the version will be (1, 1, 1)

enum MySchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 1)

    static var models: [any PersistentModel.Type] {
        [Song.self, Book.self]
    }
}

extension MySchemaV3 {
    @Model
    class Song {
        var title: String
        @Attribute(originalName: "albumName")
        var album: String
        var runTime: String
        var releaseYear: String
        var singer: String = ""     // Always assing a value or make it nil when you add new property for migration.

        init(title: String, album: String, runTime: String, releaseYear: String) {
            self.title = title
            self.album = album
            self.runTime = runTime
            self.releaseYear = releaseYear
        }
    }
}

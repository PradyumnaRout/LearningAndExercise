//
//  VersionSchemaV2.swift
//  LearningAndExercise
//
//  Created by hb on 16/01/26.
//

import Foundation
import SwiftData

// Version(1, 0, 0)

// Major, Minor, Patch
// Major chnage(Heavy weight), Minor(New Functionality), Patch(Small Chnages) (like rename)

enum MySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 1)

    static var models: [any PersistentModel.Type] {
        [Song.self, Book.self]
    }
}

extension MySchemaV2 {
    @Model
    class Song {
        var title: String
        @Attribute(originalName: "albumName")
        var album: String
        var runTime: String
        var releaseYear: String

        init(title: String, album: String, runTime: String, releaseYear: String) {
            self.title = title
            self.album = album
            self.runTime = runTime
            self.releaseYear = releaseYear
        }
    }
}


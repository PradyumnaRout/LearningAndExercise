//
//  VersionScemaV1.swift
//  LearningAndExercise
//
//  Created by hb on 16/01/26.
//

import Foundation
import SwiftData

enum MySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Song.self, Book.self]
    }
}

extension MySchemaV1 {
    @Model
    class Song {
        var title: String
        var albumName: String
        var runTime: String
        var releaseYear: String

        init(title: String, albumName: String, runTime: String, releaseYear: String) {
            self.title = title
            self.albumName = albumName
            self.runTime = runTime
            self.releaseYear = releaseYear
        }
    }
}


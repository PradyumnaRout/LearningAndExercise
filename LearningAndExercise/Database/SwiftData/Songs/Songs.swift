//
//  Songs.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftData

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

//
//  Genre.swift
//  LearningAndExercise
//
//  Created by hb on 09/01/26.
//

import Foundation
import SwiftData

@Model
class Genre {
    var name: String
    var hexColor: String
    var books: [Book]?
    
    init(name: String, color: String) {
        self.name = name
        self.hexColor = color
    }
}

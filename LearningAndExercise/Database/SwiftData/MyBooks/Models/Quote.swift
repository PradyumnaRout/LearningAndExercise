//
//  Quote.swift
//  LearningAndExercise
//
//  Created by hb on 09/01/26.
//

import Foundation
import SwiftData

//MARK:  🧠 You may thing that, as we are introducing relation ship, we have to add the new model to the modelContainer, schema in the app entry point. But actually we don't need to add this beccause SwiftData is smart enough to identify it as it has relationship with the Book model. Now after run you can check out db has the quote model in it automatically


@Model
class Quote {
    var creationDate: Date = Date.now
    var text: String
    var page: String?
    
    init(text: String, page: String? = nil) {
        self.text = text
        self.page = page
    }
    
    var book: Book?
}

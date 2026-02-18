//
//  MultipleTypeDecode.swift
//  LearningAndExercise
//
//  Created by hb on 17/02/26.
//

import Foundation

// MARK: Decoding single variable which may come in Int or String type.
enum MyAgeType: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        if let intValue = try? decoder.singleValueContainer().decode(Int.self){
            self = .int(intValue)
            return
        }
        if let stringValue = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(stringValue)
            return
        }
        
        throw MyAgeTypeError.missingValue
    }
    
    enum MyAgeTypeError: Error {
        case missingValue
    }
}

//
//  EnviornmentManager.swift
//  LearningAndExercise
//
//  Created by hb on 23/10/25.
//

import Foundation

enum AppEnvironment {
    
    // Static keys for Info.plist
    private static let endPointKey = "END_POINT"
    private static let apiKeyKey = "API_KEY"
    private static let environmentKey = "ENVIRONMENT"
    
    
    // Static computed properties
    static var endPoint: String? {
        guard let endPoint = Bundle.main.infoDictionary?[endPointKey] as? String else { return nil }
        return endPoint
    }
    
    static var apiKey: String? {
        guard let apiKey = Bundle.main.infoDictionary?[apiKeyKey] as? String else { return nil }
        return apiKey
    }
    
    static var environment: String? {
        guard let env = Bundle.main.infoDictionary?[environmentKey] as? String else { return nil }
        return env
    }
    
    // Static function to log configuration
    static func logConfiguration() {
        print("END_POINT: \(endPoint ?? "nil")")
        print("API_KEY: \(apiKey ?? "nil")")
        print("ENVIRONMENT: \(environment ?? "nil")")
        
    }
}

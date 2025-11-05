//
//  EnviornmentManager.swift
//  LearningAndExercise
//
//  Created by hb on 23/10/25.
//

// https://medium.com/@nehapenkalkar/managing-multiple-environments-in-ios-a-comprehensive-guide-03aaa44a7225
// https://satvasolutions.com/blog/set-up-ios-environments-using-xcode-schemes-production-sandbox
// https://medium.com/@tejaswini-27k/ios-project-different-environments-xcode-configurations-and-scheme-752ee4404bfa
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

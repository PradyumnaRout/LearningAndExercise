//
//  DependencyInversionAndInjection.swift
//  LearningAndExercise
//
//  Created by hb on 20/11/25.
//

import Foundation

protocol APIService {
    var url: String { get set }
    
    func fetchData()
}


class AuthAPIService: APIService {
    var url: String = ""
    
    func fetchData() {
        
    }
}

class ProfileAPIService: APIService {
    var url: String = ""
    
    func fetchData() {
        
    }
}


class DependencyInversionAndInjection {
    // Dependency Inversion
    // Using protocol instead of concrete class so it won't be tightly coupled with the service classess, we can use any service class confirms APIService
    private let service: APIService
    
    
    // Dependency Injection using initializer, we can say dependency injection as creating object using Constructor Injection, as Property Injection, Method Injection etc outside the class rather than creating concrete class inside the user class/function
    // Here we are using APIService "inside DependencyInversionAndInjection" but instead of creating APIService inside the class we only use its object.
    init(service: APIService) {
        self.service = service
    }
    
    func fetch() {
        self.service.fetchData()
    }
}

//
//  CombinePartFive.swift
//  LearningAndExercise
//
//  Created by hb on 30/10/25.
//

import Foundation
import Combine

// MARK: - Error Handling in Combine

/*
 
 In this section we will use mose: try Operators, mapError, retry, catch, replaceError, setFailureType, and a practical, production-style
 network pipeline.
 
 The Basics: Output and Failure
 
 Every Publisher has two associated type:
 👉 Output - The value type it emits.
 👉 Failure: Error - the error type, or Never if it can not fail.
 
 A pipeline that can't fail is nice for UI streams, a failing pipeline is expected for I/O like networking.
 
     // Cannot fail
     let neverFails = Just(42) // Failure == Never

     // Can fail
     struct APIError: Error { let message: String }
     let failing = Fail<String, APIError>(error: .init(message: "Boom"))
     
 
 Where Do Errors Come From?
     🔘 try operators: tryMap, tryFilter, tryCompactMap, etc.
     🔘 Decoding: decode(type:decoder:) emits decoding errors.
     🔘 URLSession: dataTaskPublisher can fail with transport errors.
     🔘 Custom publishers: anything that throws up-stream.
 
 
 
 Notes ➡️
 🔘retry sits before catch.
 🔘mapError normalizes errors early.
 🔘catch decides whether to recover or re-fail.
 🔘setFailureType is used when switching to a non-failing fallback like Just.
 🔘Checklist for Robust Error Handling
 
 ✅ Normalize early with mapError.
 ✅ Use retry(_:) sparingly for transient issues.
 ✅ Prefer catch for graceful fallbacks (cached/placeholder data).
 ✅ Use replaceError(with:) when you don’t care about the error.
 ✅ Keep streams non-failing for UI where possible.
 ✅ Log receiveCompletion for observability.
 
 */



enum AppError: Error {
    case network(URLError)
    case decoding(DecodingError)
    case other(String)
}

struct HTTPError: Error {
    let statusCode: Int
}

struct UserSubject: Codable {
    let name: String
    let surname: String
}

class NormalizeError {
    var cancellable = Set<AnyCancellable>()
    
    
    //🔷 Normalize Errors with mapError
    // Unify disparate erros into one domain-specific type.
    // It makes downstream handling simpler and keeps your sink clean.
    func normalizeWithMapError() {
        URLSession.shared.dataTaskPublisher(for: URL(string: "...")!)
            .mapError { error -> AppError in    // URLError -> AppError  // Converts any failure from the upstream publisher to new error.
                print("Finished with error!")
                return AppError.network(error)
            }
            .map(\.data)
            .decode(type: UserSubject.self, decoder: JSONDecoder())
            .mapError { error -> AppError in    // DecodeError -> AppError
                (error as? DecodingError).map(AppError.decoding) ?? .other("error")
            }
            .map(\.name, \.surname)
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { (name, surname) in
                print("Name: \(name), Surname: \(surname)")
            }
            .store(in: &cancellable)
    }
    
    
    //🔷 Retry Transient Failures with retry :
    // retry(_:) resubscribers to the upstream when it fails. Put it before catch, or it won't run.
    // Good for flaky networks. Don’t abuse it for permanent errors (e.g., 404).
    func normalizeWithRetry() {
        URLSession.shared.dataTaskPublisher(for: URL(string: "...")!)
            .retry(3)       // Try pu to 3 times on failure.
            .map(\.data)
            .decode(type: UserSubject.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
            .store(in: &cancellable)
    }
    
    func normalizeWithRetryIf() {
        URLSession.shared.dataTaskPublisher(for: URL(string: "...")!)
            .tryMap { output -> Data in
                // Check the HTTP response
                guard let response = output.response as? HTTPURLResponse else  {
                    throw URLError(.badServerResponse)
                }
                
                if !(200...299).contains(response.statusCode) {
                    // Throw a custom error so Combine can decide what to do
                    throw HTTPError(statusCode: response.statusCode)
                }
                return output.data
            }
            .retryIf(maxRetries: 3) { error in
                // Only retry if NOT a 404 error
                if let httpError = error as? HTTPError {
                    return httpError.statusCode != 404
                }
                // Retry for all non-HTTP errors (e.g. network issues)
                return true
            }
            .decode(type: UserSubject.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { print($0) })
            .store(in: &cancellable)
            
            
    }
    
    
    //🔷 Provide Fallbacks with catch :
    // Catch intercepts an error and switches to another publisher - Keeping the stream alive.
    func normalizeWithCatch() {
        let pipeline = fetchUser()
            .catch { error in
                Just("Publisher Failed with error")     // fallback to guest user
            }
            .sink { value in
                print(value)
            }

        pipeline.store(in: &cancellable)
    }
    
    func fetchUser() -> PassthroughSubject<String, Error> {
        let publisher = PassthroughSubject<String, Error>()
        
        // Simulate async behavior (e.g. network failure after delay)
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("Sending failure...")
            publisher.send(completion: .failure(AppError.other("error occured")))
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            publisher.send(completion: .failure(AppError.other("error occured")))
        }
        
        return publisher
    }
    
    
    //🔵 Replace Errors with a value: replaceError
    // When you don't need the error at all,just provide a value and make the stream non-failing.
    func normalizeWithReplaceError() {
        let publisher = PassthroughSubject<[String], AppError>()
        
        publisher
            .replaceError(with: [])
            .sink { print("render \($0)") }
            .store(in: &cancellable)
        
        publisher.send(completion: .failure(.other("Failed to get data!")))
            
    }
    
    //🔵 Bridge Non-Failing Stream
    // Some operators require a failing upstream. Use this to add a failure type to a Never stream.
    func normalizeSetFailureType() {
        Just("OK")
            .setFailureType(to: AppError.self)
            .map { $0 }
            .sink { error in
                switch error {
                case .finished:
                    print("Finished")
                case .failure(let err):
                    print("Falied with error: \(err)")
                }
            } receiveValue: { value in
                print(value)
            }
            .store(in: &cancellable)
    }
    
    
    // 🔵 Throw from Transformation: tryMap
    // Use try variants when your trnasform can throw.
    func throwUsingTryMap() {
        let dateFormatter = ISO8601DateFormatter()
        
        ["2024-05-01T10:00:00Z", "bad-date"].publisher
            .tryMap { str -> Date in
                guard let date = dateFormatter.date(from: str) else {
                    throw AppError.other(NSError(domain: "Date", code: 1) as! String)
                }
                return date
            }
            .mapError { $0 as? AppError ?? .other("Error") }
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { print($0) }
            )
            .store(in: &cancellable)
    }
    
    // 🔵 Development Helpers: assertNoFailure
    // Great in debug builds when failure would be a programming error.
    func normalizeWithAssert() {
        Just(1)
            .assertNoFailure()  // Raises a fatal error when upstream publisher fails, otherwise republish all received input.
            .sink { print($0) }
            .store(in: &cancellable)
    }
}

// 🔷Production Recipe: Resilient Network Pipeline
// A pragmatic pattern you can reuse.
/**
 import Combine

 enum APIError: Error {
     case network(URLError)
     case http(Int)            // non-2xx status
     case decoding(DecodingError)
     case other(Error)
 }

 struct User: Decodable { let id: Int; let name: String }

 func request(_ url: URL) -> AnyPublisher<Data, APIError> {
     URLSession.shared.dataTaskPublisher(for: url)
         .mapError { APIError.network($0) }
         .tryMap { output -> Data in
             guard let response = output.response as? HTTPURLResponse else {
                 return output.data
             }
             guard (200..<300).contains(response.statusCode) else {
                 throw APIError.http(response.statusCode)
             }
             return output.data
         }
         .mapError { $0 as? APIError ?? .other($0) }
         .retry(2) // transient failures
         .eraseToAnyPublisher()
 }

 func fetchUser(id: Int) -> AnyPublisher<User, APIError> {
     let url = URL(string: "https://example.com/users/\(id)")!
     return request(url)
         .decode(type: User.self, decoder: JSONDecoder())
         .mapError { $0 as? APIError ?? .decoding($0 as! DecodingError) }
         .catch { error -> AnyPublisher<User, APIError> in
             switch error {
             case .http(404):
                 // Map 404 to a domain-specific empty value
                 return Just(User(id: -1, name: "Guest"))
                     .setFailureType(to: APIError.self)
                     .eraseToAnyPublisher()
             default:
                 return Fail(error: error).eraseToAnyPublisher()
             }
         }
         .eraseToAnyPublisher()
 }

 // Usage
 var cancellables = Set<AnyCancellable>()

 fetchUser(id: 1)
     .sink(
         receiveCompletion: { print("Completion: \($0)") },
         receiveValue: { user in print("User:", user) }
     )
     .store(in: &cancellables)
 */

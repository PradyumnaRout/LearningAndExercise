//
//  URLSessionMethods.swift
//  LearningAndExercise
//
//  Created by hb on 24/11/25.
//

import Foundation
import UIKit
import Combine

struct MyResponse: Codable {
    let id: Int
    let name: String
}

// Common HTTP Errors
enum HTTPErrors: LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Response is not HTTPURLResponse."
        case .statusCode(let code): return "Server returned status code \(code)."
        case .noData: return "No data in response."
        case .decodingError(let err): return "Decoding failed: \(err.localizedDescription)"
        }
    }
}

/// Simple Function to download an image
class DownloadManager {
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            /// data : Raw data returned form the server
            /// response: Metadata about response (HTTP status code, headers, etc)
            /// error: Error if something failed.
            
            if let data = data, error == nil {
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    
    // Usage:
    func download() {
        downloadImage(from: "https://example.com/image.jpg") { image in
            if let downloadImage = image {
                // Assign the image to the image View
            } else {
                print("Failed to download image.")
            }
        }
    }
}

// MARK: - URLSession.shared.dataTask
class DataTaskVariant {
//    let dataTask1 = URLSession.shared.dataTask(with: <#T##URLRequest#>)
//    let dataTask2 = URLSession.shared.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, (any Error)?) -> Void#>)
    
    func dataTask1() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://example.com/image.jpg")!)
        
        /// ➡️ This creates the task object only
        /// It does not start the request and there is no completion request yet.
        /// You must later call the resume() and handle the response using the delegate.
        
        task.resume()
        
        /*
         Use cases:
         🔹 When using a URLSession delegate to handle responses
         🔹 When you want to configure the task before starting it (priority, etc.)
         */
    }
    
    func dataTask2() {
        URLSession.shared.dataTask(with: URL(string: "https://example.com/image.jpg")!) { data, response, error in
            
            /// ➡️ This creates the task AND gives you the response right there in the closure.
            /**
             Use cases:

             🔹 Quick network requests
             🔹 Downloading JSON/images without needing delegates
             */
        }.resume()
    }
    
    func handleDecodeData() {
        guard let url = URL(string: "https://example.com/image.jpg") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Handle Networking error
            if let error = error {
                print("Networking error: ", error.localizedDescription)
                return
            }
            
            // Validate HTTP Response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response object")
                return
            }
            
            // Handle status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error - status code: ", httpResponse.statusCode)
                return
            }
            
            // Validate Data exists
            guard let data = data else {
                print("No data returned")
                return
            }
            
            // Decode Json
            do {
                let decoded = try JSONDecoder().decode(String.self, from: data)
                
                // Upload UI on main thread
                DispatchQueue.main.async {
                    print("✅ Success:", decoded)
                }
            } catch {
                print("Jons decode error: ", error)
            }
        }
    }
}


// MARK: - URLSession.shared.data

class AsyncAwaitData {
//    let task1 = URLSession.shared.data(from: <#T##URL#>)
//    let task2 = URLSession.shared.data(for: <#T##URLRequest#>)
//    let task3 = URLSession.shared.data(for: <#T##URLRequest#>, delegate: <#T##(any URLSessionTaskDelegate)?#>)
    
    
    // Only GET.
    func task1() async {
        do {
            let (data, response) = try await URLSession.shared.data(from: URL(string: "https://example.com/image.jpg")!)
        } catch {
            print("Error: ", error.localizedDescription)
        }
        
        /**
         ➡️ What it does:
         
         🔹 Sends a simple GET request
         🔹 Automatically creates a URLRequest for you.
         🔹 Returns Data + URLResponse
         🔹 No delegate Support
         
         ➡️ Best for:
         
         🔹 Simple GET request
         🔹 Downloading json / images quickly
         🔹 No custom headers / body
         */
    }
    
    func task2() async {
        
        let url = URL(string: "https://example.com/image.jpg")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
        } catch {
            print("Error: ", error.localizedDescription)
        }
        
        /**
         ➡️ What it does:
         
         🔹 Allows any HTTP method(GET, POST, PUT, DELETE)
         🔹 Supports custom headers, request body, authorization, etc.
         🔹 still no delegate support by default.
         
         ➡️ Best for
         
         🔹 API calls with JSON body
         🔹 Authenticated requests
         🔹 Custom HTTP configuration
         */
    }
    
    func task3() async {
        let url = URL(string: "https://example.com/image.jpg")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest, delegate: nil)
        } catch {
            print("Error: ", error.localizedDescription)
        }
        
        /**
         ➡️ What it does:
         
         🔹 Same as taks2 but allows URLSessionTaskDelegate
         🔹 Gives you fine-grained control
         🔹 Authentication Challenges
         🔹 Handling redirects
         🔹 Background Tasks
         
         ➡️ Best For
         🔹 Progress Tracking (File uploads / downloads)
         🔹 Certificate pinning / authentication
         🔹 Background downloads.
         */
    }
    
    /*
     🧠 Easy Rule of Thumb

     🔹 If your request uses only a URL → .data(from:)
     🔹 If your request is a real API call → .data(for: request)
     🔹 If you need progress/auth/redirect handling → .data(for: request, delegate:)
     */
    
    
    // MARK: - Async / Await version Of API Call
    func fetchMyResponseAsync(from urlString: String) async throws -> MyResponse {
        guard let url = URL(string: urlString) else {
            throw HTTPErrors.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPErrors.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPErrors.statusCode(httpResponse.statusCode)
        }
        
        // Ensure there is data
        guard data.count > 0 else {
            throw HTTPErrors.noData
        }
        
        // Decode
        do {
            let decoded = try JSONDecoder().decode(MyResponse.self, from: data)
            return decoded
        } catch {
            throw HTTPErrors.decodingError(error)
        }
    }
        
}


// MARK: - let dataTask2 = URLSession.shared.dataTaskPublisher(for: <#T##URL#>)
class DataTaskPublisher {
    var cancellable: AnyCancellable?
    
    func fetchMyResponsePublisher(form urlString: String) -> AnyPublisher<MyResponse, Error> {
        guard let url = URL(string: urlString) else {
            // Immediately return a failing publisher for invalid URL
            return Fail(error: HTTPErrors.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw HTTPErrors.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw HTTPErrors.statusCode(httpResponse.statusCode)
                }
                
                guard output.data.count > 0 else {
                    throw HTTPErrors.noData
                }
                
                return output.data
            }
            .decode(type: MyResponse.self, decoder: JSONDecoder())
            // If you want to deliver results on the main thread (UI updates), add receive(on:)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func exampleCombineUsage() {
        fetchMyResponsePublisher(form: "https://example.com/api/data")
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ Publisher finished.")
                case .failure(let error):
                    print("❌ Publisher error:", error.localizedDescription)
                }
            } receiveValue: { response in
                print("📥 Combine response:", response)
            }
    }
    
    // When you want to cancel:
    func cancelRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}



// MARK: - Difference between URL and URLRequest :
/*
 ✅ When a method takes a URL
 
 URLSession.shared.data(from: url):
 • It always perform a get request
 • You can not change the mehtod, add headers, or send body data.
 
 ✅ When the method takes URLRequest
 
 URLSession.shared.data(for: request):
 • You can send any HTTP method: GET, POST, PUT, DELETE, PATCH, etc.
 • You can add headers, authorization tokens, a JSON body / HTTP Body, etc.
 
 example:
 var request = URLRequest(url: url)
 request.httpMethod = "POST"
 request.setValue("application/josn", forHTTPHeaderField: "Content-Type")
 request.httpBody = jsonData
 
 let (data, resposne) = try await URLSession.shared.data(for: reqeust)
 
 🔷 URL → GET request
 🔷 URLRequest → any kind of request
 */


// MARK: - 🚀 Ways to pass data in an API Call
class WaysOfDataPassinAPI {
    // 1️⃣ Query Parameters (URL Params)
    // Data is append to the URL - Typically used with GET requests
    // example: https://api.example.com/search?query=apple&page=2
    
    /*
     🔍 Format
     ?key=value

     If it had multiple values:
     api/user/user-list?id=18&page=2&limit=20
     */
    
    func asQueryParams() {
        var components = URLComponents(string: "https://api.example.com/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: "apple"),
            URLQueryItem(name: "page", value: "2")
        ]
        
        let url = components.url!
    }
    
    // 2️⃣ HTTP Body (It always takes Data) (not visible in url)
    // Best for POST, PUT, PATCH etc
    /**
     You can send different formats:
     
     🔹 JSON Body - Most commom for REST APIs
     let jsonData = try JSONEncoder().encode(myModel)
     request.httpBody = jsonData
     request.setValue("application/json", forHTTPHeaderField: "Content-Tyep")
     
     📌 What happens here:

     🔹 JSONEncoder().encode() → Converts model → raw JSON Data
     🔹 Data is placed in httpBody
     🔹 Headers tell server it's application/json
     
     Header:
     Content-Type: application/json

     Body looks like this:
     {
       "name": "John Doe",
       "age": 25,
       "title": "iOS Developer"
     }

     ✔ Proper JSON format
     ✔ Much easier to read
     ✔ Supports nested objects
     
     
     `🧠 If API requires a raw String:
     let jsonString = String(data: jsonData, encoding: .utf8)!
     request.httpBody = jsonString.data(using: .utf8)
     
     
     🔹 Form Data(URL-encoded)
     let bodyString = "username=john&password=123"
     request.httpBody = bodyString.data(using: .utf8)
     request.setValue("application/x.www-form-urlencoded", forHTTPHeaderField: "Contnet-Type")
     
     Header:
     Content-Type: application/x-www-form-urlencoded

     Body looks like this:
     name=John%20Doe&age=25&title=iOS%20Developer

     or readable:
     name=John Doe&age=25&title=iOS Developer

     ✔ Key=value pairs
     ✔ Joined by &
     ✔ Spaces and special characters are percent encoded
     
     
     🔹 Multipart Form Data (Used for file uploads, Image, video, etc)
     request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
     
     
     🔹 Headers - Used to send metadata or auth info with a request
     
     Examples:

     Authorization (JWT, Bearer token)
     Content-Type
     Custom keys
     
     request.setValue("Bearer TOKEN_HERE", forHTTPHeaderField: "Authorization")
     
     4️⃣ Path Parameters

     Embedded directly inside the URL path.

     Example:
     https://api.example.com/users/12345/profile

     Used to reference a specific resource.

     5️⃣ Cookies
     Sometimes servers rely on cookies for auth/state.
     (Swift manages them automatically unless disabled.)

     6️⃣ Upload Streams / Binary Data
     When uploading large files or streaming live uploads.
     
     URLSession.shared.uploadTask(with: request, fromFile: fileURL)
     
     
     
     `✅ URL Encoding vs JSON Encoding`

     They both send data in the HTTP body, but the formatting is completely different.

     📌 1️⃣ URL Encoding (aka Form URL Encoded)
     Header:
     Content-Type: application/x-www-form-urlencoded

     Body looks like this:
     name=John%20Doe&age=25&title=iOS%20Developer


     or readable:

     name=John Doe&age=25&title=iOS Developer


     ✔ Key=value pairs
     ✔ Joined by &
     ✔ Spaces and special characters are percent encoded

     Swift Example:
     URLComponents or URLEncoding.httpBody

     📌 2️⃣ JSON Encoding
     Header:
     Content-Type: application/json

     Body looks like this:
     {
       "name": "John Doe",
       "age": 25,
       "title": "iOS Developer"
     }


     ✔ Proper JSON format
     ✔ Much easier to read
     ✔ Supports nested objects

     Swift Example:
     let body = try JSONEncoder().encode(model)
     request.httpBody = body

     
     
     📌 Quick Summary Table
     | Method                  | HTTP Methods   | What it’s used for          |
     | ----------------------- | -------------- | --------------------------- |
     | Query Params            | GET (mostly)   | Filters, search, pagination |
     | Body - JSON             | POST/PUT/PATCH | Common APIs                 |
     | Body - Form URL-encoded | POST           | Login/older servers         |
     | Body - Multipart        | POST           | File uploads                |
     | Headers                 | All            | Auth, content type          |
     | Path Params             | All            | Identify resource           |
     | Cookies                 | All            | Sessions, auth              |

     */
}


// MARK: - 🔥 JSONSerialization vs JSONDecoder

/*
 | Feature        | `JSONSerialization`             | `JSONDecoder`                                 |
 | -------------- | ------------------------------- | --------------------------------------------- |
 | Output type    | **Any** (Dictionary / Array)    | **Swift model** (strongly typed struct/class) |
 | Works with     | Older Foundation API            | Modern Codable system                         |
 | Type-safety    | ❌ No (you must cast manually)   | ✅ Yes (model defines structure)               |
 | Runtime safety | ❌ Crashes possible when casting | ✔ Compile-time checks                         |
 | Best for       | Quick inspection / dynamic JSON | Real API model parsing                        |
 | Introduced     | iOS 5 era                       | iOS 11 (Codable)                              |

 
 🧠 Easy rule to remember

 JSONSerialization → dictionary world
 JSONDecoder → strongly typed Swift model wor
 */

// MARK: - Codable

struct Model: Codable {
    let id: Int?
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case name = "full_name"
        case email = "email_address"
    }
    
    // Decode (JSON -> Model)
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }
    
    // Encode (User -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}


// MARK: - Handling a runtime-changing id (Int or String)
/**
 You have two practical ways to handle id that sometimes comes as an Int and sometimes as a String.

 Normalize to String — simplest: decode either Int or String into a String property. Good when you only need an identifier as text.

 Preserve the original type — more robust: model id as an enum (or custom type) that stores whether it was an Int or String, and encode back using the original representation.

 Both examples below implement Codable manually with CodingKeys as you requested.
 
 `Option A — Normalize id to String (simple)`
 import Foundation

 struct User: Codable {
     let id: String        // always a String at runtime
     let name: String
     let email: String

     enum CodingKeys: String, CodingKey {
         case id = "user_id"
         case name = "full_name"
         case email = "email_address"
     }

     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         // Try Int first, then String
         if let intId = try? container.decode(Int.self, forKey: .id) {
             id = String(intId)
         } else if let strId = try? container.decode(String.self, forKey: .id) {
             id = strId
         } else {
             // If the id is missing or null, you can throw or assign default
             throw DecodingError.dataCorruptedError(forKey: .id,
                 in: container,
                 debugDescription: "user_id is neither Int nor String")
         }

         name  = try container.decode(String.self, forKey: .name)
         email = try container.decode(String.self, forKey: .email)
     }

     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         // Always encode as a String
         try container.encode(id, forKey: .id)
         try container.encode(name, forKey: .name)
         try container.encode(email, forKey: .email)
     }
 }


 Usage: decode will always give you id as String. Encoding writes user_id as a JSON string.

 `Option B — Preserve original type (Int or String) — recommended when you need fidelity`
 import Foundation

 enum IDValue: Codable, Equatable {
     case int(Int)
     case string(String)

     // Helper accessors
     var asString: String {
         switch self {
         case .int(let i): return String(i)
         case .string(let s): return s
         }
     }
     var asInt: Int? {
         switch self {
         case .int(let i): return i
         case .string(let s): return Int(s)
         }
     }

     init(from decoder: Decoder) throws {
         let container = try decoder.singleValueContainer()
         if let intVal = try? container.decode(Int.self) {
             self = .int(intVal)
             return
         }
         if let strVal = try? container.decode(String.self) {
             self = .string(strVal)
             return
         }
         throw DecodingError.dataCorruptedError(in: container,
                                                debugDescription: "IDValue cannot be decoded")
     }

     func encode(to encoder: Encoder) throws {
         var container = encoder.singleValueContainer()
         switch self {
         case .int(let i): try container.encode(i)
         case .string(let s): try container.encode(s)
         }
     }
 }

 struct User: Codable, Equatable {
     let id: IDValue
     let name: String
     let email: String

     enum CodingKeys: String, CodingKey {
         case id = "user_id"
         case name = "full_name"
         case email = "email_address"
     }

     init(id: IDValue, name: String, email: String) {
         self.id = id
         self.name = name
         self.email = email
     }

     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         // Decode using IDValue which already handles int or string
         id = try container.decode(IDValue.self, forKey: .id)
         name  = try container.decode(String.self, forKey: .name)
         email = try container.decode(String.self, forKey: .email)
     }

     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(id,    forKey: .id)
         try container.encode(name,  forKey: .name)
         try container.encode(email, forKey: .email)
     }
 }
 */

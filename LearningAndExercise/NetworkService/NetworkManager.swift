//
//  NetworkManager.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation
import UIKit

class NetworkManager {
    
    // Shared Instance
    static let shared = NetworkManager()
    
    // Initializer
    private init() {}
    
    // Request Data
    static func dataRequest<T: Decodable>(with url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        // Handle Error
        try shared.handleURLResponse(output: (data, response))
        
        do  {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            debugPrint(decodedData)
            return decodedData
        } catch let error {
            throw NetworkError.mapError(error)
        }
    }
    
    // Image Download Using async await.
    static func downloadImage(withUrl: String) async throws -> UIImage? {
        let url = URL(string: withUrl)!
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return shared.handleResponse(data: data, response: response)
        } catch {
            throw NetworkError.invalidResponse
        }
    }
    
    private func handleURLResponse(output: (data: Data, response: URLResponse)) throws {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        try NetworkError.throwNetworkError(statusCode: httpResponse.statusCode, data: output.data)
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data), let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }

}

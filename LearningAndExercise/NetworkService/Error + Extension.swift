//
//  Error + Extension.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    
    // MARK: - Client Error: 400...499
    case clientError(statusCode: Int)
    // MARK: - Parsing Error
    case parsingError(error: Error)
    case requestError(errorMessage: String)
    // MARK: - Common network cases
    case badURL
    case badRequest(statusCode: Int)
    case requestFailed(error: Error)
    case invalidResponse
    case noInternetConnection
    case timeout
    // MARK: - Server Error: 500...599
    case serverError(statusCode: Int, data: Data?)
    case unauthorized
    case forbidden
    case notFound
    case decodingError(error: Error)
    case unknown(statusCode: Int?, error: Error)
    
    
    // MARK: - Custom error description
    var errorDescription: String? {
        switch self {
        case .clientError(let statusCode):
            return "Client error. Status code: \(statusCode)"
        case .parsingError(let error):
            return "Erorr in parsing.\(error.localizedDescription)"
        case .requestError(let errorMessage):
            return errorMessage
        case .badURL:
            return "The URL provided was invalid."
        case .badRequest(let statusCode):
            return "The request provided was bad. Status code: \(statusCode)"
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from the server."
        case .noInternetConnection:
            return "No internet connection."
        case .timeout:
            return "The request timed out."
        case .serverError(let statusCode, _):
            return "Server error with status code: \(statusCode)"
        case .unauthorized:
            return "Unauthorized access. Please login again."
        case .forbidden:
            return "Forbidden access to this resource."
        case .notFound:
            return "The requested resource was not found."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unknown(_, let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    static func throwNetworkError(statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200..<299:
            // Success
            break
        case 400:
            throw NetworkError.badRequest(statusCode: statusCode)
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: statusCode, data: data)
        default:
            throw NetworkError.serverError(statusCode: statusCode, data: data)
        }
    }
    
    static func mapError(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                return .requestFailed(error: urlError)
            }
        } else if let decodingError = error as? DecodingError {
            return .decodingError(error: decodingError)
        } else {
            return .unknown(statusCode: nil, error: error)
        }
    }
}

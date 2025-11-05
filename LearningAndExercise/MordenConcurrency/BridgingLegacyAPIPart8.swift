//
//  BridgingLegacyAPIPart8.swift
//  LearningAndExercise
//
//  Created by hb on 05/11/25.
//

import Foundation

// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-8-mixing-old-and-new-bridging-legacy-apis-3689d06ea72c
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-9-advanced-concurrency-patterns-fa495adf68db  (Must watch for INTV)
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-10-applying-modern-concurrency-in-a-real-project-392861e37632

// MARK: - Mixing Old and New (Bridging Legacy APIs)

// 🔹 What Are Continuations?
/*
 A continuation is a way to pause async code until a callback is called.
 
 Think of it as:
 Hay Swift I am going to wait here. When the old callback finishes, resume me with the result.
 
 There are two main types:
 1. WithCheckedContinuation ✅
     • Safe, runtime checks ensure you resume exactly once.
     • Recommended for most use cases.
 2. WithUnsafeContinuation ⚠️
     • Low-level, faster, no safety checks.
     • Use only when performance is critical and you guarantee correct usage.
 */


class BridgingLegacyAPI {
    // 🔷 Bridging Completion Handler APIs
    
    func fetchData(completion: @escaping (Result<String, Never>) -> Void) {}
    
    // To bridge in into async await
    // A continuation must be resumed exactly once. If the continuation has already been resumed through this object, then the attempt to resume the continuation will trap.
    // Forgetting to resume → your async code hangs indefinitely.
    func fetchDataAsync() async throws -> String {
        try await withCheckedContinuation { continuation in
            fetchData { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func useFetchDataAsync() {
        Task {
            do {
                let data = try await fetchDataAsync()
                print("Data:", data)
            } catch {
                print("Error:", error)
            }
        }
    }
}

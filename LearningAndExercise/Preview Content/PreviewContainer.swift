//
//  PreviewContainer.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import Foundation
import SwiftData

struct Preview {
    let continer: ModelContainer
    
    init(_ models: any PersistentModel.Type...) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(models)
        do {
            continer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create preview container.")
        }
    }
    
    func addExamples(_ examples: [any PersistentModel]) {
        Task { @MainActor in
            examples.forEach { example in
                continer.mainContext.insert(example)
            }
        }
    }
}

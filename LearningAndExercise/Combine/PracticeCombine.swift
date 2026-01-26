//
//  PracticeCombine.swift
//  LearningAndExercise
//
//  Created by Rahul Kiumar on 24/01/26.
//

import SwiftUI

struct PracticeCombine: View {
    let obj = CombineOperations()
    var body: some View {
        VStack(spacing: 20) {
            Text("Hay Combine")
                .font(.title)
                .fontWeight(.bold)
            
            Button("Execute") {
                obj.operations()
            }
            .buttonStyle(.borderedProminent)
        }
            
    }
}

#Preview {
    PracticeCombine()
}

import Combine

class CombineOperations {
    var cancellable = Set<AnyCancellable>()
    
    let publisher1 = PassthroughSubject<Int, NetworkError>()
    let publisher2 = PassthroughSubject<Int, NetworkError>()
    
    func operations() {
        foo()
    }
    
    func foo() {
        
    }
}



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
    
    func operations() {
        foo()
    }
    
    let subject = CurrentValueSubject<Int, Never>(0)
    func foo() {
        let publisher = [10,20,30,40,50,60].publisher
        
        let filterPublisher = [10, 20, 30, 40, 50, 60].publisher
            .map { $0 * 1 }
        
        let subscriber = IntSubscriber()
        
        filterPublisher.subscribe(subscriber)
    }
    
}



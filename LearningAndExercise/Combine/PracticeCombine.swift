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
        let firstPublisher = PassthroughSubject<String, NetworkError>()
        let secondPublisher = PassthroughSubject<String, NetworkError>()
        
        firstPublisher
            .zip(secondPublisher)
            .sink { status in
                switch status {
                case .finished:
                    print("Task Finished")
                case .failure(let error):
                    print("Error occured: \(error.localizedDescription)")
                }
            } receiveValue: { (value1, value2) in
                print("Value1: \(value1), and Value2: \(value2)")
            }
            .store(in: &cancellable)

        firstPublisher.send("Hello")
        firstPublisher.send("How you doing")
        secondPublisher.send("Guys")
        secondPublisher.send("Any problem")
        firstPublisher.send("100")
        secondPublisher.send(completion: .failure(.badURL))
        secondPublisher.send("No problem")

    }
}



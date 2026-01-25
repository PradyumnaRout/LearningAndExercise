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
        let publisher = PassthroughSubject<Int, Never>()

        // MARK: Execution: 1
        /*
        publisher
            .collect(.byTimeOrCount(DispatchQueue.main, .seconds(4), 2))
            .sink(receiveValue: {
                print("all values as array: \($0)")
            })
            .store(in: &cancellable)
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        
        /*
         Output -
         all values as array: [1, 2]
         // After four second if it did not get second value, it will return the single value.
         all values as array: [3]
         
         
         In Execution One first [1, 2] collection will print immediately, as it is getting it properly. But in the case of 3, it will wait for four second for the second value to pair with 3, to make another collection with 3. SO Second time it will wait for 4 second and if it won't get any value, it will return only [3]
         */
         */
        
        // MARK: Execution: 2
        /*
        publisher
            .collect(.byTimeOrCount(DispatchQueue.main, .seconds(4), 1))
            .sink(receiveValue: {
                print("all values as array: \($0)")
            })
            .store(in: &cancellable)
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        
        /*
         Output -
         all values as array: [1]
         all values as array: [2]
         all values as array: [3]
         
         In second execution it will print all the vlaues immediately, as the value require to make an collection here is only one. And it is getting it immediately. So Here it will not wait for four second
         */
         
         */
        
        // MARK: Execution: 3
        /*
        publisher
            .collect(.byTime(DispatchQueue.main, .seconds(4)))
            .sink(receiveValue: {
                print("all values as array: \($0)")
            })
            .store(in: &cancellable)
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        
        /*
         Output -
         Wait for 4 seconds
         all values as array: [1, 2, 3]
         
         🧠 Here as we don't mention any collection limit, so it will wait for 4 second and then print all the collection values send by the publisher with in 4 second.
         */
         
         */
        
        // MARK: Execution: 4
        /*
        publisher1
            .collect(2)
            .sink(receiveCompletion: { completion in
                print("Complete with : \(completion)")
            }, receiveValue: { collection in
                print("all values as array: \(collection)")
            })
            .store(in: &cancellable)
        
        publisher1.send(1)
        publisher1.send(2)
        publisher1.send(3)
        
//        publisher1.send(completion: .finished)
        publisher1.send(completion: .failure(.badURL))
        
        /*
         Output -
         all values as array: [1, 2]
         all values as array: [3]
         
         
         Here as we mention to collect collection of two elements, the first time it get two elemetn it will return [1, 2]
         
         Then it will not receive 3 untill you send the completion with success, because it will still wait for the second value to complete the collection.
         Now if you comment the completion with success line [3] will never print.
         
         But if you send a completion with error, then it will never return [3] and which is also correct.
         */
         
         */
        
        // MARK: Execution: 5
        publisher1
            .collect()
            .sink(receiveCompletion: { completion in
                print("Complete with : \(completion)")
            }, receiveValue: { collection in
                print("all values as array: \(collection)")
            })
            .store(in: &cancellable)
        
        publisher1.send(1)
        publisher1.send(2)
        publisher1.send(3)
        
//        publisher1.send(completion: .finished)
        publisher1.send(completion: .failure(.badURL))
        
        /*
         Output -
         Case 1:
         If you do not send any completion it won't print anything
         
         Case 2: IN case of Completion with success
         all values as array: [1, 2, 3]
         Complete with : finished
         
         case 3: IN case of completion with failure. (It breaks the stream)
         Complete with : failure(LearningAndExercise.NetworkError.badURL)
         
         */
    }
}



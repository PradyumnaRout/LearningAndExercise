//
//  AnyPublisher.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import Foundation
/**
 how to send a value in anypublisher
 
 AnyPublisher” usually refers to Swift’s Combine framework.
 If that’s what you mean, the key idea is:

 You don’t send values to an AnyPublisher directly.
 You send values through a Subject, and expose it as an AnyPublisher.

 ✅ The correct pattern (Swift Combine)
 1. Create a Subject

 Subjects can send values.

 import Combine

 let subject = PassthroughSubject<Int, Never>()


 or (if you need an initial value):

 let subject = CurrentValueSubject<Int, Never>(0)

 2. Expose it as AnyPublisher

 This hides the ability to send values from outside.

 let publisher: AnyPublisher<Int, Never> =
     subject.eraseToAnyPublisher()

 3. Send values

 You send values through the subject, not the AnyPublisher.

 subject.send(42)
 subject.send(100)

 4. Subscribe to the AnyPublisher
 let cancellable = publisher.sink { value in
     print("Received:", value)
 }

 🔒 Why this pattern is used

 • AnyPublisher = read-only
 • Subject = write + read
 • This keeps your API clean and safe

 Example in a ViewModel:

 class ViewModel {
     private let subject = PassthroughSubject<String, Never>()

     var publisher: AnyPublisher<String, Never> {
         subject.eraseToAnyPublisher()
     }

     func sendMessage(_ message: String) {
         subject.send(message)
     }
 }

 ❌ Common mistake
 let publisher: AnyPublisher<Int, Never>
 // ❌ You cannot call publisher.send(...)


 AnyPublisher has no send() method by design.
 */

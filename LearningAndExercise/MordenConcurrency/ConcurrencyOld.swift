//
//  ConcurrencyOld.swift
//  LearningAndExercise
//
//  Created by hb on 14/11/25.
//

import Foundation


// MARK: - Global Concurrent Queue (System Provided)

class GlobalConcurentQueueExperiment {
    
    /// Assigning task to multiple Global Queue with different Quality Of Service, And let's see which one's execution complete first
    func testMultipleQOS() {
        // QOS - background
        DispatchQueue.global(qos: .background).sync {
            for i in 11...20 {
                print(i)
            }
        }
        
        // QOS - userInteractive
        DispatchQueue.global(qos: .userInteractive).sync {
            for i in 1...10 {
                print(i)
            }
        }
    }
    /*
     Keypoints -
     🔹The two dispatch queues in the above function is async in nature, so the first queue will not stop the execution untill it finishes its own, so the second queue can start execution simultaneously with the first one but as overall it is a queue its execution will start after the first one.
     🔹So it is not possible to predict the actual output as it is an async, that means "1" can print first some times and sometimes "11"
     🔹So what is the work of quality of service here - So while printing all those values the execution of the second queue will complete first in most of the cases, not in every cases, "sometimes first queue completes first". But Most of the cases second queue will completes its execution before the first queue. Because qos of the second queue is userInitiative which has a greater priority that background queue.
     🔹So quality of service do not help to complete the task before others always but in most of the cases.
     
     🔹If you user sync in the above case then the output is so predictable because it will block the execution of second queue untill the completion of the first one.
     */
    
    func testMultipleQOS2() {
        // QOS - background
        DispatchQueue.global(qos: .background).async {
            for i in 11...20 {
                print(i)
            }
        }
        
        // QOS - userInteractive
        DispatchQueue.global(qos: .userInteractive).async {
            for i in 1...10 {
                print(i)
            }
        }
        
        // QOS - userInteractive
        DispatchQueue.global(qos: .utility).async {
            for i in 21...25 {
                print(i)
            }
        }
    }
    
    
    func testMultipleQOS3() {
        // QOS - background
        DispatchQueue.global(qos: .background).async {
            for i in 11...20 {
                print(i)
            }
        }
        
        DispatchQueue.main.async {
            for i in 21...25 {
                print(i)
            }
        }
        
        // QOS - userInteractive
        DispatchQueue.global(qos: .userInteractive).async {
            for i in 1...10 {
                print(i)
            }
        }
        
        /**
         Output1 - 1, 11, 2, 3, 4, 5, 12, 6, 13, 14, 15, 16, 17, 18, 19, 20, 7, 8, 9, 10, 21, 22, 23, 24, 25
         output2 - 1, 11, 12, 13, 2, 14, 3, 15, 4, 16, 5, 17, 6, 18, 7, 19, 8, 20, 9, 10, 21, 22, 23, 24, 25
         output3 - 1, 11, 2, 12, 3, 4, 13, 14, 5, 15, 16, 6, 17, 7, 8, 18, 9, 19, 10, 20, 21, 22, 23, 24, 25
         output4 - 1, 11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
         output5 - 11, 1, 12, 2, 13, 3, 14, 4, 15, 16, 5, 17, 6, 18, 7, 19, 8, 20, 9, 10, 21, 22, 23, 24, 25
         output6 - 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22, 23, 24, 25, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
         output7 - 11, 1, 12, 2, 13, 14, 3, 15, 4, 16, 5, 17, 6, 18, 7, 19, 8, 9, 20, 10, 21, 22, 23, 24, 25
         output8 - 1, 11, 2, 12, 3, 4, 5, 13, 14, 6, 7, 15, 8, 16, 9, 17, 10, 18, 19, 20, 21, 22, 23, 24, 25
         
         Here above are some outputs I've checked by running the function multiple time and from that We can say that we can not predict the output and also which one will complete first. But most of the time the global queue will complete first than main queue. and again in global queue that depends upon QOS. That is actually depends upon the resources available in the system.
         */
    }
    
}



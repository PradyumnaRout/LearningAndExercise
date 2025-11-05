//
//  DeadLock.swift
//  LearningAndExercise
//
//  Created by hb on 03/11/25.
//

import Foundation
/// 🔷 `two threads (queues) are waiting for each other to release a lock — which causes a deadlock.
class DeadLockExample {
    private let queue1 = DispatchQueue(label: "com.example.queue1")
    private let queue2 = DispatchQueue(label: "com.example.queue2")
    
    func createDeadLock() {
        queue1.async {
            print("Task 1 started!")
            self.queue2.sync {
                print("Task 1 waiting for queue 2")
            }
            print("Task 1 finished")
        }
        
        
        queue2.async {
            print("Task 2 started")
            self.queue1.sync {
                print("Task 2 waiting for quue 2")
            }
            print("Task 2 finished.")
        }
    }
}
/*
 ✅ What happens above?

 ● queue1 asynchronously starts a task and then tries to synchronously execute code on queue2.
 ● At the same time, queue2 asynchronously starts a task and then tries to synchronously execute on queue1.
 ● Each is waiting for the other to finish — deadlock!
 
 ✅ Solution 1: Use async Instead of sync to Prevent Blocking
 */

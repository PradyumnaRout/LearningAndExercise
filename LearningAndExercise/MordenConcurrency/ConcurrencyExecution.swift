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

// MARK: - Target Queue
class TargetQueueBehaviour {
    
    func experiment() {
        // serial queue
        let serialQueue = DispatchQueue.init(label: "com.serial.queue")
        
        // concurrent queue
        let concurrentQueue = DispatchQueue.init(label: "com.concurrent.queue", attributes: .concurrent, autoreleaseFrequency: .inherit, target: serialQueue)
        
        serialQueue.async {
            for i in 0...5 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        concurrentQueue.async {
            for i in 6...10 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        /**
         Output without target queue
         vlaue: 6  🤡
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 7  🤡
         vlaue: 2  🤡
         vlaue: 8  🤡
         vlaue: 3  🤡
         vlaue: 9  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         vlaue: 10  🤡
         
         Output with target queue -
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         vlaue: 6  🤡
         vlaue: 7  🤡
         vlaue: 8  🤡
         vlaue: 9  🤡
         vlaue: 10  🤡
         
         
         As you see if we assing the target queue of a concurrent queue to a serial queue then they will become serial to each other and the execution will happen serially. Because target queue is the queue under the hood where all the execution actually happens.
         */
    }
        
}


//MARK: - DispatchQueue Execution
/**
 1. serial - async
 2. serial - sync
 3. concurrent - sync
 4. concurrent - async
 */

class ConcurrencyExecution {
    /// 1. Serial - Async
    func serialWithAsync() {
        // default - serial Queue
        let customQueue = DispatchQueue(label: "com.serial.async")
        
        for i in 0..<4 {
            customQueue.async {
                if Thread.isMainThread {
                    print("Running in main thread")
                } else {
                    print("Running in some other thread")
                }
            }
        }
        
        print("This is an outside task")
        
        customQueue.async {
            for i in 0...5 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        /**
         output - Running in some other thread
         This is an outside task
         Running in some other thread
         Running in some other thread
         Running in some other thread
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         
         as async does not block the current execution so this is an outside task print in the second place but all the other tasks assigned to the custome queue will execute serially instead of concurrently because the custom queue is a serial queue.
         */
    }
    
    /// 2 - serial - sync
    func serialWithSync() {
        // default - serial Queue
        let customQueue = DispatchQueue(label: "com.serial.sync")
        
        for i in 0..<4 {
            customQueue.sync {
                if Thread.isMainThread {
                    print("Running in main thread")
                } else {
                    print("Running in some other thread")
                }
            }
        }
        
        print("This is an outside task")
        
        customQueue.sync {
            for i in 0...5 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        /**
         Output -
         Running in main thread
         Running in main thread
         Running in main thread
         Running in main thread
         This is an outside task
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         
         As it is a sync way of execution so all the code will execute one by one because sync block the current execution.
         But you notice one thing that it is executing in main thread, As we know only main queue can use main thread. All the other queue like global queue and custom queu use other thread, but here our custom queu is using main thread. This is happening because while using sync, it blocks the execution of any other task, so in that case main thread will be free, so in that cases system may be or may not be use main thread for the execution.
         */
    }
    
    /// 3. concurrent - sync
    func concurrentWithSync() {
        let customQueue = DispatchQueue(label: "com.concurrent.sync", attributes: .concurrent)
        
        
        for i in 0..<4 {
            customQueue.sync {
                if Thread.isMainThread {
                    print("Running in main thread")
                } else {
                    print("Running in some other thread")
                }
            }
        }
        
        print("This is an outside task")
        
        customQueue.sync {
            for i in 0...5 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        /**
         output - Running in main thread
         Running in main thread
         Running in main thread
         Running in main thread
         This is an outside task
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         
         This will give the same output as serial sync. Though it is concurrent queue, but because of sync block the execution will happen one by one.
         */
    }
    
    /// 4. concurrent - async
    func concurrentWithAsync() {
        let customQueue = DispatchQueue(label: "com.concurrent.sync", attributes: .concurrent)
        
        
        for i in 0..<4 {
            customQueue.async {
                if Thread.isMainThread {
                    print("Running in main thread")
                } else {
                    print("Running in some other thread")
                }
            }
        }
        
        print("This is an outside task")
        
        customQueue.async {
            for i in 0...5 {
                print("vlaue: \(i)  🤡")
            }
        }
        
        /**
         Output -
         This is an outside task
         Running in some other thread
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         Running in some other thread
         Running in some other thread
         Running in some other thread
         Running in some other thread
         Running in some other thread
         This is an outside task
         Running in some other thread
         Running in some other thread
         vlaue: 0  🤡
         vlaue: 1  🤡
         vlaue: 2  🤡
         vlaue: 3  🤡
         vlaue: 4  🤡
         vlaue: 5  🤡
         
         
         I have run that two time and both of the time I got some different response because it is concurrent so it uses more resourece to execute and because of async, it will not block the current execution.
         */
    }
}




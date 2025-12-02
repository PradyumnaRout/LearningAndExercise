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



// MARK: - DispatchGroup
// Used to group multiple task together.
class DispatchGroupExecution {
    let dispatchGroup = DispatchGroup()
    let customQueue = DispatchQueue.init(label: "com.concurrent.queue", attributes: .concurrent)
    
    func groupWithNotify() {
        // enter to group
        dispatchGroup.enter()
        customQueue.async {
            if Thread.isMainThread {
                print("Task 1 :: Running in main thread")
            } else {
                print("Task 1 :: Running in other thread")
            }
            
            self.dispatchGroup.leave()
            print("After leaving the task one")
        }
        
        dispatchGroup.enter()
        customQueue.async {
            if Thread.isMainThread {
                print("Task 2 :: Running in main thread")
            } else {
                print("Task 2 :: Running in other thread")
            }
            
            self.dispatchGroup.leave()
            print("After leaving the task Two")
        }
        
        // it manages enter and leave by itself
        customQueue.async(group: dispatchGroup) {
            if Thread.isMainThread {
                print("Task 3 :: Running in main thread")
            } else {
                print("Task 3 :: Running in other thread")
            }

            sleep(UInt32(arc4random_uniform(4)))
            print("After finishing task Three")
        }
        
        // Notify when all tasks are completed
//        dispatchGroup.notify(queue: .main) {
//            print("All tasks are finished. Display the results here.")
//        }
        
        // Wait for the all the task to complete
        // This will block the current thread until all tasks are completed
//        dispatchGroup.wait()
        
        let timeoutResult = dispatchGroup.wait(timeout: .now() + 0.2)
        
        switch timeoutResult {
        case .success:
            print("Success")
        case .timedOut:
            print("Time out")
        }
        
        print("It does not block the current thread")
        
        /**
         output on notify -
         
         It does not block the current thread
         Task 3 :: Running in other thread
         Task 1 :: Running in other thread
         Task 2 :: Running in other thread
         After finishing task Three
         After leaving the task one
         After leaving the task Two
         All tasks are finished. Display the results here.
         
         // output on wait
         Task 1 :: Running in other thread
         Task 2 :: Running in other thread
         Task 3 :: Running in other thread
         After leaving the task Two
         After finishing task Three
         It does not block the current thread
         After leaving the task one  - `(This prints last because as you can see in the code, group is left before it. But one thing we can not predict that it always print at last.)`
         
         output with distpatch timeout result -
         Task 2 :: Running in other thread
         Task 1 :: Running in other thread
         After leaving the task one
         After leaving the task Two
         Task 3 :: Running in other thread
         Time out
         It does not block the current thread
         After finishing task Three
         
         
         The out put will be asynchronous and the last one will execute after the finish of both the task because of the notify and it won't block the current thread because notify itself is asynchronous
         */
        
    }
}



// MARK: - Dispatch Work Item.

class DispatchWorkItemExecution {
    
    func exampleOne() {
        let workItem = DispatchWorkItem {
            print("Work item executing")
        }
        
        let queue = DispatchQueue(label: "com.exampleOne")
        queue.async(execute: workItem)
        
        workItem.cancel()
        
        if workItem.isCancelled {
            print("Work iten has been cancelled.")
        }
    }
    /**
     Here’s what happens step-by-step:

     🔹 You create a DispatchWorkItem
     🔹 You enqueue it on a background queue (async)
     🔹 Immediately after queuing, you call cancel()
     🔹 Then you check isCancelled

     🔍 Important behavior

     🔹 cancel() does NOT stop the block from executing once it’s already queued.
     🔹 It only sets an internal flag (isCancelled = true)
     🔹 The work item still runs unless you explicitly check isCancelled inside the block.

     🧩 Most likely output
     Work item executing
     Work iten has been cancelled.

     Why not guaranteed?
     🔹 Because timing matters. If the queue executed the block before cancellation was set, you could see:

     Work iten has been cancelled.
     Work item executing


     🔹 Or in a very rare timing case—if the program exits too fast—you might see only:
     Work iten has been cancelled.

     🔹 But in normal conditions on a serial queue, it will almost always execute the work and print both lines.
     */
    
    func exampleTwo() {
        var workItem: DispatchWorkItem!
        workItem = DispatchWorkItem {
//            if workItem.isCancelled { return }
//            sleep(UInt32(8))
            print("Work item executing")
        }
        
        let queue = DispatchQueue(label: "com.exampleOne")
//        queue.async(execute: workItem)
        queue.asyncAfter(deadline: .now() + 8, execute: workItem)       // it will enter to the workItem block after 8 seconds
        
        sleep(UInt32(2))
        workItem.cancel()       // cancel() does NOT stop the block from executing once it’s already queued.It only sets an internal flag (isCancelled = true)
        
        if workItem.isCancelled {
            print("Work iten has been cancelled.")
        }
        
        // Notify will call no matter your task exectution completes or cancelled
        workItem.notify(queue: queue) {
            print("Work item execution done")
        }
        
//        workItem.wait()
//        print("After wait")
    }
    /**
     Output -
     Work iten has been cancelled.
     Work item executing
     Work item execution done
     
     🔷 we will get this output everytime, because we are cancelling task after two section of it started, so     the task is actually not cancelled, only the isCalcelled variable becomes true. Execution in this case    won't stop.
     
     But it may varry if you change the sleep or waiting timing  because it all depents on timing.
     
     */
    
    
    func exampleThree() {
        let workItemOne = DispatchWorkItem {
            for i in 0...5 {
                print("➡️ Printing:: \(i)")
            }
        }
        
        let workItemTwo = DispatchWorkItem {
            for i in 6...10 {
                print("➡️ Printing:: \(i)")
            }
        }
        
        let workItemThree = DispatchWorkItem {
            for i in 11...15 {
                print("➡️ Printing:: \(i)")
            }
        }
        
        let queue = DispatchQueue(label: "queue.concorrent", attributes: .concurrent)
        
        queue.async(execute: workItemOne)
        
        queue.async(execute: workItemTwo)
        
        queue.async(execute: workItemThree)
        
        workItemOne.notify(queue: queue, execute: {
            print("Work Item 1️⃣ finished")
        })
        
        workItemTwo.notify(queue: queue, execute: {
            print("Work Item 2️⃣ finished")
        })
        
        workItemThree.notify(queue: queue, execute: {
            print("Work Item 3️⃣ finished")
        })
        
        /**
         
         Output will be different everytime as we are using concurrent queue.
         
         ➡️ Printing:: 6
         ➡️ Printing:: 7
         ➡️ Printing:: 8
         ➡️ Printing:: 9
         ➡️ Printing:: 10
         ➡️ Printing:: 0
         Work Item 2️⃣ finished
         ➡️ Printing:: 11
         ➡️ Printing:: 1
         ➡️ Printing:: 2
         ➡️ Printing:: 3
         ➡️ Printing:: 4
         ➡️ Printing:: 12
         ➡️ Printing:: 13
         ➡️ Printing:: 14
         ➡️ Printing:: 15
         ➡️ Printing:: 5
         Work Item 3️⃣ finished
         Work Item 1️⃣ finished
         */
    }
    
    
    /// Not preferable to use group.enter() and group.leave() with dispatch work item, it will cause dead lock if enter do not have correspoding leave.
    func exampleFour() {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "queue.concurrent", attributes: .concurrent)

        
        let workItemOne = DispatchWorkItem {
            for i in 0...5 {
                print("➡️ Printing:: \(i)")
            }
            group.leave()
        }
        
        let workItemTwo = DispatchWorkItem {
            for i in 6...10 {
                print("➡️ Printing:: \(i)")
            }
        }
        
        let workItemThree = DispatchWorkItem {
            for i in 11...15 {
                print("➡️ Printing:: \(i)")
            }
        }
        
        group.enter()
        queue.async(execute: workItemOne)
        
        
        group.enter()
        queue.async(execute: workItemTwo)
        
        group.enter()
        queue.async(execute: workItemThree)
        
        group.notify(queue: queue) {
            print("Execution in group finished ✅")
        }
        
//        group.wait()
//        print("Execution in group finished ✅")
        
        workItemOne.notify(queue: queue, execute: {
            print("Work Item 1️⃣ finished")
        })
        
        workItemTwo.notify(queue: queue, execute: {
            print("Work Item 2️⃣ finished")
        })
        
        workItemThree.notify(queue: queue, execute: {
            print("Work Item 3️⃣ finished")
        })
        
        /**
         output - when you use group.leave() after queue.async(execute: workItemThree)
         Execution in group finished ✅
         ➡️ Printing:: 6
         ➡️ Printing:: 7
         ➡️ Printing:: 8
         ➡️ Printing:: 9
         ➡️ Printing:: 0
         ➡️ Printing:: 10
         ➡️ Printing:: 11
         ➡️ Printing:: 1
         ➡️ Printing:: 2
         ➡️ Printing:: 3
         ➡️ Printing:: 4
         Work Item 2️⃣ finished
         ➡️ Printing:: 5
         ➡️ Printing:: 12
         Work Item 1️⃣ finished
         ➡️ Printing:: 13
         ➡️ Printing:: 14
         ➡️ Printing:: 15
         Work Item 3️⃣ finished
         
         output - when you use group.leave() inside workItemBlock
         
         // In this case you can notice notify will not call, which cause deadlock, because  enter() calls do not have corresponding leave() calls.
         ➡️ Printing:: 11
         ➡️ Printing:: 12
         ➡️ Printing:: 13
         ➡️ Printing:: 14
         ➡️ Printing:: 15
         Work Item 3️⃣ finished
         ➡️ Printing:: 0
         ➡️ Printing:: 1
         ➡️ Printing:: 2
         ➡️ Printing:: 3
         ➡️ Printing:: 4
         ➡️ Printing:: 5
         ➡️ Printing:: 6
         Work Item 1️⃣ finished
         ➡️ Printing:: 7
         ➡️ Printing:: 8
         ➡️ Printing:: 9
         ➡️ Printing:: 10
         Work Item 2️⃣ finished
         
         
         
         🔵 So do not use group.enter() and group.leave() when you use dispatch Group with Dispatch Work Item.
         */
    }
    
    
    // MARK: - DispatchGroup with work item. How to use dispatch group with dispatch work item.
    func dispatchGroupWithWorkItem() {
        let group = DispatchGroup()
        
        let workItem1 = DispatchWorkItem {
            print("WorkItem 1 running")
            sleep(1)
            print("Workitem 1 done")
        }
        
        let workItem2 = DispatchWorkItem {
            print("WorkItem 2 running")
            sleep(1)
            print("Workitem 2 done")
        }
        
        // Assign each work item to the group
        DispatchQueue.global().async(group: group, execute: workItem1)
        DispatchQueue.global().async(group: group, execute: workItem2)
        
        group.notify(queue: .main) {
            print("All work items completed.")
        }
        
        /**
         output -
         WorkItem 1 running
         WorkItem 2 running
         Workitem 1 done
         Workitem 2 done
         All work items completed.
         */
    }
    
    func cancelWorkItemInGroup() {
        let group = DispatchGroup()
        var workItem: DispatchWorkItem!
        
        workItem = DispatchWorkItem {
            if Thread.isMainThread {
                print("Running on main thread")
            }
            print("Work Item started")
            
            
            for i in 1...5 {
                if workItem.isCancelled {
                    print("WorkItem cancelled at iteration: \(i)")
                    return
                }
                
                sleep(1)
                print("Iteration:: \(i)")
            }
        }
        
        
        DispatchQueue.global().async(group: group, execute: workItem)
        
        // Cancel after two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            workItem.cancel()
        }
        
        group.notify(queue: .main) {
            print("Group finished (cancelled or not)")
        }
        
        /**
         Output -
         Work Item started
         Iteration:: 1
         Iteration:: 2
         Iteration:: 3
         WorkItem cancelled at iteration: 4
         Group finished (cancelled or not)
         */
    }
}

    

// MARK: DISPATCH BARRIER
class DispatachBarrierExecutions {
    var amountRemain: Int = 50
    let items: [Int] = [30, 40]
    
    
    func example() {
        let customQueue = DispatchQueue.init(label: "concurrent_queue", attributes: .concurrent)
        
        for i in 0...5 {
            customQueue.async {
                print("value:: \(i)")
            }
            
            /**
             value:: 0
             value:: 1
             value:: 3
             value:: 2
             value:: 4
             value:: 5
             */
        }
        
        customQueue.async {
            for i in 0...5 {
                print("value:: \(i)")
            }
            
            /**
             value:: 0
             value:: 1
             value:: 2
             value:: 3
             value:: 4
             value:: 5
             */
        }
    }
    
    func barrierOne() { // barrier blocks the execution not the thread.
        let customQueue = DispatchQueue.init(label: "concurrent_queue", attributes: .concurrent)
        
        for value in self.items {
//            customQueue.async {
//                self.execute(value: value)
//            }
            
            customQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self.execute(value: value)
            }
            
            // It will execute once the above task completes.
            customQueue.async {
                print("async block 2")
            }
            
            customQueue.async {
                print("async block 3")
            }
            
            // it will execute indepenetly, custom queue will not affect it. the barrier queue can only affect it self.
            DispatchQueue.global().async {
                print("This is a global concurrent queue")
            }
        }
    }
    
    func execute(value: Int) {
        if amountRemain > value {
            print("Value: \(value)")
            sleep(3)
            
            
            self.amountRemain = self.amountRemain - value
            print("Remaining amount: \(amountRemain)")
            /**
             output - (always)
             Value: 30
             Remaining amount: 20
             */
            
            /// Because your barrier only protects the custom queue, but you’re actually updating amountRemain on the main queue, the critical part is not protected. So do not use any other queue than barrier queue for critical part.
            /*
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.amountRemain = self.amountRemain - value
                print("Remaining amount: \(amountRemain)")
                
                /**
                 Value: 30
                 Value: 40
                 Remaining amount: 20
                 Remaining amount: -20
                 */
            }
             */
        }
    }
}



class DispatchSemaphoreExecution {
    
}

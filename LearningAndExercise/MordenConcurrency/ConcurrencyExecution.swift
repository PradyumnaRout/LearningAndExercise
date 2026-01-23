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
        
        // it manages enter and leave by itself because you are passing dispatchGroup in group parameter
        customQueue.async(group: dispatchGroup) {
            if Thread.isMainThread {
                print("Task 3 :: Running in main thread")
            } else {
                print("Task 3 :: Running in other thread")
            }

            sleep(UInt32(arc4random_uniform(4)))
            print("After finishing task Three")
        }
        
        //MARK:  Notify when all tasks are completed
        dispatchGroup.notify(queue: .main) {
            print("All tasks are finished. Display the results here.")
        }
        
        // MARK:  Wait for the all the task to complete
        // This will block the current thread until all tasks are completed
//        dispatchGroup.wait()
        
        // MARK: Wait with Timeout
//        let timeoutResult = dispatchGroup.wait(timeout: .now() + 0.2)
//        
//        switch timeoutResult {
//        case .success:
//            print("Success")
//        case .timedOut:
//            print("Time out")
//        }
        
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
            group.leave()
        }
        
        let workItemThree = DispatchWorkItem {
            for i in 11...15 {
                print("➡️ Printing:: \(i)")
            }
            group.leave()
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
         Execution in group finished ✅     // Its position may varry with the notify methods of the work items
         
         
         
         🔵 So do not use group.enter() and group.leave() when you use dispatch Group with Dispatch Work Item.
         instead you can use "DispatchQueue.global().async(group: group, execute: workItem1)" this method of dispatch queue.
         
         Otherwise if you want to handle manually then user .enter and .leave  properly. If you do not use .enter and .leave at all Execution in group finished ✅ will call before the execution is finished because it will consider the whole async block as one task
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
                // Execution Block
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
            // Execution block
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
            
            // place the critical part in the barrier only.
            customQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                self.execute(value: value)
            }
            
//            // It will execute once the above task completes.
//            customQueue.async {
//                print("async block 2")
//            }
//            
//            customQueue.async {
//                print("async block 3")
//            }
//            
//            // it will execute indepenetly, custom queue will not affect it. the barrier queue can only affect it self.
//            DispatchQueue.global().async {
//                print("This is a global concurrent queue")
//            }
        }
    }
    
    func executeBarrier() {
        let customQueue = DispatchQueue.init(label: "concurrent_queue", attributes: .concurrent)
        
//        for value in self.items {
//            customQueue.async(flags: .barrier) { [weak self] in
//                guard let self = self else { return }
//                self.execute(value: value)
//            }
//        }
        
        /**
         1. Multiple async(flags: .barrier) inside the loop
         for value in self.items {
             customQueue.async(flags: .barrier) {
                 self.execute(value: value)
             }
         }

         ❗ What actually happens

         You are submitting N separate barrier blocks, one for each item.

         Each barrier block executes one at a time, never concurrently.

         Between each barrier block, no other block (even non-barrier) can run on that queue.

         Essentially:

         barrier(item1)
         barrier(item2)
         barrier(item3)
         ...

         ✔️ Effect:

         Strict serialization across the whole queue
         → no concurrency at all
         → runs slower
         → prevents all other tasks on that queue until all items finish
         */
        
//        customQueue.async {
//            for i in 0...5 {
//                print("Value : \(i)")
//            }
//        }
//        
//        customQueue.async {
//            for i in 6...10 {
//                print("Value : \(i)")
//            }
//        }
        
        customQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            for value in self.items {
                self.execute(value: value)
            }
        }
        

        
        
        /**
         2. Single barrier block wrapping the loop
         customQueue.async(flags: .barrier) {
             for value in self.items {
                 self.execute(value: value)
             }
         }

         ❗ What actually happens

         You submit one single barrier block.

         Queue behavior:

         🔵 `All previously submitted non-barrier tasks run concurrently.`

         Then the queue reaches this block → enters exclusive mode

         The entire loop executes in one uninterrupted block, serially.

         After the loop finishes, the queue resumes concurrent behavior.

         ✔️ Effect:

         Only this one block is exclusive.

         Tasks inside the loop are not isolated barriers, they are just simple synchronous statements.

         Faster and cleaner than the first approach.
         */
    }
    
    func execute(value: Int) {
        if amountRemain > value {
            print("Value: \(value)")
//            sleep(3)
            
            
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

// MARK: Dispatch Barrier
class DispatchBarrierProblems {
    var payBalance: Int = 100
    let itemsPrice: [Int] = [60, 80]
    
    let barrierQueue = DispatchQueue(label: "dispatch_barrier_queue", attributes: .concurrent)
    
    func operations() {
        // MARK: Execution: 1
//        for item in itemsPrice {
//            barrierQueue.async(flags: .barrier) { [weak self] in
//                guard let `self` else { return }
//                self.purchase(item)
//            }
//        }
        
        
        // MARK: Execution: 2
        // This is better and safer version. You may think it may return minus. but no, because barrier will run it in a single thread. so One task will be execute at a time.
        barrierQueue.async(flags: .barrier) { [weak self] in
            guard let `self` else { return }
            for item in itemsPrice {
                self.purchase(item)
            }
        }
    }
    
    func purchase(_ amount: Int) {
        // Place the critical section only inside the used barrier queue,  if you use any other queue then critical section will execute on that thread. So you will get wrong output.
        if payBalance > amount {
            sleep(3)
            self.payBalance = self.payBalance - amount
        }
    }
    
    func resetBalance() {
        print("Available Balance: \(payBalance)")
        self.payBalance = 100
    }
}


// MARK: DispatchSemaphore (Dependency)
class DispatchSemaphoreDependency {
    let queue = DispatchQueue(label: "com.example.tasks", attributes: .concurrent)

    // Allow only 2 tasks to run at the same time
    let semaphore = DispatchSemaphore(value: 2)

    // Dependency semaphores
    let taskACompleted = DispatchSemaphore(value: 0)
    let taskBCompleted = DispatchSemaphore(value: 0)
    // MARK: 🧠 Here zero means you block the execution, and when signal calls it increase to 1. Yes it can chnage the initialized value.

    func taskA() {
        semaphore.wait()   // acquire slot
        print("🚀 Task A started (Downloading)")
        sleep(2)
        print("✅ Task A finished")
        
        taskACompleted.signal()  // notify B
        semaphore.signal()       // release slot
    }

    func taskB() {
        taskACompleted.wait()   // wait for A to finish
        semaphore.wait()
        
        print("🚀 Task B started (Processing)")
        sleep(2)
        print("✅ Task B finished")
        
        taskBCompleted.signal() // notify C
        semaphore.signal()
    }

    func taskC() {
        taskBCompleted.wait()   // wait for B to finish
        semaphore.wait()
        
        print("🚀 Task C started (Uploading)")
        sleep(2)
        print("✅ Task C finished")
        
        semaphore.signal()
    }

    // Dispatch tasks
    func operations() {
        queue.async { self.taskA() }
        queue.async { self.taskB() }
        queue.async { self.taskC() }
    }

    // Keep playground or CLI alive
//    RunLoop.main.run()

}




class DispatchSemaphoreExecution {
    var totalPayBalance: Int = 50
    var cartItems: [Int] = [30, 40]
    let semaphore = DispatchSemaphore(value: 1)

    
    func semaphoreExecution() {
        for items in cartItems {
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.execute(value: items)
            }
        }
        
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            for item in cartItems {
//                self.execute(value: item)
//            }
//        }
        
        // both the block will give same output -
        /*
         item value: 30
         Remaining amout : 20
         
         
         if you change value to 2
         item value: 30
         item value: 40
         Remaining amout : 10
         Remaining amout : -20
         */
    }
    
    func execute(value: Int) {
        semaphore.wait()
        if totalPayBalance > value {
            print("item value: \(value)")
            sleep(3)
            
            self.totalPayBalance -= value
            semaphore.signal()
            print("Remaining amout : \(totalPayBalance)")
        }
    }
}


// MARK: - Operation And Operation Queue
class ExecutionOfOperationAndOperationQueue {
    func executeOne() {
        print("About to begin operation")
        testOperationOne()
        print("Operation Executed!")
    }
    
    func testOperationOne() {
        let blockOperation = BlockOperation {
            print("First Test")
            sleep(3)
        }
        blockOperation.start()
    }
    /**
     About to begin operation
     First Test
     
     // After 3 sec Operation executed will be print as block operation is synchronous in Manner by default.
     Operation Executed!
     */
    
    /// We can pass multiple block to block operatoion and they will execute concurrently.
    func executionTwo() {
        print("About to begin operation")
        testOperationTwo()
        print("Operation Executed!")
    }
    
    func testOperationTwo() {
        let blockOperation = BlockOperation()
        
       // Completion Blcok of an operation only execute when the operation get completed
        blockOperation.completionBlock = {
            print("Execution operation block completes!")
        }
        
        blockOperation.addExecutionBlock {
            print("Is executin on main thread: \(Thread.isMainThread)")
            print("First Block Executed")
        }
        
        blockOperation.addExecutionBlock {
            print("Second Block Executed")
        }
        
        blockOperation.addExecutionBlock {
            print("Third Block Executed")
        }
        
        // Execute on main thread
//        blockOperation.start()
        
        // Execute in BG thread
        DispatchQueue.global().async {
            blockOperation.start()
        }
    }
    /**
     About to begin operation
     Second Block Executed
     Third Block Executed
     Is executin on main thread: true
     First Block Executed
     Operation Executed!
     
     ➡️ Output will change everytime you run the code and the "Operation Executed!" will only print once the execution of all the blocks will complete, Because it treats all the execution block as one, as they are the part of one blockOperation.
     
     This is alos executing in synchronous manner. As a result you can see Operation Executed! prints at last.
     
     Here in above execution you can see the execution is happening in main thread because .start() is getting called in main thread, so to call it from background thread, we can wrap the start() function in global thread but the nature of execution will still synchronous.
     
     
     When you call the start() method in BG thread the output will be -
     
     About to begin operation
     Operation Executed! (This prints first because now we are not using main thread for executing operaton.)
     Second Block Executed
     Third Block Executed
     Is executin on main thread: false
     First Block Executed
     Execution operation block completes!
     */
    
    
    //MARK:  Custom Operation
    // In execution of an operation first start() method will call and then main() will execute.
    func executionThree() {
        let customOpr = CustomOperatino()
        customOpr.start()
        print("Custom operatoin executed!")
    }
    /**
     Number ➡️ 0
     Number ➡️ 1
     Number ➡️ 2
     Number ➡️ 3
     Number ➡️ 4
     Number ➡️ 5
     Number ➡️ 6
     Number ➡️ 7
     Number ➡️ 8
     Number ➡️ 9
     Number ➡️ 10
     Custom operatoin executed!*/
    
    
    func executeFour() {
        TestOperationFour()
        print("Custom Operation Executed!")
    }
    
    //MARK:  Operation Queue
    func TestOperationFour() {
        let operationQueue = OperationQueue()
        // Operation queue is concurrent in nature.
        // To make the operatin queue seial
       // operationQueue.maxConcurrentOperationCount = 1
        
        let operation1: BlockOperation = BlockOperation()
        let operation2: BlockOperation = BlockOperation()
        
        operation1.addExecutionBlock {
//            print("Operation 1 being executed")
            for i in 1...10 {
                print(i)
            }
        }
        
        operation1.completionBlock = {
            print("Operation 1 executed")
        }
        
        operation2.addExecutionBlock {
//            print("Operation 2 being executed")
            for i in 11...20 {
                print(i)
            }
        }
        
        operation2.completionBlock = {
            print("Operation 2 executed")
        }
        
        
        // Dependency in operation
        operation2.addDependency(operation1)
        // Here operation2 should wait till the time operation 1 being executed, Here Operation2 is depend on Operation1
        // for checking dependecy remove the maximumConcurrent
        
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
    }
    /**
     Custom Operation Executed!
     (This is executing first, that means operation queue execute operation in another thread than main thread.)
     
     
     Lets check the operations are concurrent
     
     Custom Operation Executed!
     11
     12
     13
     14
     15
     16
     1
     17
     2
     18
     3
     4
     19
     5
     20
     6
     7
     8
     9
     Operation 2 executed
     10
     Operation 1 executed
     
     IN case operationQueue.maxConcurrentOperationCount = 1
     
     Custom Operation Executed!
     1
     2
     3
     4
     5
     6
     7
     8
     9
     10
     Operation 1 executed
     11
     12
     13
     14
     15
     16
     17
     18
     19
     20
     Operation 2 executed
     
     - In case of dependency -
     Custom Operation Executed!
     1
     2
     3
     4
     5
     6
     7
     8
     9
     10
     11
     12
     13
     14
     15
     16
     17
     Operation 1 executed
     18
     19
     20
     Operation 2 executed
     
     
     // Here is a catch that the completion block might not executed at the expected time, it might delay. Bbut the operatio2 will only start when the operation1 finish its execution.
     // Completion block will executed a slight delay(not every time), but the execution block can start before the completion block.
     
     */
    
    
    
    // Running asynchronous block in an operation queue.
    func executeFive() {
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation(block: printOneToTen)
        let operation2 = BlockOperation(block: printElevenToTwenty)
        
        operation2.addDependency(operation1)
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
        
        print("Custom Operation Executed!")
    }
    /**
     
     // As you can see this is not following depenedency. This is because if you execute a async job inside an operation, it will assumed to be completed as soon as the finishes, mean while if you are executing something asynchrounsly, like you are executing something else in other thread, or some other task, it will not be considered, so it will dissove the dependecny.
     
     // To deal with this problem we shoud state of the operation.
     
     // the async block
     DispatchQueue.global().async {
         for i in 1...10  {
             print(i)
         }
     }
     
     Custom Operation Executed!
     1
     11
     2
     12
     3
     13
     4
     14
     5
     15
     6
     16
     7
     17
     8
     9
     18
     10
     19
     20
     */
    
    func printOneToTen() {
        DispatchQueue.global().async {
            for i in 1...10  {
                print(i)
            }
        }
    }
    
    func printElevenToTwenty() {
        DispatchQueue.global().async {
            for i in 11...20  {
                print(i)
            }
        }
    }
    
    func executeAsyncOperation() {
        let operationQueue = OperationQueue()
        
        let operation1 = PrintNumberOperation(range:Range( 0 ... 25))
        let operation2 = PrintNumberOperation(range: Range(26 ... 50))
        
        operation2.addDependency(operation1)
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
        
        print("Custom Operation Executed!")
        
        /**
         Custom Operation Executed!
         0
         1
         2
         3
         4
         5
         6
         7
         8
         9
         10
         11
         12
         13
         14
         15
         16
         17
         18
         19
         20
         21
         22
         23
         24
         25
         26
         27
         28
         29
         30
         31
         32
         33
         34
         35
         36
         37
         38
         39
         40
         41
         42
         43
         44
         45
         46
         47
         48
         49
         50
         */
    }
}

// MARK: - Custom Operation
class CustomOperatino: Operation {
    // This will execute the execution off the main thread, but this is not the right way as Thread is a raw API and we have to manage everyting like memory, etc if we use Thread. ThereFore OperationQueue comes into picture.
    override func start() {
        Thread.init(block: main).start()
    }
    
    override func main() {
        for i in 0...10 {
            print("Number ➡️ \(i)")
        }
    }
}


// MARK: States of Opearation
class AsyncOperation: Operation {
    enum State: String {
        case isReady
        case isExecuting
        case isFinished
    }
    
    var state: State = .isReady {
        willSet(newValue) {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isAsynchronous: Bool { true }
    override var isExecuting: Bool { state == .isExecuting }
    override var isFinished: Bool {
        if isCancelled && state != .isExecuting { return true }
        return state == .isFinished
    }
    
    override func start() {
        guard !isCancelled else {
            state = .isFinished
            return
        }
        state = .isExecuting
        main()
    }
    
    override func cancel() {
        state = .isFinished
    }
}


class PrintNumberOperation: AsyncOperation {
    var range: Range<Int>
    
    init(range: Range<Int>) {
        self.range = range
    }
    
    override func main() {
        DispatchQueue.global().async { [weak self] in
            guard let self: PrintNumberOperation = self else { return }
            for i in self.range {
                print(i)
            }
            self.state = .isFinished
        }
    }
}



// MARK: BLOCK OPERATION EXAMPLE
class BlcokOperationExecution {
    func operations() {
        // MARK: Execution: 1
//        print("About to begin the operation")
//        execution1()
//        print("Wooo, Execution finished.😂")
        // the second print statement will execute after execution1() finishes its execution as Operation is synchronous in nature. Untill you execute it in another background thread.
        // If you execute the block operation in another background thread, the second print statement will print immediately.
        
        
        //MARK: Execution: 2
//        print("About to begin the operation")
//        execution2()
//        print("Wooo, Execution finished.😂")
        
        
        // MARK: Exectuion: 3
        execution3()
    }
    
    // MARK: Executions
    // Execution: 1 single block operation.
    func execution1() {
        let blockOperation = BlockOperation {
            print("This is the first operation.")
            sleep(3)
        }
        
        // Running in main Thread.
        blockOperation.start()
        // Output -
        /*
         About to begin the operation
         This is the first operation.
         Wooo, Execution finished.😂        // will execute after 3 second of operation block execution.
         */
        
        // Running in background thread
//        DispatchQueue.global().async {
//            blockOperation.start()
//        }
        // Output -
        /*
         About to begin the operation
         Wooo, Execution finished.😂
         This is the first operation.
         */
    }
    
    // Execution: 2 Block operation with concurrent execution (Inside operation block).
    func execution2() {
        let blockOperation = BlockOperation()
        
        blockOperation.completionBlock = {
            print("😎✌🏻 Operation block finish its execution!")
        }
        
        blockOperation.addExecutionBlock {
            for i in 1...5 {
                print("First block operation:: \(i)")
            }
        }
        
        blockOperation.addExecutionBlock {
            for i in 6...10 {
                print("First block operation:: \(i)")
            }
        }
        
        blockOperation.addExecutionBlock {
            for i in 11...15 {
                print("First block operation:: \(i)")
            }
        }
        
        // Execute in main thread
//        blockOperation.start()
        /* Output -
         About to begin the operation
         First block operation:: 1
         First block operation:: 6
         First block operation:: 11
         First block operation:: 2
         First block operation:: 7
         First block operation:: 12
         First block operation:: 3
         First block operation:: 4
         First block operation:: 5
         First block operation:: 8
         First block operation:: 13
         First block operation:: 9
         First block operation:: 10
         First block operation:: 14
         First block operation:: 15
         Wooo, Execution finished.😂
         😎✌🏻 Operation block finish its execution!
         */
        
        // Execution in background thread
        DispatchQueue.global().async {
            blockOperation.start()
        }
        /* Output -
         About to begin the operation
         Wooo, Execution finished.😂
         First block operation:: 6
         First block operation:: 7
         First block operation:: 11
         First block operation:: 12
         First block operation:: 13
         First block operation:: 8
         First block operation:: 14
         First block operation:: 1
         First block operation:: 9
         First block operation:: 15
         First block operation:: 2
         First block operation:: 10
         First block operation:: 3
         First block operation:: 4
         First block operation:: 5
         😎✌🏻 Operation block finish its execution!
         */
    }
    
    
    // MARK: Operation Queue
    func execution3() {
        let operationQueue = OperationQueue()
        
        
        let blockOperation1 = BlockOperation()
        let blockOperation2 = BlockOperation()
        
        blockOperation1.addExecutionBlock {
            for i in 1...10 {
                print("Block operation One: \(i)")
            }
        }
        
        blockOperation1.completionBlock = {
            print("Block operation one complete!")
        }
        
        blockOperation2.addExecutionBlock {
            for i in 11...20 {
                print("Block operation two: \(i)")
            }
        }
        
        blockOperation2.completionBlock = {
            print("Block operation Two complete!")
        }
        
        
        // First Approach - Execute block operations in operation queue
//        operationQueue.addOperation(blockOperation1)
//        operationQueue.addOperation(blockOperation2)
        
        
        // Second Approach - Try synchronization. It will execute one operation at a time
//        operationQueue.maxConcurrentOperationCount = 1
//        operationQueue.addOperation(blockOperation1)
//        operationQueue.addOperation(blockOperation2)
        
        
        // Third Approach - Try Dependecy. Two will execute after One.
        blockOperation2.addDependency(blockOperation1)
        operationQueue.addOperation(blockOperation2)
        operationQueue.addOperation(blockOperation1)
        
    }
    
}


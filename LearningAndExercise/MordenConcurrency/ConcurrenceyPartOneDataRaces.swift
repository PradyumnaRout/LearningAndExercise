//
//  ConcurrenceyPartOne.swift
//  LearningAndExercise
//
//  Created by hb on 31/10/25.
//

/**
 Dispatch Group -
 https://medium.com/@rahulsinghrajawat/dispatchgroup-b120bc0bfe68
 https://ruslandzhafarov.medium.com/how-to-use-dispatchgroup-4bec5ae00ee5
 https://medium.com/@harshaag99/understanding-semaphore-dispatch-in-swift-1fd419650f3f
 https://medium.com/@harshaag99/dispatchqueue-vs-operationqueue-in-swift-02a71626080f
 
 
 Dispatch work item And Dispatch Group.
 https://manasaprema04.medium.com/multithreading-in-ios-part-2-3-fe0116ffee5
 */

/*
 🖇️
 
 Queue Type                                         async behavior                                  sync behavior
 Serial Queue                           Runs tasks one after another (always serial)    Runs tasks one after another; caller                                                                                       waits for completion
 Concurrent Queue                           Runs multiple tasks in parallel             Caller waits for task to finish — but                                                                                      tasks may still run in parallel with                                                                                       others already on the queue
 
 
 | Fact                                               | Explanation                                         |
 | -------------------------------------------------- | --------------------------------------------------- |
 | ✅ `sync` blocks are executed immediately           | Caller waits for each to finish                     |
 | ✅ Concurrent queues can run multiple tasks at once | But only if multiple tasks are already in the queue |
 | ❌ Your loop doesn't add tasks fast enough          | It waits every time → preventing overlap            |
 | ✅ Result: You unintentionally made it serial       | Even though it's a concurrent queue                 |

 */

/**
 A deadlock happens when two or more threads are waiting on each other forever, each holding a resource that the other one needs. Typical signs of deadlock:

 Mutual waiting

 No further progress

 Locks or sync dispatches involved
 */

// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-1-introduction-938da7773903
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-2-understanding-async-await-2bfb268ed487
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-3-tasks-and-task-priorities-3fd647a03fcf
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-4-structured-concurrency-0fd12afc0092
// https://blog.stackademic.com/mastering-modern-concurrency-in-swift-part-5-actors-protecting-shared-state-27c81fc51f98
import Foundation

//MARK: - Data Races

/*
 An actor in swift is like class, but with one key difference.
 
 ● Only one task can access its mutable state at a time.
 ● This prevents data races where multiple task read and write to the same property simultaneously.
 
 You can think actor a serial executer for its data.
 */

/// `Here, even if multiple concurrent tasks call increment(), the actor ensures that updates to value happen safely.
actor ActorCounter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

class ClassCounter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

//👉 Test data races: Unsynchronized concurrent access to shared data.
class TestDataRaces {
    var actorObj = ActorCounter()
    var classObj = ClassCounter()
    
    let concurrentqueue = DispatchQueue.global()  // Concurrent queue
    private let serialQueue = DispatchQueue(label: "com.example.safeQueue") // Serial
    
    // 🔷 Data Race in class
    /**
     ● Two Task {} blocks run asynchronously on different threads.
     ● Both may call classObj.increment() at the same time.
     ● Meanwhile, you immediately call getValue() without waiting for the tasks to finish.

     ● `This isn't deadlock; it's unsynchronized concurrent access to shared data, leading to:
     ✅ No thread waiting forever → no deadlock.
     ⚠️ Possible incorrect result (0, 1, or 2) → data race.
     ❌ No guarantee both increments finish before reading value.
     */
    // Data race using Task{}
    func testClassDataRace() {
        Task {
            classObj.increment()
        }
        
        Task {
            classObj.increment()
        }
        
        let result = classObj.getValue()
        print(result)       // Possibel outcome - (0, 1, or 2)
    }
    
    // Data race uisng dispatchqueue
    func testRaceCondition() {
        for _ in 0..<10000 {
            concurrentqueue.async { [weak self] in
                self?.classObj.increment()    // ⚠ Multiple threads writing to 'value' at same time
            }
        }
        
        // Give some time for tasks to finish (not perfect but demonstrates the issue)
        concurrentqueue.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            print("Final value: \(String(describing: self?.classObj.getValue()))")
        })
    }
    
    // ✅ Concurrent queues can run multiple tasks at once But only if multiple tasks are already in the queue
    func dataRaceUsingConcurrentQueue() {
        
        // It will execute concurrently with the below sync block because it is already in the queue.
        concurrentqueue.async {
            for i in 1...3 {
                print("Async Task 1 -> \(i)")
                self.classObj.increment()
            }
        }

        concurrentqueue.sync {
            for i in 1...3 {
                print("Sync Task   -> \(i)")
                self.classObj.increment()
            }
        }

        // will execute after the execution of above to queue.
        concurrentqueue.async {
            for i in 1...3 {
                print("Async Task 2 -> \(i)")
                self.classObj.increment()
            }
        }
        
        concurrentqueue.sync {
            print("Enter to get value")
            print("counter value :: \(self.classObj.getValue())")
        }
    }
    
    
    /// 🖍️ `Even though you're using async, when tasks are submitted to a serial queue, they are still executed one after another, in order.
    func solveDataRace() {
        for _ in 0..<1000 {
            serialQueue.async {
                print("Enter to increment")
                self.classObj.increment()
            }
        }
        
        serialQueue.async {
            print("Enter to get value")
            print("counter value :: \(self.classObj.getValue())")
        }
    }
    
    
    
    // 🔷 Data Race in Actor: Actor manages data reaces by default
    /// `Actors prevent data races, but they do NOT wait for tasks created by Task {} blocks.
    func dataRaceInActor() async {
        Task {
            await actorObj.increment()
        }

        Task {
            await actorObj.increment()
        }

        Task {
            await actorObj.increment()
        }

        let result = await actorObj.getValue()
        print(result) // ❌ Likely prints 0 or 1, not 3
    }
    
    func solveDataRaceInActor() async {
        await actorObj.increment()
        await actorObj.increment()
        await actorObj.increment()
        
        let result = await actorObj.getValue()
        print(result)
    }
    
}


// ➡️ Here’s an example of a thread-safe (data race–free) class in Swift using a serial dispatch queue to synchronize access to shared state:
/*
 🛡️ Why is this Secure from Data Races?

 ● Shared state (value) is private — cannot be accessed directly outside the class.
 ● Synchronization via a serial DispatchQueue — all reads and writes to value occur in a controlled, sequential manner.
 ● No overlapping access — prevents two threads from reading/writing simultaneously.
 */
final class SecureCounter {
    private var counter: Int = 0
    
    // A serial DispatchQueue ensures only one thread accesses `value` at a time
    private let queue = DispatchQueue(label: "com.example.serailQueue")
    
    // Thread safe increment function
    func increment() {
        queue.sync {
            counter += 1
        }
    }
    
    // Thread safe decrement function
    func decrement() {
        queue.sync {
            counter -= 1
        }
    }
    
    // Thread-safe getter for the value
    func getValue() -> Int {
        return queue.sync {
            counter
        }
    }
}

class UseSecureCounter {
    let counter = SecureCounter()
    
    func usage() {
        DispatchQueue.global().async {
            for _ in 0..<100 {
                print("counter increment: \(self.counter.getValue())")
                self.counter.increment()
            }
        }
        
        DispatchQueue.global().async {
            for _ in 0..<10 {
                print("counter decrement: \(self.counter.getValue())")
                self.counter.decrement()
            }
        }
        
        DispatchQueue.main.async {
            print("Counter value:", self.counter.getValue())
        }
    }
}

final class DataManager {

    // MARK: - Singleton Instance (thread-safe by Swift runtime)
    static let shared = DataManager()

    // MARK: - Private Init prevents external creation
    private init() {}

    // MARK: - Protected State
    private var value: Int = 0

    // MARK: - Synchronization Queue
    private let queue = DispatchQueue(label: "com.example.DataManager.queue")

    // MARK: - Thread-safe methods
    func setValue(_ newValue: Int) {
        queue.sync {
            value = newValue
        }
    }

    func getValue() -> Int {
        queue.sync {
            value
        }
    }
}


class DataManagerExecution {
    func execute() {
        DispatchQueue.global().async {
            for i in 10...20 {
                DataManager.shared.setValue(i)
            }
        }

        DispatchQueue.global().async {
            print(DataManager.shared.getValue())
        }
        
        DispatchQueue.global().async {
            DataManager.shared.setValue(200)
        }
    }
}

// Using Dispatch Semaphore
final class SemaphoreCounter {
    private var value: Int = 0
    private let semaphore = DispatchSemaphore(value: 1)
    
    func increment() {
        semaphore.wait()
        value += 1
        semaphore.signal()
    }
    
    func decrement() {
        semaphore.wait()
        value -= 1
        semaphore.signal()
    }
    
    func getValue() -> Int {
        semaphore.wait()
        let currentValue = value
        semaphore.signal()
        return currentValue
    }
}

class UseSecureSemaphore {
    private var counter = SemaphoreCounter()
    
    func usage() {
        DispatchQueue.global().async {
            for _ in 0..<100 {
                self.counter.increment()
            }
        }
        
        DispatchQueue.global().async {
            for _ in 0..<90 {
                self.counter.decrement()
            }
        }
        
        DispatchQueue.main.async {
            print("Counter value:", self.counter.getValue())
        }
    }
}

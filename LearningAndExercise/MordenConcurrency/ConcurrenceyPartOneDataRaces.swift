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


//MARK: EXAMPLE DATA RACES::::::
// MARK: - Data Races
// MARK: Actor - Only one thead can access its multiple states at a time.


// MARK: Counter Actor Data Races
// MARK: Example: 1, Solve Data races
actor CounterActor {
    var counter = 0
    
    func increaseByOne() {
        counter += 1
    }
    
    func decreaseByOne() {
        counter -= 1
    }
}

class CounterDataRacesExecution {
    var counterObj = CounterActor()
    
    // The operation counter += 1 is actually:
    // Read counter
    // Add 1
    // Write back
    // If two threads do this simultaneously, updates get lost.
    // and you can get 1372, 1583, 1897 like that. And that is data race.
    // But in case of actor you will always find 2000, because actor solves data races.
    // 🔷 Data Race in Actor: Actor manages data reaces by default
    func operations() {
        Task {
            for _ in 0..<1000 {
                await counterObj.increaseByOne()   // write
            }
        }
        
        Task {
            for _ in 0..<1000 {
                await counterObj.increaseByOne()   // write
            }
        }
    }
    
    func getValue() {
        Task {
            print("Total Value: \(await counterObj.counter)")
        }
    }
    
    /// `Actors prevent data races, but they do NOT wait for tasks created by Task {} blocks.
    func taskScheduleInActor() async {
        Task {
            await counterObj.increaseByOne()
        }
        
        Task {
            await counterObj.increaseByOne()
        }
        
        Task {
            await counterObj.increaseByOne()
        }
        
        let result = await counterObj.counter
        print(result) // ❌ Likely prints 0 or 1, not 3. This is not data races, it is just task sheduling.
    }
    
    func solveTaskSheduceInActor() async {
        await counterObj.increaseByOne()
        await counterObj.increaseByOne()
        await counterObj.increaseByOne()
        
        let result = await counterObj.counter
        print(result)
    }
}




//MARK:  Example: 2 Solve Data Race
actor AccountBalanceActor {
    var availableBalance: Int = 100
        
    func deposit(_ amount: Int) {
        availableBalance += amount
    }
    
    func withdraw(_ amount: Int) async -> Bool {
        // Even if you sleep it, the races will never happen like in shared case.
        try? await Task.sleep(nanoseconds: 200_000_000)
        if availableBalance >= amount {
            availableBalance -= amount
            return true
        }
        
        return false
    }
    
    func balanceCheck() -> Int {
        availableBalance
    }
    
    func resetBalance() {
        availableBalance = 100
    }
}

class CustomerDataRacesOnActor {
    var holderOne = AccountBalanceActor()
    
    func operations() {
        Task {
            print("Holder One :: \(await holderOne.withdraw(70))")
        }
        
        Task {
            print("Holder One2 :: \(await holderOne.withdraw(80))")
        }
    }
    
    func getValue() {
        Task {
            print("Available Balance is :\(await holderOne.balanceCheck())")
            await holderOne.resetBalance()
        }
    }
}





// MARK: Example: 3 (Creating Data Races In Actor through shared object)
actor AccountBalanceActor2 {
    static var availableBalance: Int = 100
        
    func deposit(_ amount: Int) {
        AccountBalanceActor2.availableBalance += amount
    }
    
    func withdraw(_ amount: Int) async -> Bool {
        // This is a data races because you are accessing a shared instance availableBalance from multiple task. May be you will never get both true because may be your system scheduling handling this, but still it is a data race. To forcefully produce it, uncomment the sleep.
        // When you uncomment it, you will see the data races happens. But still you can stop is by uncommenting the inner sleep and commenting the outer sleep. That will solve your data races, But the correct approach should not to use shared object like static or class.
        try? await Task.sleep(nanoseconds: 200_000_000)
        if AccountBalanceActor2.availableBalance >= amount {
            AccountBalanceActor2.availableBalance -= amount
//            try? await Task.sleep(nanoseconds: 200_000_000)
            return true
        }
        return false
    }
    
    func balanceCheck() -> Int {
        AccountBalanceActor2.availableBalance
    }
}

class CustomerDataRacesOnActor2 {
    var holderOne = AccountBalanceActor2()
    var holderTwo = AccountBalanceActor2()
    
    func operations() {
        Task {
            print("Holder One :: \(await holderOne.withdraw(80))")
        }
        
        Task {
            print("Holder Two :: \(await holderTwo.withdraw(70))")
        }
    }
    
    func getValue() {
        AccountBalanceActor2.availableBalance = 100
        print("Available Balance is :\(AccountBalanceActor2.availableBalance)")
    }
}




// MARK: Now Start data races in class
// Creating Data Races
class CounterClass {
    var value = 0
    
    func increaseByOne() {
//        sleep(2)
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

class CounterClassDataRacesExecution {
    let concurrentQueue = DispatchQueue.global()
    let serialQueue = DispatchQueue(label: "serial_queue")
    var objCounter = CounterClass()
    
    func operations() {
        // MARK: Concurrent Queue Exection Using Task,
        // MARK: ⚠ Multiple threads writing to 'value' at same time
        // MARK:  Execution: 1 (Task)
        /*
        Task {
            for _ in 0..<1000 {
                 objCounter.increaseByOne()   // write
            }
        }
        
        Task {
            for _ in 0..<1000 {
                 objCounter.increaseByOne()   // write
            }
        }
         */
        
        
        // MARK: Executin: 2 (Dispatch queue)
        /*
        // Remember🧠: Concurrent queues can run multiple tasks at once But only if multiple tasks are already in the queue
                
        concurrentQueue.async {
            // It will execute concurrently with the below sync block because it is already in the queue.
            for _ in 1...1000 {
//                print("Async Task 1")
                self.objCounter.increaseByOne()
            }
        }
        
        concurrentQueue.sync {
            for _ in 1...1000 {
//                print("Sync Task")
                self.objCounter.increaseByOne()
            }
        }
        
        
//         will execute after the execution of above to queue.
        concurrentQueue.async {
            for _ in 1...1000 {
//                print("Async Task 2")
                self.objCounter.increaseByOne()
            }
        }
         */
        
        
        
        // MARK: Execution: 3 (Dispatch queue)
        /*
        concurrentQueue.async {
            for _ in 0..<1000 {
                self.objCounter.increaseByOne()   // write
            }
        }

        concurrentQueue.async {
            for _ in 0..<1000 {
                self.objCounter.increaseByOne()   // write
            }
        }
         */
        
        
        
        // MARK: Execution: 4 (Dispatch queue Using Serial Queue)
        /*
        /// 🖍️ `Even though you're using async, when tasks are submitted to a serial queue, they are still executed one after another, in order.
        
        serialQueue.async {
            for _ in 0..<1000 {
                self.objCounter.increaseByOne()
            }
        }
        
        for _ in 0..<1000 {
            serialQueue.async {
//                print("Enter to increment")
                self.objCounter.increaseByOne()
            }
        }
         */
        
        
        
        // MARK: Execution: 5 (Dispatch queue Using Concurrent Queue)
        concurrentQueue.async {
            for _ in 0..<1000 {
                self.objCounter.increaseByOne()
            }
        }

        for _ in 0..<1000 {
            concurrentQueue.async {
                self.objCounter.increaseByOne()
            }
        }

    }
    
    func getValue() {
        // Execution: 1
        /*
        // Here you may expect the values to be 2000 but when you execute it you will get values like
        // 1935, 1959, 1969, 1952  etc, That is because of data races. That multiple resouces, threads are writing to the same object at the same time.
        print("Total Value: \(objCounter.getValue())")
        objCounter.value = 0
         */
        
        
        // Execution: 2
        /*
        // In the Execution 2 It has an sync block at the middle, it will execute the previous async block with it concurrently. And the last async block will execute after the sync block completes its execution. so you will always get total value less than 3000
        // One more important thing is, If you want to see data races then remove print statement becasue, print it self do synchronous work, so with the presence of print you may see whole correct value every time.😂
        
        print("Total Value: \(objCounter.getValue())")
        objCounter.value = 0
         */
        
        
        
        // Execution: 3
        /*
        // Here alos you will get value less than 2000
        print("Total Value: \(objCounter.getValue())")
        objCounter.value = 0
         */
        
        
        // Execution: 4
        /*
        // Here you will always get 2000 because of the serial queue.
        print("Total Value: \(objCounter.getValue())")
        objCounter.value = 0
         */
        
        
        // Execution 5
        // Here you will always get 2000 because of the serial queue. Even if you chnage the place of the queue execution.
        print("Total Value: \(objCounter.getValue())")
        objCounter.value = 0
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

// MARK: Solving Data Races in Class::::
// Creating a Thread safe synchronous counter class
class ThreadSafeCounter {
    private let queue = DispatchQueue.init(label: "serial_dispatch_queue")
    private var counter: Int = 0
    
    func increaseByOne() {
        queue.sync {
            counter += 1
        }
    }
    
    func decreaseByOne() {
        queue.sync {
            counter -= 1
        }
    }
    
    func getValue() {
        queue.sync {
            print("Counter value:: \(counter)")
            
            counter = 0
        }
    }
}


// MARK: Thread Safe Shared Singleton
class ThreadSafeSharedSingleton {
    private let queue = DispatchQueue.init(label: "serial_dispatch_queue_singleton")
    static let shared = ThreadSafeSharedSingleton()
    
    private init() {}
    
    private var counter: Int = 0
    
    func increaseByOne() {
        queue.sync {
            counter += 1
        }
    }
    
    func decreaseByOne() {
        queue.sync {
            counter -= 1
        }
    }
    
    func getValue() {
        queue.sync {
            print("Counter value:: \(counter)")
            
            counter = 0
        }
    }
}

class SolveDataRaceExecutor {
    let concurrentQueue = DispatchQueue.global()
    var obj = ThreadSafeCounter()
    
    func operations() {
        
        // Execution: 1
        /*
        concurrentQueue.async {
            for _ in 1...1000 {
                self.obj.increaseByOne()
            }
        }
        
        concurrentQueue.async {
            for _ in 1...1000 {
                self.obj.increaseByOne()
            }
        }
         */
        
        
        // Execution: 2
        /*
        for _ in 1...1000 {
            concurrentQueue.async {
                self.obj.increaseByOne()
            }
        }
        
        concurrentQueue.async {
            for _ in 1...1000 {
                self.obj.increaseByOne()
            }
        }
         */
        
        
        // Execution: 3
        /*
        Task {
            await withTaskGroup { group in
                for _ in 1...1000 {
                    group.addTask {
                        self.obj.increaseByOne()
                    }
                }
            }
        }
        
        Task {
            for _ in 1...1000 {
                self.obj.increaseByOne()
            }
        }
         */
        
        
        // Execution: 4
        // Data Manager Execution singleton Thread safe.
        concurrentQueue.async {
            for _ in 1...1000 {
                ThreadSafeSharedSingleton.shared.increaseByOne()
            }
        }
        
        concurrentQueue.async {
            for _ in 1...1000 {
                ThreadSafeSharedSingleton.shared.increaseByOne()
            }
        }
    }
    
    func getValue() {
        // Always get the full corrected value because the object itself is coming form a synchronous/serial context.
//        obj.getValue()
        ThreadSafeSharedSingleton.shared.getValue()
    }
}



actor CounterActorSharedResouces {
    static var counter = 0
    
    func increaseByOne() {
        CounterActorSharedResouces.counter += 1
    }
    
    func decreaseByOne() {
        CounterActorSharedResouces.counter -= 1
    }
    
    static func getValue() {
        print("Value:: \(CounterActorSharedResouces.counter)")
        CounterActorSharedResouces.counter = 0
    }
}

class CounterActorSharedResoucesExecutor {
    let counterObj1 = CounterActorSharedResouces()
    let counterObj2 = CounterActorSharedResouces()
    
    func operations() {
        // Here you will always get values less than 2000 as we are using two different object here
        Task {
            for _ in 0..<1000 {
                await counterObj1.increaseByOne()   // write
            }
        }
        
        Task {
            for _ in 0..<1000 {
                await counterObj2.increaseByOne()   // write
            }
        }
    }
    
    func getValue() {
        CounterActorSharedResouces.getValue()
    }
}


actor CounterActorSharedResoucesSingleton {
    static let shared = CounterActorSharedResoucesSingleton()
    private var counter = 0
    
    
    func increaseByOne() {
        counter += 1
    }
    
    func decreaseByOne() {
        counter -= 1
    }
    
    func getValue() -> Int {
        return counter
    }
    
    func reset() {
        counter = 0
    }
}

class CounterActorSharedResoucesExecutorSingleton {
    private let obj = CounterActorSharedResoucesSingleton.shared
    func operations() {
        // Here you will always get values less than 200
        Task {
            for _ in 0..<1000 {
                await obj.increaseByOne()   // write
            }
        }
        
        Task {
            for _ in 0..<1000 {
                await obj.increaseByOne()   // write
            }
        }
    }
    
    func getValue() {
        // Always get 2000 as it is a single object.
        Task {
            print("Value:: \(await obj.getValue())")
            await obj.reset()
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

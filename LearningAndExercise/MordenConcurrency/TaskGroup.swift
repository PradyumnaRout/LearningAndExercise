//
//  TaskGroup.swift
//  LearningAndExercise
//
//  Created by hb on 04/11/25.
//

import Foundation
import UIKit
// Task Group - https://ahmadgsufi.medium.com/taskgroup-7e73ecea1a6

/*
 ✅ Why Use TaskGroup?

 Here are the main reasons:

 1. Run many tasks at the same time (in parallel):
 If you want to perform async work on multiple items (like downloading files or processing data), TaskGroup lets all those tasks run concurrently.

 2. Automatically wait for all tasks to finish:
 With TaskGroup, you don’t manually track when each task is done. The group handles it for you — you just collect the results.

 3. Better structured code:
 All tasks in the group are contained within one scope (withTaskGroup), making your code clean and easy to manage.

 4. Safe and cancellable:
 If the parent task is cancelled, all child tasks in the group are automatically cancelled too.
 
 🔍 When Should You Use TaskGroup?
 
 | Use Case                                     | Use `TaskGroup`?                   |
 | -------------------------------------------- | ---------------------------------- |
 | Run independent tasks in parallel            | ✅ Yes                              |
 | Wait for all async tasks to finish           | ✅ Yes                              |
 | Manage child task cancellation automatically | ✅ Yes                              |
 | Run one async task only                      | ❌ No (just use `await`)            |
 | Want ordered results like `.map`             | ⚠ Build your own or use `asyncMap` |

 
 ✅ In Short

 TaskGroup is used to:

 ✔ Run many async tasks in parallel
 ✔ Collect their results
 ✔ Keep concurrency safe and structured
 ✔ Simplify cancellation and error handling
 */

class WhyTaskGroup {
    func downloadImage( from url: URL) async -> UIImage {
        // Pretend downloading
        return UIImage()
    }
    
    func gromTaskGroup() {
        let urls = ["url1", "url2", "url3"]
        Task {
            var images: [UIImage] = []
            
            await withTaskGroup(of: UIImage.self) { group in
                for url in urls {
                    group.addTask {
                        await self.downloadImage(from: URL(string: url)!)
                    }
                }
                
                for await image in group {
                    images.append(image)
                }
            }
            print("Downloaded images: \(images.count)")
        }
    }
}

/*
 🔹 Two Types of Task Groups
 
 Type                                       Handles Errors?                             Example
 TaskGroup                   ❌ No (errors are ignored or must be                withTaskGroup(of: Int.self)
                            handled inside task manually)
 ThrowingTaskGroup          ✅ Yes (errors can be thrown, caught, and will       withThrowingTaskGroup(of: Int.self)
                            cancel remaining tasks)
 */

class CompareTaskAndThrowingTask {
    
    func doWork(_ number: Int) async throws -> Int {
        if number == 2 {
            throw NSError(domain: "TestError", code: 1)
        }
        return number * 2
    }

    /**
     ✅ If You Use TaskGroup (Non-Throwing)
     🖍️ If a task inside fails(throw an error), the error is ignored unless you catch it manually inside the task.
     
     • Errors stay inside the task.
     • Other tasks continue running normally.
     • No automatic cancellation.
     */
    func nonThrowingTaskGroup() async {
        await withTaskGroup(of: Int.self) { group in
            for number in [1, 2, 3] {
                group.addTask {
                    do {
                        return try await self.doWork(number)
                    } catch {
                        print("Task failed: \(error)")
                        return -1
                    }
                }
            }
            
            for await result in group {
                print("Result:", result)
            }
            
        }
    }
    
    /**
     ✅ If You Use ThrowingTaskGroup (Recommended for Errors)
     🖍️ This allows throwing tasks safely. If one task fails:
     
     ✔ The error is propagated out of the group
     ✔ Remaining tasks in the group are automatically cancelled
     ✔ You can catch the error outside
     */
    

    func throwingTaskGroup() {
        Task {
            do {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for number in [1, 2, 3] {
                        group.addTask {
                            try await self.doWork(number)
                        }
                    }

                    for try await result in group {
                        print("Result:", result)
                    }
                }
            } catch {
                print("❗Task group failed because of:", error)
            }
        }
    }
    /**
     | Behavior                          | `TaskGroup`            | `ThrowingTaskGroup`   |
     | --------------------------------- | ---------------------- | --------------------- |
     | Error propagation                 | ❌ No                   | ✅ Yes                 |
     | Cancels remaining tasks on error  | ❌ No                   | ✅ Yes                 |
     | You can use `try / catch` outside | ❌ No                   | ✅ Yes                 |
     | Best for                          | Tasks that don’t throw | Tasks that might fail |

     */
    
}

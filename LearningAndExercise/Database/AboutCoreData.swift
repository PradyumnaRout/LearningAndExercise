//
//  AboutCoreData.swift
//  LearningAndExercise
//
//  Created by hb on 07/11/25.
//

// https://andreea-andro.medium.com/core-data-lightweight-migration-quick-reference-6f025dfbd41f
// MARK: - Heavyweight Migration.
/**
 ✅ Why it is Heavyweight

 A lightweight migration can only happen when Core Data can infer the changes without needing to transform existing data.
 Changing an attribute’s type requires data transformation, because existing records stored on disk need to be converted from the old type to the new one. Core Data cannot infer how to convert "25" (String) into 25 (Int), or how to convert an Int64 timestamp into a Date, etc.

 So Core Data says: "I don't know how to migrate the data safely" → requires mapping model + migration logic → heavyweight.
 
 ✅ Examples of lightweight changes (supported automatically)
 | Change                                                            | Lightweight? |
 | ----------------------------------------------------------------- | ------------ |
 | Add a new optional attribute                                      | ✅ Yes        |
 | Add a new entity                                                  | ✅ Yes        |
 | Rename an attribute (with renaming identifier)                    | ✅ Yes        |
 | Make an optional attribute non-optional (if default value exists) | ✅ Yes        |
 | Add a relationship                                                | ✅ Yes        |

 ❌ Examples of heavyweight changes (requires mapping)
 | Change                                               | Lightweight? |
 | ---------------------------------------------------- | ------------ |
 | Change attribute type (`String → Int`, `Int → Date`) | ❌ No         |
 | Split one entity into two                            | ❌ No         |
 | Merge two entities into one                          | ❌ No         |
 | Remove an attribute without default substitution     | ❌ No         |
 | Add validation or custom transformation              | ❌ No         |

 
 ✅ Quick rule to remember:
 | Change                                         | Migration Type  |
 | ---------------------------------------------- | --------------- |
 | Core Data can infer & no data transform needed | **Lightweight** |
 | Requires custom conversion logic               | **Heavyweight** |

 */




/**
 In Core Data, you typically work with two kinds of NSManagedObjectContext:

 Main (UI) Context
 Background Context
 They serve different purposes and should not be mixed, because each one is tied to a different thread/queue.

 ✅ Main Context (viewContext)

 Use it when:
 ● You are updating the UI (e.g., showing data in a table view).
 ● You need to fetch objects to display immediately.
 ● You are responding to user interaction (e.g., editing data in a form).
 ● You need to bind data to SwiftUI views or UIKit components.

 Why?
 Because the main context runs on the main thread, which is the only thread allowed to update UI elements.

 let context = persistentContainer.viewContext
 let request = NSFetchRequest<MyEntity>(entityName: "MyEntity")
 let results = try? context.fetch(request)

 ✅ Background Context

 Use it when:
 ● You are performing large or slow operations, such as:
 ● Importing JSON files or syncing from a server
 ● Heavy batch inserts, updates, deletes
 ● Saving large changes that may block the UI
 ● You need to do work off the main thread to keep the UI smooth.

 Example:

 let bgContext = persistentContainer.newBackgroundContext()
 bgContext.perform {
     let newItem = MyEntity(context: bgContext)
     newItem.name = "Background Item"
     try? bgContext.save()
 }

 🔄 Keeping Contexts in Sync

 When background context saves, the main context does not automatically update unless you observe changes.

 Typical pattern:

 NotificationCenter.default.addObserver(
     self,
     selector: #selector(contextDidSave),
     name: .NSManagedObjectContextDidSave,
     object: bgContext
 )


 Or if using NSPersistentContainer, you can enable automatic merging:

 persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

 🧠 Summary Table
 | Use Case                     | Which Context?         | Reason                     |
 | ---------------------------- | ---------------------- | -------------------------- |
 | Displaying data in UI        | **Main context**       | UI thread only             |
 | Editing data user sees       | **Main context**       | Immediate reflection in UI |
 | Heavy imports / parsing JSON | **Background context** | Prevent UI freeze          |
 | Syncing with server          | **Background context** | Async, avoids blocking     |
 | Batch operations             | **Background context** | Performance                |
 | Auto-saving UI edits         | **Main context**       | User expectation           |

 🔥 Common Mistake to Avoid

 ❌ Never pass managed objects between contexts directly.
 If you need the same object in another context, use its objectID.

 let objectID = someManagedObject.objectID
 let bgObject = bgContext.object(with: objectID)
 */

/**
 Best practices: saving & merging
 1) Configure your stack up-front
 let container = NSPersistentContainer(name: "Model")
 container.loadPersistentStores { _, error in
     precondition(error == nil, "Store failed: \(error!)")
 }

 let viewContext = container.viewContext
 viewContext.automaticallyMergesChangesFromParent = true
 viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
 viewContext.undoManager = nil               // UI rarely needs undo

 // For background work, create ad-hoc contexts:
 func newBGContext() -> NSManagedObjectContext {
     let ctx = container.newBackgroundContext()
     ctx.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
     ctx.undoManager = nil                    // performance
     return ctx
 }


 Why this setup?

 automaticallyMergesChangesFromParent keeps UI in sync when background saves.

 Different merge policies reduce “last write wins” surprises: UI prefers user edits; background prefers the store when resolving conflicts.

 No undo manager in BG contexts = less memory & faster saves.

 2) Create in background, show on main
 let ctx = newBGContext()
 ctx.perform {
     let user = User(context: ctx)
     user.name = "Ada"
     try? ctx.obtainPermanentIDs(for: ctx.insertedObjects.map { $0 })
     try? ctx.save() // viewContext will auto-merge
 }


 obtainPermanentIDs ensures stable objectIDs immediately after creation (useful if you need to reference the object elsewhere).

 3) Edit on the main context (for UI)

 Bind SwiftUI/UI elements to objects from viewContext. Save small edits frequently, e.g., on disappear or via debounced saves:

 try? viewContext.save()

 4) Use child contexts for “draft” edits (optional but nice)

 Make a child of viewContext for complex forms. Commit or discard atomically.

 let editContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
 editContext.parent = viewContext
 // Work in editContext, then:
 try? editContext.save()   // pushes to parent (viewContext)
 try? viewContext.save()   // persists to disk

 5) Merge results of batch ops explicitly

 For NSBatchInsert/Update/Delete, request object IDs and merge:

 let ctx = newBGContext()
 ctx.perform {
     let req = NSBatchUpdateRequest(entityName: "Item")
     req.predicate = NSPredicate(format: "flagged == NO")
     req.propertiesToUpdate = ["flagged": true]
     req.resultType = .updatedObjectIDsResultType

     if let result = try? ctx.execute(req) as? NSBatchUpdateResult,
        let ids = result.result as? [NSManagedObjectID] {
         let changes = [NSUpdatedObjectsKey: ids]
         NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
     }
 }

 6) Save order & frequency

 Background work: bgContext.save() (auto-merges into viewContext).

 UI work: viewContext.save() (persist to disk).

 Save small and often in UI; chunked saves in BG (e.g., every N items) to control memory.

 7) Consider Persistent History for multi-process sync

 If you have app extensions or multiple processes, enable Persistent History Tracking and apply transactions to the viewContext. (Skip if single process.)

 How to avoid threading crashes
 1) Never touch objects off their context’s queue

 Golden rule: only use a managed object on the queue of its NSManagedObjectContext.

 To move across threads/contexts, pass the objectID and refetch.

 let id = user.objectID // from main
 bgContext.perform {
     let bgUser = try? bgContext.existingObject(with: id) as? User
     bgUser?.lastSyncedAt = Date()
     try? bgContext.save()
 }

 2) Always wrap work in perform {} / performAndWait {}

 BG contexts: use perform {} (async) for throughput.

 Main context: use perform {} if you’re not already on the main queue (e.g., from a callback).

 bgContext.perform {
     // safe here
 }

 3) Don’t nest blocking calls (avoid deadlocks)

 Avoid calling performAndWait on main from a background queue (or vice-versa). Prefer perform.

 If you must block, ensure the callee won’t in turn block on your current queue.

 4) Don’t pass managed objects into Swift concurrency without care

 If using async/await, hop to the correct actor/queue before touching Core Data:

 @MainActor
 func updateUI(with objectID: NSManagedObjectID) {
     let obj = try? viewContext.existingObject(with: objectID)
     // safe UI updates here
 }


 Treat contexts as not Sendable; interact on their queues.

 5) Turn large objects into faults after use

 Long BG jobs can bloat memory. Periodically:

 ctx.refreshAllObjects()   // or ctx.reset() if appropriate


 reset() clears change tracking—only use when you don’t need unsaved changes.

 6) Avoid retain cycles & long-lived BG contexts

 Create a BG context for a job, save, then let it go.

 Don’t stash managed objects in singletons; stash objectIDs instead.

 7) Use safe merge policies to reduce conflicts

 UI (viewContext): NSMergeByPropertyObjectTrumpMergePolicy (favor user edits).

 Background: NSMergeByPropertyStoreTrumpMergePolicy (favor latest store state).

 For strict correctness (server-assigned fields), customize policy per entity or resolve conflicts manually.

 8) Handle deleted objects gracefully

 Objects might be deleted in another context by the time you refetch them.

 if let obj = try? ctx.existingObject(with: id), !obj.isFault {
    // use it
 } else {
    // it was deleted or not yet loaded
 }

 9) Batch ops: keep UI objects fresh

 After batch updates/deletes, merge IDs (see #5 above) so UI faults re-fire and FRC/@FetchRequest update without crashes on stale references.

 10) Diagnostics

 Enable Core Data concurrency debugging:

 Scheme > Arguments > -com.apple.CoreData.ConcurrencyDebug 1

 Watch for messages like “CoreData: error: Serious application error…” which often indicate cross-thread object use.

 Minimal, safe templates

 Background job template

 func importItems(_ payload: [ItemDTO], container: NSPersistentContainer) {
     let ctx = container.newBackgroundContext()
     ctx.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
     ctx.perform {
         for (i, dto) in payload.enumerated() {
             let item = Item(context: ctx)
             item.id = dto.id
             item.name = dto.name
             if i % 500 == 0 { try? ctx.save(); ctx.reset() }
         }
         try? ctx.save()
     }
 }


 UI save template

 @MainActor
 func saveUI(_ context: NSManagedObjectContext) {
     guard context.hasChanges else { return }
     try? context.save()
 }
 */

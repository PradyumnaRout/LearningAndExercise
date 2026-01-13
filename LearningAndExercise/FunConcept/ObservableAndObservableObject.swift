//
//  ObservableAndObservableObject.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import Foundation

// MARK: Bindable
// https://medium.com/@jefinabduljaleel/state-binding-and-bindable-in-swiftui-661377090eb6
// https://www.donnywals.com/whats-the-difference-between-binding-and-bindable/

// what if I want to user it inside my viewmodel

/**
 Here’s a clear, practical comparison between @Observable (new) and ObservableObject (old) in SwiftUI — with why, when, and how to choose.

 🆕 @Observable (Swift 5.9+)
 What it is

 A macro-based observation system introduced with Swift’s Observation framework.

 @Observable
 class ViewModel {
     var count = 0
 }

 How it works

 The compiler generates change-tracking code

 SwiftUI automatically observes only the properties actually used

 No Combine involved

 🧓 ObservableObject + @Published
 class ViewModel: ObservableObject {
     @Published var count = 0
 }

 How it works

 Uses Combine

 Any change to @Published triggers objectWillChange

 SwiftUI refreshes everything depending on the object

 ⚖️ Side-by-side comparison
 Feature    @Observable    ObservableObject
 Introduced    Swift 5.9    iOS 13
 Based on    Observation framework    Combine
 Boilerplate    ✅ Minimal    ❌ More
 @Published needed    ❌ No    ✅ Yes
 $property in VM    ❌ No    ✅ Yes
 Automatic dependency tracking    ✅ Yes    ❌ No
 Partial view updates    ✅ Yes    ❌ No
 Performance    🚀 Better    🐢 Worse
 SwiftUI-first    ✅ Yes    ❌ No
 🔑 Key behavioral differences
 1️⃣ Property-level observation vs object-level

 ObservableObject

 @Published var a = 0
 @Published var b = 0


 Changing a refreshes everything.

 @Observable

 var a = 0
 var b = 0


 Only views reading a update when a changes.

 2️⃣ Bindings ($) behavior
 Question    Answer
 $property exists in ViewModel?    ObservableObject ✅ / @Observable ❌
 $property exists in View?    Both ✅

 With @Observable, bindings are created via @Bindable in the View.

 3️⃣ Reacting to changes

 ObservableObject

 $name
     .sink { print($0) }


 @Observable

 var name = "" {
     didSet { print(name) }
 }


 No streams, no subscriptions.

 🧠 When to use which
 ✅ Use @Observable when:

 You’re building new SwiftUI code

 You want less boilerplate

 You don’t need Combine streams

 You want better performance

 You want clearer separation of concerns

 ❌ Avoid @Observable when:

 You need Combine pipelines

 You expose publishers publicly

 You rely on $property inside the ViewModel

 You support iOS < 17

 📱 Platform availability
 Feature    Min OS
 @Observable    iOS 17 / macOS 14
 ObservableObject    iOS 13
 🔄 Migration example
 // OLD
 class VM: ObservableObject {
     @Published var count = 0
 }

 // NEW
 @Observable
 class VM {
     var count = 0
 }


 View change:

 @State private var vm = VM()
 @Bindable var vm = vm

 🧠 Mental model (best way to remember)

 ObservableObject → “Notify everyone”

 @Observable → “Only notify who cares”

 🏁 Final takeaway

 @Observable replaces ObservableObject for SwiftUI-first apps.
 Combine is still valid — just no longer required for UI state.
 */


// how to use @Bindable var vm = vm here, give an example

/**
 
 Here’s a clear, minimal, real example showing exactly how and where to use:

 @Bindable var vm = vm


 This only works with @Observable and inside a SwiftUI View body scope.

 1️⃣ ViewModel using @Observable
 import Observation

 @Observable
 class CounterViewModel {
     var count: Int = 0

     func increment() {
         count += 1
     }
 }

 2️⃣ SwiftUI View using @Bindable
 import SwiftUI

 struct CounterView: View {
     @State private var vm = CounterViewModel()

     var body: some View {
         // 👇 THIS is the important line
         @Bindable var vm = vm

         VStack(spacing: 20) {
             Text("Count: \(vm.count)")

             Button("Increment") {
                 vm.increment()
             }

             Stepper("Stepper", value: $vm.count) // ✅ Binding works
         }
         .padding()
     }
 }

 3️⃣ What @Bindable var vm = vm actually does
 @Bindable var vm = vm


 Creates a binding-aware copy of vm

 Enables $vm.property

 Scoped only to the View body

 Does not create a new instance

 Does not live in the ViewModel

 Think of it as:

 “I want bindings for this observable object in this view.”

 4️⃣ ❌ Common mistakes
 ❌ Putting @Bindable on the property
 @Bindable var vm = CounterViewModel() // ❌ Wrong

 ❌ Using $vm without @Bindable
 Stepper(value: $vm.count) // ❌ Compile error

 ❌ Trying to use it in ViewModel
 @Bindable var vm = vm // ❌ Only valid in View

 5️⃣ With @Environment
 struct CounterView: View {
     @Environment(CounterViewModel.self) private var vm

     var body: some View {
         @Bindable var vm = vm

         Toggle("Enabled", isOn: $vm.isEnabled)
     }
 }

 6️⃣ When you do NOT need @Bindable
 Text(vm.count.description) // ✅ Read-only access is fine


 You only need @Bindable when:

 Using $vm.property

 Passing bindings to child views

 🧠 Mental model
 Keyword    Meaning
 @Observable    Makes the model observable
 @State    Owns the model
 @Bindable    Enables bindings in the View
 $vm.property    Two-way binding
 🏁 Summary

 @Bindable var vm = vm goes inside the View body

 Required for $vm.property

 Works only with @Observable

 Replaces $publishedProperty pattern

 If you want next:

 passing @Bindable to child views

 replacing @ObservedObject

 a full MVVM flow
 */


/**
 @Observable class MyCounter { @Bindable var count = 0 } struct ContentView: View { var counter: MyCounter = MyCounter() init() {} var body: some View { VStack { Text("The count is \(counter.count)") // This will now get compiled MyButton(count: $counter.count) } .padding() } } In the above example the property of the @Observable model is marked as @Bindable, can you explain me about that
 
 
 You cannot put @Bindable on a property inside an @Observable class.

 This line is incorrect:

 @Observable
 class MyCounter {
     @Bindable var count = 0   // ❌ This is not allowed
 }


 @Bindable is a View-only property wrapper.
 It is not meant to be used inside models.

 ✅ The Correct Pattern
 Model
 import Observation

 @Observable
 class MyCounter {
     var count = 0   // ✅ normal stored property
 }

 View
 struct ContentView: View {
     @State private var counter = MyCounter()   // owner

     var body: some View {
         VStack {
             Text("The count is \(counter.count)")
             MyButton(count: $counter.count)   // binding works automatically
         }
         .padding()
     }
 }

 Button View
 struct MyButton: View {
     @Binding var count: Int

     var body: some View {
         Button("Increment") {
             count += 1
         }
     }
 }


 This works because:

 @Observable makes count observable

 SwiftUI automatically synthesizes $counter.count as a Binding<Int>

 No @Bindable is needed inside the model

 🔍 What @Bindable Actually Does

 @Bindable is used in a View when you receive an observable object and want bindings to its properties.

 Example
 struct CounterView: View {
     @Bindable var counter: MyCounter   // 👈 this is where @Bindable goes

     var body: some View {
         VStack {
             Text("Count: \(counter.count)")
             Button("Increment") {
                 counter.count += 1
             }
         }
     }
 }


 Now SwiftUI allows:

 TextField("Count", value: $counter.count, format: .number)


 Because @Bindable exposes bindings to the model’s properties.

 🔹 Correct Data Flow Pattern
 @State owns the model
    ↓
 @Bindable exposes bindings
    ↓
 @Observable publishes changes
    ↓
 SwiftUI updates UI

 ❌ Why @Bindable inside the model is wrong
 Reason    Explanation
 @Bindable is a View wrapper    It only works in SwiftUI views
 Observation already tracks properties    @Observable handles publishing
 It breaks the macro system    Observation macro expects plain properties
 Bindings are created by SwiftUI    Not by the model
 ✅ If your goal is this:
 MyButton(count: $counter.count)


 You only need:

 @Observable class MyCounter { var count = 0 }


 SwiftUI automatically provides $counter.count.
 */



// MARK:  differnce between @State private var counter = Counter() And private var counter = Counter()
/**
 
 @Observable
 class Counter {
     var value = 0
 }
 
 
 my concern is what is the difference between
 @State private var counter = Counter()
 and
 private var counter = Counter()

 Excellent — this gets to the heart of how SwiftUI’s view lifecycle works.

 The difference is who owns the memory and whether SwiftUI preserves it across view updates.

 The Core Difference
 ✅ With @State
 @State private var counter = Counter()


 SwiftUI:

 Stores counter outside the view struct

 Preserves it across view redraws

 Keeps the same instance alive

 Tracks reads to counter's observable properties

 Triggers view updates when counter changes

 This is the correct way to store an @Observable model in a view.

 ❌ Without @State
 private var counter = Counter()


 SwiftUI:

 Recreates counter every time the view recomputes

 Loses all previous state

 Breaks observation tracking

 Causes unexpected resets

 Because SwiftUI views are value types, they are recreated frequently. A normal var is reinitialized every time.

 This means:

 struct ContentView: View {
     private var counter = Counter()   // ❌ BAD

     var body: some View {
         Text("\(counter.value)")
     }
 }


 Every UI update creates a brand new Counter().

 What actually happens during a redraw

 When SwiftUI updates the UI:

 It creates a new ContentView struct

 All stored properties are reinitialized

 counter = Counter() runs again

 Old instance is discarded

 So your state is lost.

 Why @State fixes this

 @State tells SwiftUI:

 "This value is persistent state. Store it outside the view struct and keep it alive."

 So SwiftUI keeps the same Counter instance even though the view struct itself is recreated.
 */

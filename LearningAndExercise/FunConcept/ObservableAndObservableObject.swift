//
//  ObservableAndObservableObject.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import Foundation

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

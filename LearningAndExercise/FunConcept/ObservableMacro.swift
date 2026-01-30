//
//  ObservableMacro.swift
//  LearningAndExercise
//
//  Created by hb on 30/01/26.
//

// Migration of Observable and ObservableObject. - https://developer.apple.com/documentation/SwiftUI/Migrating-from-the-observable-object-protocol-to-the-observable-macro

import SwiftUI
import Observation

struct ObservableMacro: View {
    /// BEFORE: ObservableObject
    @StateObject var viewModel1 = CounterViewModel()
    // Redraw the view everyTime so print changes will print everytime. No matter you use @StateObject or @ObservedObject. It should not be happend becasue we are increasing viewModel1.increaseUnrelatedCount() but we are not using unrelatedCount in our view.
    
    /// AFTER: @Observable
    let viewModel2 = ObservedCounterViewModel()
    // It won't re-render the view everytime. untill we use unrelatedCount and increase it.
    
    var body: some View {
        Self._printChanges()
        return VStack {
            Text("Count is: \(viewModel1.count)")
            Button("Increase count", action: {
                viewModel1.increaseUnrelatedCount()
//                viewModel2.increaseCount()
            })
        }
        .padding()
    }
}



final class CounterViewModel: ObservableObject {
    @Published private(set) var count: Int = 0
    
    /// Not observed by our `CounterView`.
    @Published private(set) var unrelatedCount: Int = 0

    func increaseCount() {
        count += 1
    }
    
    func increaseUnrelatedCount() {
        unrelatedCount = 1
    }
}



@Observable
final class ObservedCounterViewModel {
    private(set) var count: Int = 0
    
    private(set) var unrelatedCount: Int = 0

    func increaseCount() {
        count += 1
    }
    
    func increaseUnrelatedCount() {
        unrelatedCount = 1
        
        // Observer the change globally. Force the UI to update.
//        Task {    // MainActor in
//            await MainActor.run {
//                unrelatedCount = 1
//            }
//        }
    }
}


class UserPostClass {
    var name: String
    var post:String
    
    init(name: String, post: String) {
        self.name = name
        self.post = post
    }
}


struct UserPostStruct {
    var name: String
    var post: String
}


struct ObservableWithStructAndClass: View {
    private var viewModel = ObservableViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Class: \(viewModel.postC.name), \(viewModel.postC.post)")
            
            Text("Struct: \(viewModel.postS.name), \(viewModel.postS.post)")

            Button("Change Struct") {
                viewModel.changeStructPost()
            }
            
            Button("Change Class") {
                // In class it will not reflect the change because class is reference type.
                viewModel.changeClassPost()
            }
        }
    }
}


@Observable class ObservableViewModel {
    var postS: UserPostStruct = UserPostStruct(name: "iOS", post: "Hello")
    
    var postC: UserPostClass = UserPostClass(name: "Android", post: "World")
    
    func changeClassPost() {
        postC.name = "React"
    }
    
    func changeStructPost() {
        postS.post = "Byeee"
    }
}



#Preview {
    ObservableWithStructAndClass()
}

//
//  ObservableObjectWithClassAndStruct.swift
//  LearningAndExercise
//
//  Created by hb on 09/02/26.
//

import Foundation
import SwiftUI

struct UserDetailStruct {
    var age: Int
    var name: String
}

class UserDetailClass {
    var age: Int
    var name: String

    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

class UserDetailModelWithObs: ObservableObject {
    @Published var age: Int
    var name: String

    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}



class UserVMStruct: ObservableObject {
    @Published var user = UserDetailStruct(age: 20, name: "Pradyumna")

    func increaseAge() {
        user.age += 1
    }
}

class UserVMClass: ObservableObject {
    @Published var user = UserDetailClass(age: 20, name: "Pradyumna")

    func increaseAge() {
        user.age += 1
    }
}

class UserVMClassWithObs: ObservableObject {
    @Published var user = UserDetailModelWithObs(age: 20, name: "Pradyumna")
    // private var cancellables = Set<AnyCancellable>()
    
//    init() {
//        user.objectWillChange.sink { [weak self] _ in
//            self?.objectWillChange.send()
//        }.store(in: &cancellables)
//    }

    func increaseAge() {
        user.age += 1
        
        // you can use the init with cancellable or the below statement.
        objectWillChange.send()
    }
}




struct ContentViewEG1: View {
    // MARK:  ObservableObject ViewModel + struct Model
//    @StateObject var vm = UserVMStruct()
    // While using ObservableObject with struct type model, anything change inside the model, can update the view.
    
    //MARK:  ObservableObject ViewModel + Class Model
//    @StateObject var vm1 = UserVMClass()
//    @ObservedObject var vm2 = UserVMClass()
    // In the above case I am using class for model, so anyting change inside model will not update the view. But yes it will update if you make the model ObservableObject.
    
    
    //MARK:  ObservableObject ViewModel + ObservableObject Class Model
    @ObservedObject var vm = UserVMClassWithObs()

    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")

            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview {
    ContentViewEG1()
}


// MARK: ✅ Why an Inner View Works in case of class model and objersvable object.
/*
 SwiftUI isn’t listening to user.

 So if you create an inner view that observes user directly, you attach the observation to the right object.

 That fixes the update.
 */

struct ContentViewWithInner: View {
    @StateObject var vm = UserVMClassWithObs()

    var body: some View {
        UserViewInner(user: vm.user)
    }
}

struct UserViewInner: View {
    @ObservedObject var user: UserDetailModelWithObs

    var body: some View {
        VStack {
            Text("Age: \(user.age)")

            Button("Increase Age") {
                user.age += 1
            }
        }
    }
}

#Preview("Inner view") {
    ContentViewWithInner()
}

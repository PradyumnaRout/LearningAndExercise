//
//  ContentView.swift
//  LearningAndExercise
//
//  Created by hb on 17/10/25.
//

import SwiftUI

struct ContentView: View {
    
//    var sub = UserViewModel()
//    var obj = BasicAsyncStream()
    
    // Custom publisher
//        let publisher = StringPublisher(inputValue: "hello world")
//        let subscriber = StringSubscriber()
    let publisher = OperatorCombineLatest()

    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // Custom publisher
//            publisher.subscribe(subscriber)
//            AppEnvironment.logConfiguration()
//            sub.testLazyProperty()
//            sub.addNewOne()
            
//            obj.basicExample()
            publisher.testCombineLatestWith2()
        }
    }
}

#Preview {
    ContentView()
}

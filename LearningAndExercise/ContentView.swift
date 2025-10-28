//
//  ContentView.swift
//  LearningAndExercise
//
//  Created by hb on 17/10/25.
//

import SwiftUI

struct ContentView: View {
    
    var sub = OperatorSwitchToLatest()
    
    // Custom publisher
//        let publisher = StringPublisher(inputValue: "hello world")
//        let subscriber = StringSubscriber()

    
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
            sub.operateSwitchToLatest()
        }
    }
}

#Preview {
    ContentView()
}

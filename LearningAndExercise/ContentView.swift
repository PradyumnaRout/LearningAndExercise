//
//  ContentView.swift
//  LearningAndExercise
//
//  Created by hb on 17/10/25.
//

import SwiftUI

struct ContentView: View {
    let obj = PropertyWrapperExecution(
        firstName: "steve",
        lastName: "jobs",
        score: 120
    )

    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            print("FistName: \(obj.firstName), LastName: \(obj.lastName), score:\(obj.score)")
            obj.firstName = "aman"
            obj.lastName = "gupta"
            obj.score = 75
            
            print("FistName: \(obj.firstName), LastName: \(obj.lastName), score:\(obj.score)")
        }
    }
}

#Preview {
    ContentView()
}

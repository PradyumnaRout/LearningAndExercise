//
//  ContentView.swift
//  LearningAndExercise
//
//  Created by hb on 17/10/25.
//

import SwiftUI

struct ContentView: View {
    
    var pub = SubjectPassThrough()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
//            AppEnvironment.logConfiguration()
            pub.subscribe()
        }
    }
}

#Preview {
    ContentView()
}

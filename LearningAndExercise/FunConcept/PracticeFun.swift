//
//  PracticeFun.swift
//  LearningAndExercise
//
//  Created by Rahul Kiumar on 24/01/26.
//

import SwiftUI

struct PracticeFun: View {
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PracticeFun()
}


struct WrappedValueDifference: View {
    @State var currentValue: String
    
    init(currentValue: String) {
        _currentValue = State(initialValue: currentValue)
        
        /*
         var currentValue: String          // the wrappedValue
         This assigns to the wrapped value (wrappedValue).
         
         It's like - self._currentValue.wrappedValue = currentValue
         
         
         
         
         var _currentValue: State<String>  // the wrapper itself
         This assigns to the property wrapper itself.
         Swift rewrite it as - _currentValue = State(initialValue: currentValue)

         
         | Line                               | What it sets          | Meaning                |
         | ---------------------------------- | --------------------- | ---------------------- |
         | `self.currentValue = currentValue` | `wrappedValue`        | Mutating the state     |
         | `_currentValue = currentValue`     | the wrapper (`State`) | Initializing the state |

         
         Think of it like:
         currentValue → the value
         _currentValue → the box that holds the value
         
         🧠 Correct way to init
         @State var currentValue: String

         init(currentValue: String) {
             _currentValue = State(initialValue: currentValue)
         }
         
         self.currentValue = currentValue // ❌ not correct for @State in init

         */
    }

    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

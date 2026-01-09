//
//  NewGenreView.swift
//  LearningAndExercise
//
//  Created by hb on 09/01/26.
//

import SwiftUI
import SwiftData

struct NewGenreView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var color = Color.red
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("genre", text: $name)
                
                // Color Picker
                ColorPicker("set the genre color", selection: $color, supportsOpacity: false)
                Text(color.toHex() ?? "No Hex")
                
                Button("Create") {
                    let newGenre = Genre(name: name, color: color.toHex()!)
                    context.insert(newGenre)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(name.isEmpty)
            }
            .navigationTitle("New Genre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewGenreView()
}

//
//  EditBookView.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import SwiftUI

struct EditBookView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var book: Book
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Info") {
                    TextField("Title", text: $book.title)
                    TextField("Author", text: $book.author)
                }
                
                Section("Status") {
                    Picker("Status", selection: $book.status) {
                        ForEach(Status.allCases) { status in
                            Text(status.desc).tag(status.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                }
                
                Section("Rating") {
                    Stepper(
                        value: Binding(
                            get: { book.rating ?? 0 },
                            set: { book.rating = $0 == 0 ? nil : $0 }
                        ),
                        in: 0...5) {
                            HStack {
                                Text("Rating")
                                Spacer()
                                if let rating = book.rating {
                                    Text("\(rating)/5")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("None")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                }
                
                Section("Summary") {
                    TextEditor(text: $book.synopsis)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Update Book
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let preview = Preview(Book.self)
    return EditBookView(book: Book.sampleBooks[3])
        .modelContainer(preview.continer)
}

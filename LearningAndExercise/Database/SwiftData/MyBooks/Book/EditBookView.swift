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
    @State var showGenre = false
    
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
                
                Section("Recommended By") {
                    TextField("Recommended By", text: $book.recommendedBy)
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
                    
                    NavigationLink {
                        QuoteListView(book: book)
                    } label: {
                        let count = book.quotes?.count ?? 0
                        Label("\(count) Quotes", systemImage: "quote.opening")
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
                
                Section {
                    Button {
                        showGenre.toggle()
                    } label: {
                        Text("Geners")
                    }
                    .foregroundStyle(.black)
                    
                    if let genres = book.genres {
                        ViewThatFits {
                            ScrollView(.horizontal, showsIndicators: false) {
                                GenreStackView(genres: genres)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showGenre, content: {
                GenresView(book: book)
            })
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

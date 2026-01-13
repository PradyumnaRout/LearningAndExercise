//
//  EditBookView.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import SwiftUI
import PhotosUI

struct EditBookView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var book: Book        // Reson why it is @Bindable(Below)
    @State var showGenre = false
    @State private var selectedBookCover: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Book Cover") {
                    PhotosPicker(
                        selection: $selectedBookCover,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Group {
                                if let coverData = book.bookCover,
                                   let uiImage = UIImage(data: coverData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .tint(.primary)
                                }
                            }
                            .frame(width: 75, height: 100)
                            .overlay(alignment: .bottomTrailing) {
                                if book.bookCover != nil {
                                    Button {
                                        selectedBookCover = nil
                                        book.bookCover = nil
                                    } label: {
                                        Image(systemName: "x.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                }
                
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
            .task(id: selectedBookCover, {
                // Run async task with id, when id changes it will execute
                if let data = try? await selectedBookCover?.loadTransferable(type: Data.self) {
                    book.bookCover = data
                }
            })
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




// MARK: Important question about SwiftData @Bindable and @State
/**
 
 🔹 What @Bindable does here
 struct EditBookView: View {
     @Bindable var book: Book
 }


 This means:

 ✔ book is a SwiftData managed model
 ✔ Changes are tracked by SwiftData
 ✔ UI updates automatically
 ✔ Changes are written back to the model context
 ✔ Other views observing the same book update too

 So when you write:

 TextField("Title", text: $book.title)


 You are editing the actual SwiftData object.

 ❌ What happens if you use @State instead?
 struct EditBookView: View {
     @State var book: Book   // ❌ wrong for SwiftData models
 }

 This breaks the SwiftData data flow.

 @State means:

 "This view OWNS this value."

 But your Book is owned by SwiftData, not the view.

 Problems you will get
 1️⃣ State makes a copy of the reference

 SwiftData tracks identity by model context.
 @State stores a local reference that is no longer managed properly.

 2️⃣ Changes may not persist

 SwiftData may not detect changes correctly:

 book.title = "New Title"  // might not save properly

 3️⃣ Other views won't update

 Other views observing the same Book won’t refresh because SwiftUI thinks it's local state.

 4️⃣ Previews and navigation may break

 NavigationStack + SwiftData relies on identity tracking.
 @State breaks that chain.

 🔹 Correct ownership pattern
 Wrapper    Who owns the model?
 @State    The view owns it
 @Bindable    SwiftData owns it
 @Query    SwiftData fetches it
 @Environment(.modelContext)    SwiftData context
 🔹 When is @State allowed with models?

 Only if the model is not SwiftData:

 @Observable
 class DraftBook {
     var title = ""
     var author = ""
 }


 Then:

 @State private var draft = DraftBook()   // fine


 But SwiftData @Model objects must never be @State.
 */

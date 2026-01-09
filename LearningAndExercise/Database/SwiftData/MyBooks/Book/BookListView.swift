//
//  BookListView.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import Foundation
import SwiftUI
import SwiftData

enum SortOrder: LocalizedStringResource, Identifiable, CaseIterable {
    case status, title, author
    
    var id: Self {
        self
    }
}

struct BookListView: View {
    @State private var createNewBook = false
    @State private var sortOrder = SortOrder.status
    @State private var filter = ""
    
    var body: some View {
        NavigationStack {
            BookList(sortOrder: sortOrder, filterString: filter)
            .navigationTitle("My Books")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createNewBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Picker("Sort", selection: $sortOrder) {
                                ForEach(SortOrder.allCases) { sortOrder in
                                    Text(sortOrder.rawValue)
                                        .tag(sortOrder)
                                }
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                        }
                    }
            }
            .sheet(isPresented: $createNewBook) {
                NewBookView()
                    .presentationDetents([.medium])
            }
        }
        .searchable(
            text: $filter,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Filter on title or author"
        )
    }
}

#Preview("English") {
    let preview = Preview(Book.self)
    let books = Book.sampleBooks
    let genres = Genre.sampleGenres
    preview.addExamples(books)
    preview.addExamples(genres)
    return BookListView()
        .modelContainer(preview.continer)
}

#Preview("German") {
    let preview = Preview(Book.self)
    let books = Book.sampleBooks
    let genres = Genre.sampleGenres
    preview.addExamples(books)
    preview.addExamples(genres)
    return BookListView()
        .modelContainer(preview.continer)
        .environment(\.locale, Locale(identifier: "DE"))
}

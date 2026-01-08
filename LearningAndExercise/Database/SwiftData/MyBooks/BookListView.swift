//
//  BookListView.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import Foundation
import SwiftUI
import SwiftData

enum SortOrder: String, Identifiable, CaseIterable {
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

#Preview {
    let preview = Preview(Book.self)
    preview.addExamples(Book.sampleBooks)
    return BookListView()
        .modelContainer(preview.continer)
}

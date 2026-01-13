//
//  BookList.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import SwiftUI
import SwiftData

struct BookList: View {
    @Environment(\.modelContext) private var context
    // Can not use multiple keypath to filter
//    @Query(sort: \Book.status) private var books: [Book]
    @Query private var books: [Book]
    
    init(sortOrder: SortOrder, filterString: String) {
        // Sort
        let sortDescriptor: [SortDescriptor<Book>] = switch sortOrder {
        case .status:
            [SortDescriptor(\Book.status), SortDescriptor(\Book.title)]
        case .title:
            [SortDescriptor(\Book.title)]
        case .author:
            [SortDescriptor(\Book.author)]
        }
        
        // Filter
        let predicate = #Predicate<Book> { book in
            book.title.localizedStandardContains(filterString)
            || book.author.localizedStandardContains(filterString)
            || filterString.isEmpty
        }
            
        // Here _books is a stored one because now the books is not initialized yet so, it is a getonly property now.
        // Because books is just a computed property backed by the wrapper — it doesn’t exist yet.
        // But _books is the actual stored property.
        // so when you write like this, You are replacing the entire query wrapper with a new one.
        _books = Query(filter: predicate, sort: sortDescriptor, animation: .bouncy)
    }
    
    
    var body: some View {
        Group {
            if books.isEmpty {
                ContentUnavailableView("Enter your first book", systemImage: "book.fill")
            } else {
                List {
                    ForEach(books) { book in
                        NavigationLink {
                            EditBookView(book: book)
                        } label: {
                            HStack(spacing: 10) {
                                VStack {
                                    Group {
                                        if let coverData = book.bookCover,
                                           let uiImage = UIImage(data: coverData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .tint(.primary)
                                        }
                                    }
                                    .frame(width: 35, height: 35)
                                    .clipShape(Circle())
                                    book.icon
                                }
                                VStack(alignment: .leading) {
                                    Text(book.title).font(.title2)
                                    Text(book.author).foregroundStyle(.secondary)
                                    Text("Recommended By: \(book.recommendedBy)")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                        .padding(.bottom, 5)
                                    if let rating  = book.rating {
                                        HStack {
                                            ForEach(0..<rating, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .imageScale(.small)
                                                    .foregroundStyle(.yellow)
                                            }
                                        }
                                    }
                                    if let genres = book.genres {
                                        ViewThatFits {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                GenreStackView(genres: genres)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let book = books[index]
                            context.delete(book)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    let preview = Preview(Book.self)
    preview.addExamples(Book.sampleBooks)
    return NavigationStack {
        BookList(sortOrder: .status, filterString: "")
            .modelContainer(preview.continer)
    }
}

//
//  BookMarkSample.swift
//  LearningAndExercise
//
//  Created by hb on 08/01/26.
//

import Foundation

extension Book {
    static let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
    static let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date.now)!
    static var sampleBooks: [Book] = [
        Book(
            title: "The Pragmatic Programmer",
            author: "Andrew Hunt & David Thomas",
            synopsis: "A practical guide to software craftsmanship.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Clean Code",
            author: "Robert C. Martin",
            dateStarted: Date(),
            synopsis: "Best practices for writing clean, maintainable code.",
            rating: 4,
            status: .inProgress,
        ),
        Book(
            title: "Swift Programming",
            author: "Apple Inc.",
            synopsis: "Official guide to the Swift programming language.",
            status: .onShelf
        ),
        Book(
            title: "Design Patterns",
            author: "Erich Gamma et al.",
            dateCompleted: Date(),
            synopsis: "Foundational object-oriented design patterns.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Refactoring",
            author: "Martin Fowler",
            dateStarted: Date(),
            synopsis: "Improving the design of existing code.",
            rating: 4,
            status: .inProgress
        ),
        Book(
            title: "Introduction to Algorithms",
            author: "Thomas H. Cormen",
            synopsis: "Comprehensive algorithms textbook.",
            status: .onShelf
        ),
        Book(
            title: "You Don't Know JS",
            author: "Kyle Simpson",
            dateCompleted: Date(),
            synopsis: "Deep dive into JavaScript fundamentals.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Effective Java",
            author: "Joshua Bloch",
            synopsis: "Best practices for the Java language.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Cracking the Coding Interview",
            author: "Gayle Laakmann McDowell",
            dateStarted: Date(),
            synopsis: "Interview prep for software engineers.",
            status: .inProgress
        ),
        Book(
            title: "The Mythical Man-Month",
            author: "Frederick P. Brooks Jr.",
            synopsis: "Essays on software engineering management.",
            rating: 4,
            status: .completed
        ),
        Book(
            title: "Working Effectively with Legacy Code",
            author: "Michael Feathers",
            synopsis: "Techniques for changing legacy systems safely.",
            status: .onShelf
        ),
        Book(
            title: "Head First Design Patterns",
            author: "Eric Freeman",
            dateStarted: Date(),
            synopsis: "Beginner-friendly approach to design patterns.",
            rating: 4,
            status: .inProgress
        ),
        Book(
            title: "The Clean Coder",
            author: "Robert C. Martin",
            synopsis: "Professionalism and discipline in software development.",
            rating: 4,
            status: .completed
        ),
        Book(
            title: "Algorithms to Live By",
            author: "Brian Christian",
            synopsis: "Applying computer science to everyday decisions.",
            status: .onShelf
        ),
        Book(
            title: "Deep Work",
            author: "Cal Newport",
            dateCompleted: Date(),
            synopsis: "Focused success in a distracted world.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Atomic Habits",
            author: "James Clear",
            synopsis: "Building good habits and breaking bad ones.",
            rating: 5,
            status: .completed
        ),
        Book(
            title: "Grokking Algorithms",
            author: "Aditya Bhargava",
            dateStarted: Date(),
            synopsis: "Visual and intuitive guide to algorithms.",
            status: .inProgress
        ),
        Book(
            title: "Structure and Interpretation of Computer Programs",
            author: "Harold Abelson",
            synopsis: "Classic text on computer science fundamentals.",
            status: .onShelf
        ),
        Book(
            title: "Don't Make Me Think",
            author: "Steve Krug",
            synopsis: "Common-sense approach to usability.",
            rating: 4,
            status: .completed
        ),
        Book(
            title: "The Art of Computer Programming",
            author: "Donald Knuth",
            synopsis: "Definitive multi-volume work on algorithms.",
            status: .onShelf
        )
    ]

}

//
//  SwiftDataServiceView.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftUI

struct SwiftDataServiceView: View {
    @State private var showUserSheet: Bool = false
    @State private var users: [AppUser] = []
    @State private var service: SwiftDataService = SwiftDataService()
    
    var body: some View {
        NavigationStack {
            Group {
                if users.isEmpty {
                    ContentUnavailableView("No user found", systemImage: "magnifyingglass")
                } else {
                    List {
                        ForEach(users) { user in
                            NavigationLink {
                                UserDetailView(user: user, service: service)
                            } label: {
                                Text(user.name)
                                    .font(.title3)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showUserSheet) {
                NewUserView(service: service)
                    .presentationDetents([.medium])
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showUserSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        }
        .task(id: showUserSheet) {
            do {
                users = try service.fetchUser()
            } catch {
                print("Error in creating user")
            }
        }
    }
}

#Preview {
    SwiftDataServiceView()
}

struct NewUserView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var postName: String = ""
    
    let service: SwiftDataService
    
    var body: some View {
        VStack {
            HStack {
                Text("Name")
                
                TextField("Patric", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Post")
                
                TextField("Post", text: $postName)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button("Create") {
                createUser()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
    
    func createUser() {
        Task {
            do {
                let user = try await service.createUser(name: name)
                try service.createPost(title: postName, for: user)
                dismiss()
            } catch {
                print("Error in creating user")
            }
        }
    }
}


struct UserDetailView: View {

    @State var user: AppUser
    let service: SwiftDataService

    @State private var newPostTitle = ""

    var body: some View {
        Form {
            Section("User") {
                TextField("Name", text: $user.name)

                Button("Save Name") {
                    updateUser()
                }
            }

            Section("Posts") {
                ForEach(user.post) { post in
                    PostRow(post: post, service: service)
                }

                HStack {
                    TextField("New post", text: $newPostTitle)

                    Button("Add") {
                        addPost()
                    }
                }
            }
        }
        .navigationTitle("User Detail")
    }

    func updateUser() {
        do {
            try service.updateUser(user, newName: user.name)
        } catch {
            print("Update user error:", error)
        }
    }

    func addPost() {
        do {
            try service.createPost(title: newPostTitle, for: user)
            newPostTitle = ""
        } catch {
            print("Add post error:", error)
        }
    }
}


struct PostRow: View {

    @State var post: UserPost
    let service: SwiftDataService

    var body: some View {
        HStack {
            TextField("Post title", text: $post.title)

            Button("Save") {
                updatePost()
            }
        }
    }

    func updatePost() {
        do {
            try service.updatePost(post, newTitle: post.title)
            print("Post updated successfully.")
        } catch {
            print("Update post error:", error)
        }
    }
}


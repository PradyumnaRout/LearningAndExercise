//
//  UserListView.swift
//  LearningAndExercise
//
//  Created by hb on 07/11/25.
//

import Foundation
import SwiftUI

// 2. UserView - The main view displaying the list and the add button
struct UserView: View {
    // Replace with @FetchRequest for Core Data
    @State private var users: [UserDataModel] = []
    
    @State private var showingAddUserAlert = false
    @State private var showingEditUserAlert = false
    @State private var userToEdit: UserDataModel? // Holds the user being edited
    
    
    // State variables for the alert text fields
    @State private var tempFirstName: String = ""
    @State private var tempLastName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempAge: String = "" // Use String for TextField input
    @State private var tempProfilePic: String = ""
    @State private var tempPlace: String = ""
    
    // Helper to determine the binding for the sheet's isPresented parameter
    private var isSheetActive: Binding<Bool> {
        if showingEditUserAlert {
            return $showingEditUserAlert
        } else {
            return $showingAddUserAlert
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // User List
                List {
                    ForEach($users, id: \.id) { $user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.fullName)
                                    .font(.headline)
                                Text("Place: \(user.place ?? "n/a")")
                                    .font(.subheadline)
                                Text("Age: \(String(describing: user.age ?? 0))) type: \(type(of: user.age))")
                                    .font(.subheadline)
                                Text(user.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            // Edit Button Icon
                            Button {
                                self.userToEdit = user
                                // Pre-fill temp fields with user data
                                self.tempFirstName = user.firstName ?? ""
                                self.tempLastName = user.lastName ?? ""
                                self.tempEmail = user.email ?? ""
                                self.tempAge = String(user.age ?? 0)
                                self.tempProfilePic = user.profilePic ?? ""
                                self.showingEditUserAlert = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                        }
                    }
                    .onDelete(perform: deleteUser) // Optional: Add swipe-to-delete
                }
                .navigationTitle("Users List")
                
                // Floating Plus Button (bottom right)
                Button {
                    // Reset temporary fields for new user
                    self.tempFirstName = ""
                    self.tempLastName = ""
                    self.tempEmail = ""
                    self.tempAge = ""
                    self.tempProfilePic = "person.circle.fill" // Default value
                    self.showingAddUserAlert = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .shadow(radius: 5)
                }
                .padding()
            }
            // ⭐️ FIX: Use a single sheet modifier and combine the presentation logic.
            .sheet(isPresented: Binding(
                get: { self.showingAddUserAlert || self.showingEditUserAlert },
                set: { newValue in
                    if !newValue { // When the sheet is dismissed
                        self.showingAddUserAlert = false
                        self.showingEditUserAlert = false
                        self.userToEdit = nil
                    }
                }
            )) {
                UserFormView(
                    // Pass the correct *active* binding for self-dismissal
                    isPresented: isSheetActive,
                    isEditing: $showingEditUserAlert,
                    userToEdit: $userToEdit,
                    tempFirstName: $tempFirstName,
                    tempLastName: $tempLastName,
                    tempEmail: $tempEmail,
                    tempAge: $tempAge,
                    tempProfilePic: $tempProfilePic,
                    tempPlace: $tempPlace,
                    
                    addUserAction: addUser,
                    editUserAction: editUser
                )
            }
            .task {
                self.users = await CoreDataManager.shared.fetchUsers()
            }
        }
    }
    
    // --- Core Data / Data Management Operations ---
    
    func addUser() {
        // 1. Validate Input
//        guard let age = Int(tempAge) else {
//            print("Invalid Age")
//            // Handle error (e.g., show an error message)
//            return
//        }
        
        // 2. Core Data Operation: Save the new user
        let newUser = UserDataModel(
            firstName: tempFirstName,
            lastName: tempLastName,
            age: Int32(tempAge), email: tempEmail,
            profilePic: tempProfilePic,
            place: tempPlace
        )
        
        // Replace with Core Data 'save' operation
//        users.append(newUser)
        Task {
            await CoreDataManager.shared.persistUserDetails(from: newUser)
            self.users = await CoreDataManager.shared.fetchUsers()
        }
        
        
        // 3. Reset state
        showingAddUserAlert = false
    }
    
    func editUser() {
        guard let index = users.firstIndex(where: { $0.id == userToEdit?.id }) else {
            print("Invalid Data or User Not Found")
            return
        }
        
        // 1. Core Data Operation: Update the existing user
        let newUser = UserDataModel(
            firstName: tempFirstName,
            lastName: tempLastName,
            age: Int32(tempAge), email: tempEmail,
            profilePic: tempProfilePic,
            place: tempPlace
        )
        Task {
            _ = await CoreDataManager.shared.persistUserDetails(from: newUser)
            self.users = await CoreDataManager.shared.fetchUsers()
        }
        // 2. Reset state
        showingEditUserAlert = false
        userToEdit = nil
        
        
    }
    
    func deleteUser(offsets: IndexSet) {
        // 1. Identify users to delete (e.g., by their email, which is assumed unique)
        // We map the IndexSet to the email of the users that were selected for deletion.
        let emailsToDelete = offsets.map { users[$0].email }
        
        // 2. Perform Core Data Deletion
        Task {
            for email in emailsToDelete {
                // Assuming CoreDataManager.shared.deleteUser handles deletion by email
                // (You must define this CoreDataManager/deleteUser implementation)
                await CoreDataManager.shared.deleteUser(with: email ?? "")
            }
        }
        
        // 3. Update the temporary @State array (This is crucial for the UI to update immediately)
        users.remove(atOffsets: offsets)
        
        Task {
            self.users = await CoreDataManager.shared.fetchUsers()
        }
        
        // Note: If you were using @FetchRequest, deleting the NSManagedObject
        // and saving the context would automatically update the list, and you might skip step 3.
    }
}

// 3. Custom Form View for Adding/Editing (Better than Alert for 5 fields)
struct UserFormView: View {
    @Binding var isPresented: Bool
    @Binding var isEditing: Bool
    @Binding var userToEdit: UserDataModel?
    
    @Binding var tempFirstName: String
    @Binding var tempLastName: String
    @Binding var tempEmail: String
    @Binding var tempAge: String
    @Binding var tempProfilePic: String
    @Binding var tempPlace: String
    
    var addUserAction: () -> Void
    var editUserAction: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isEditing ? "Edit User Details" : "New User Details")) {
                    TextField("First Name", text: $tempFirstName)
                    TextField("Last Name", text: $tempLastName)
                    TextField("Place", text: $tempPlace)
                    TextField("Email", text: $tempEmail)
                    TextField("Age", text: $tempAge)
                        .keyboardType(.numberPad)
                    TextField("Profile Pic (e.g., system icon name)", text: $tempProfilePic)
                }
            }
            .navigationTitle(isEditing ? "Edit User" : "Add User")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isEditing {
                            isEditing = false
                            userToEdit = nil
                        } else {
                            isPresented = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        if isEditing {
                            editUserAction()
                        } else {
                            addUserAction()
                        }
                    }
                    .disabled(tempFirstName.isEmpty || tempLastName.isEmpty || tempEmail.isEmpty || tempAge.isEmpty)
                }
            }
        }
    }
}

// Preview Provider (Optional)
#Preview {
    UserView()
}

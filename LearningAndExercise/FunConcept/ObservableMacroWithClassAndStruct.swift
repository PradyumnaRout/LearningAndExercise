//
//  ObservableMacroWithClassAndStruct.swift
//  LearningAndExercise
//
//  Created by hb on 09/02/26.
//

import Foundation
import SwiftUI

// MARK: Scenario 1: UserDetail is a Class
class UserDetailOBSMacro1 {
    var age: Int
    var name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

@Observable
class UserViewModelOBSMacro1 {
    var user = UserDetailOBSMacro1(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
    }
}

struct ContentViewOBSMacro1: View {
    var vm = UserViewModelOBSMacro1()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGOne") {
    ContentViewOBSMacro1()
    /**
     Result: The view will NOT update ❌
     Why? Because user is a reference type (class). When you change user.age, you're modifying the contents of the object, but the user property itself (the reference/pointer) hasn't changed. The @Observable macro tracks changes to the user property, not changes within the object it points to.
     */
}

// MARK: Scenario 2: UserDetail is a Struct
struct UserDetailOBSMacro2 {
    var age: Int
    var name: String
}

@Observable
class UserViewModelOBSMacro2 {
    var user = UserDetailOBSMacro2(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
    }
}

struct ContentViewOBSMacro2: View {
    var vm = UserViewModelOBSMacro2()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGTwo") {
    ContentViewOBSMacro2()
    /**
     Result: The view WILL update ✅
     Why? Because user is a value type (struct). When you change user.age, Swift creates a new copy of the struct with the updated value and assigns it back to user. This means the user property itself changes, which the @Observable macro detects and triggers a view update.
     */
}



// MARK: Solutions for Class-based UserDetail
// If you need UserDetail to be a class, here are your options:
//Option 1: Make UserDetail also @Observable

@Observable
class UserDetailOBSMacro3 {
    var age: Int
    var name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}

@Observable
class UserViewModelOBSMacro3 {
    var user = UserDetailOBSMacro3(age: 20, name: "Pradyumna")
    
    func increaseAge() {
        user.age += 1
        user = user     // Force reassignment to trigger observation
    }
}

struct ContentViewOBSMacro3: View {
    var vm = UserViewModelOBSMacro3()
    
    var body: some View {
        VStack {
            Text("Age: \(vm.user.age)")
            
            Button("Increase Age") {
                vm.increaseAge()
            }
        }
    }
}

#Preview("EGThree") {
    ContentViewOBSMacro2()
}


// MARK: Solutions for Class-based UserDetail - is there any other solution
/*
 Option 3: Manually trigger observation with withObservationTracking
 Actually, the simpler approach is to reassign the user property after mutation:
 swiftclass UserDetail {
     var age: Int
     var name: String
     
     init(age: Int, name: String) {
         self.age = age
         self.name = name
     }
 }

 @Observable
 class UserViewModel {
     var user = UserDetail(age: 20, name: "Pradyumna")
     
     func increaseAge() {
         user.age += 1
         // Trigger change by reassigning - but this is awkward
         let temp = user
         user = temp
     }
 }
 But this is clunky. Here's a better pattern:

 Option 4: Use a computed property wrapper
 swiftclass UserDetail {
     var age: Int
     var name: String
     
     init(age: Int, name: String) {
         self.age = age
         self.name = name
     }
 }

 @Observable
 class UserViewModel {
     private var _user = UserDetail(age: 20, name: "Pradyumna")
     
     var user: UserDetail {
         get { _user }
         set { _user = newValue }
     }
     
     func increaseAge() {
         _user.age += 1
         user = _user  // Trigger observation through setter
     }
 }

 Option 5: Keep individual properties in ViewModel (flatten the model)
 
 @Observable
 class UserViewModel {
     var age: Int = 20
     var name: String = "Pradyumna"
     
     func increaseAge() {
         age += 1
     }
 }

 struct ContentView: View {
     var vm = UserViewModel()
     
     var body: some View {
         VStack {
             Text("Age: \(vm.age)")
             
             Button("Increase Age") {
                 vm.increaseAge()
             }
         }
     }
 }
 This works perfectly and is often the cleanest approach! ✅

 Option 6: Use @ObservationIgnored + manual notification
 
 @Observable
 class UserViewModel {
     @ObservationIgnored private var _user = UserDetail(age: 20, name: "Pradyumna")
     
     var user: UserDetail {
         @storageRestrictions(initializes: _user)
         init(initialValue) {
             _user = initialValue
         }
         get {
             access(keyPath: \.user)
             return _user
         }
         set {
             withMutation(keyPath: \.user) {
                 _user = newValue
             }
         }
     }
     
     func increaseAge() {
         withMutation(keyPath: \.user) {
             _user.age += 1
         }
     }
 }

 My Recommendation:
 For your scenario, the best solutions are:

 Make UserDetail a struct (simplest and most idiomatic)
 Make UserDetail also @Observable (if it needs to be a class)
 Flatten the properties into the ViewModel directly (Option 5)
 */



// MARK: INTRESTING FACT
import SwiftUI

struct UpdateProfileView: View {
    @FocusState private var focus: FocusField?
    
    @State private var viewModel = UpdateProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView(.vertical) {
                VStack {
                    headerImage
                    contentView
                }
                .padding(.top, 50)
            }
            .scrollIndicators(.hidden)
            .padding(.top, -15)
            .zIndex(-1)
        }
    }
    
    //MARK: Header Image
    private var headerImage: some View {
        Image("house")
            .resizable()
            .scaledToFill()
            .frame(width: 135, height: 135)
            .padding(.all, 5)
            .background(
                Circle()
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 0)
            )
            .compositingGroup()
            .overlay(alignment: .bottomTrailing) {
                Image("chevron.right")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 40, height: 44)
                            .foregroundStyle(.blue)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white)
                            .frame(width: 44, height: 48)
                    }
                    .compositingGroup()
                    .offset(x: -5, y: -7)
            }
            .frame(maxWidth: .infinity)
    }
    
    //MARK: Content
    private var contentView: some View {
        VStack {
            DropTextField(
                header: "First Name",
                placeholder: "First Name",
                enableSecureField: false,
                text: $viewModel.userData.firstName,
                isFocused: focus == .firstName
            )
            .focused($focus, equals: .firstName)
            
            DropTextField(
                header: "Last name",
                placeholder: "Last name",
                enableSecureField: false,
                text: $viewModel.userData.lastName,
                isFocused: focus == .lastName
            )
            .focused($focus, equals: .lastName)
            
            DropTextField(
                header: "nick name",
                placeholder: "nick name",
                enableSecureField: false,
                text: $viewModel.userData.nickName,
                isFocused: focus == .nickName
            )
            .focused($focus, equals: .nickName)
            
            DropTextField(
                header: "email",
                placeholder: "email",
                enableSecureField: false,
                text: $viewModel.userData.email,
                isFocused: focus == .email
            )
            .focused($focus, equals: .email)
            
            Text(viewModel.userData.firstName)
            // Here if you run this, you can see, by upadating the first name in the text field will not update the text.
            // As we know @Observable Macro/ Observable Object does not recat to changes inside model class. But in case of the above textfield the change will update the UI, but the text will not update.
            
            // This is because in the textfield case the access started from an observable root. So it will work.
            // But in text case, it will not work.
        }
        
    }
}

#Preview {
    UpdateProfileView()
}

class UpdateModel {
    var firstName: String
    var lastName: String
    var nickName: String
    var email: String
    var phone: String
    var dateOfBirth: String
    var gender: String
    
    init(firstName: String, lastName: String, nickName: String, email: String, phone: String, dateOfBirth: String, gender: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.nickName = nickName
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.gender = gender
    }
}


@Observable
class UpdateProfileViewModel {
    var userData = UpdateModel(
        firstName: "John",
        lastName: "Appleseed",
        nickName: "Johnny",
        email: "john@example.com",
        phone: "1234567890",
        dateOfBirth: "1990-01-01",
        gender: "Male"
    )
        
    func naviateBack() {
    }
}



enum FocusField {
    case nickName
    case firstName
    case lastName
    case email
    case password
    case confPassword
    case addressLine1
    case addressLine2
    case postalCode
    case city
    case stateProvinceRegion
    case country
}


struct DropTextField: View {
    @FocusState private var focus: Bool
    let header: String
    let placeholder: String
    let enableSecureField: Bool
    var disable: Bool = false
    let font: Font = .system(size: 14, weight: .regular)
    let height: CGFloat = 52

    // NEW with defaults
    var trailingImage: Image? = nil
    var trailingAction: (() -> Void)? = nil

    @Binding var text: String
    var isFocused: Bool

    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.blue)
                .padding(.leading, 6)

            ZStack(alignment: .trailing) {
                ZStack {
                    if enableSecureField && !isPasswordVisible {
                        SecureField("", text: $text, prompt: Text(placeholder)
                            .foregroundColor(Color.secondaryFont)
                            .font(.sora(size: 14, weight: .light))
                        )
                        .focused($focus)
                    } else {
                        TextField("", text: $text, prompt: Text(placeholder)
                            .foregroundColor(Color.secondaryFont)
                            .font(.sora(size: 14, weight: .light))
                        )
                        .focused($focus)
                        .disabled(disable)
                    }
                }
                .frame(height: height)
                .padding(.leading)
                .font(font)
                .padding(.trailing, trailingPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isFocused ? Color.blue : Color.gray.opacity(0.8),
                            lineWidth: 2
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(.black.opacity(0.001))
                .contentShape(Rectangle())
                .onTapGesture {
                    focus = true
                }

                HStack(spacing: 8) {
                    if enableSecureField {
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                    }

                    if let trailingImage, let trailingAction {
                        Button {
                            trailingAction()
                        } label: {
                            trailingImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.trailing, 12)
            }
        }
    }

    private var trailingPadding: CGFloat {
        var count = 0
        if enableSecureField { count += 1 }
        if trailingImage != nil { count += 1 }
        return count > 0 ? CGFloat(count) * 32 : 0
    }
}


#Preview {
    DropTextField(
        header: "First name",
        placeholder: "Enter first name",
        enableSecureField: false,
        text: .constant(""), isFocused: false
    )
}

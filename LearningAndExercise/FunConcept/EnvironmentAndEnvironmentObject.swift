//
//  EnvironmentAndEnvironmentObject.swift
//  LearningAndExercise
//
//  Created by hb on 01/01/26.
//

import Foundation
import SwiftUI

// MARK: @Environment vs @EnvironmentObject

//https://manishpathak99.medium.com/difference-between-environment-vs-environmentobject-in-swiftui-61d26926c471
// https://www.avanderlee.com/swiftui/environmentobject/

/*
 
 • Both @Environment and @EnvironmentObject are property wrapper while @Environment keeps values with predefined keys, and @EnvironmentObject keeps arbitary object.
 
 • For example if you need to keep information about User object which includes name, age, gender etc. you need to use @EnvironmentObject, whereas if you would like to keep whether device is in dark or light mode, system local language, calendar preference, edit mode, it is great for using @Environment.
 
 • @Enviromnent is a key/value pair whereas, @EnvironmentObject ia a value idenitfied by its type.
 
 • @Environment(\.locale) var locale: Locale
  
 • @EnvironmentObject var user: User    // is an object where you keep user-related information.

 */

// MARK: @EnvironmentObject:

/*
 
 • It is similar to observable object

 • The model should conform to the ObservableObject protocol.
 
 • We need to mark properties in this model as @Published to notify changes to view which actively using the object.
 
 • Then model should be a class for sure. Because ObservableObject is about identity, not just data. It is designed for shared, long-lived state. And only reference type can provide this.
 
 • No need for default vlaue, because it can read default value form evironment. If object is not available in environment, app will crash
 
 • Another major difference is, say we have 5 views(V1…V5), if we want to pass a object directly from V1 to V5 we could use @EnvironmentObject rather than @ObservedObject. Set data to be passed in V1 and retrieve it in V5(or wherever needed). Code will be much simple.
 
 • So that menas @EnvironmentObject has power to share data to multiple views in hierarcy.
 
 • It will hold only one type of instance at same time environment.
 
 • Its purely based on views. If a parent view sets environment object all its child can make use of it. If another parent view set another env object, their child’s can make us of it. Eg: If you set environment object in your ContentView in SceneDelegate all its child views can make use of it.
 
 */

final class Theme: ObservableObject {
    @Published var primaryColor: Color = .orange
    
    init(primaryColor: Color) {
        self.primaryColor = primaryColor
    }
}

struct EntryView: View {
    // @State private var path: [Int] = []
    @State private var path = NavigationPath()
    @StateObject var currentTheme = Theme(primaryColor: .red)
    @StateObject var currentTheme2 = Theme(primaryColor: .orange)
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(currentTheme.primaryColor)
                    .frame(width: 100, height: 100)
                
                Button("Second") {
                    path.append("SecondView")
                }
                .padding()
                
                Button("Third") {
                    path.append("ThirdView")
                }
                .padding()
            }
            .navigationTitle("Entry View")
            .navigationDestination(for: String.self) { title in
                switch title {
                case "SecondView":
                    SecondView()
                        .environmentObject(currentTheme2)       // // The object closer to the view takes priority over any parent objects.
                case "ThirdView":
                    ThirdView()
                default:
                    EmptyView()
                }
            }
        }
        // The first provided environment object will always take precedence over any following defined environment objects on the same view.
        .environmentObject(currentTheme)        // // The first object takes priority over any following objects.
        .environmentObject(currentTheme2)
    }
}


struct SecondView: View {
    @EnvironmentObject private var currentTheme: Theme
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(currentTheme.primaryColor)
                .frame(width: 200, height: 200)
            
            Button("Change Color") {
                currentTheme.primaryColor = .blue           // It will reload each and every view connected to @EnvironmentObject.
            }
            .padding()
            
        }
        .environmentObject(currentTheme)
    }
}

struct ThirdView: View {
    @EnvironmentObject private var currentTheme: Theme
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(currentTheme.primaryColor)
                .frame(width: 300, height: 300)
        }
    }
}


// MARK: Providing multiple @EnvironmentObjects

/**
 Providing multiple @EnvironmentObjects
 
 @main
 struct MyApp: App {
     @StateObject var userSession = UserSession()
     @StateObject var settings = AppSettings()

     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environmentObject(userSession)
                 .environmentObject(settings)
         }
     }
 }
 
 Consuming multiple environment objects in a view

 struct ContentView: View {
     @EnvironmentObject var userSession: UserSession
     @EnvironmentObject var settings: AppSettings

     var body: some View {
         VStack {
             Text("User: \(userSession.username)")
             Toggle("Dark Mode", isOn: $settings.isDarkMode)
         }
     }
 }

 
 */



// MARK: @Environment:
/*
 
 • We can use this to get system-related values like whether apps are running in light or dark mode, core data's managed object context, size classes, etc...
 
 • We need to provive proper keys to access its value because it holds the same datatype against multiple keys.
 
 • @Environment is value type but @EnvironmentObject is reference type.
 
 • On the other hand there are many predefined @Environment syate-managed environment values. You can also create custom one. It needs to be struct type and conforms to EnvironmentKey
 
 */

struct SunlightKey: EnvironmentKey {
    static var defaultValue: String = "Rectangle"
}

// Not add it to EnvironmentValues as an extension of it
extension EnvironmentValues {
    
    var sunlight: String {
        get { self[SunlightKey.self] }
        set { self[SunlightKey.self] = newValue  }
    }
}

@Observable
class PointValue {
    var value: Double = 10.0
    
    init(value: Double) {
        self.value = value
    }
}


// Use the above like  key/value pair:
struct PointValueKey: EnvironmentKey {
    static var defaultValue: PointValue = PointValue(value: 20.0)
}

// extend environmentValue
extension EnvironmentValues {
    
    var point: PointValue {
        get {
            self[PointValueKey.self]
        } set {
            self[PointValueKey.self] = newValue
        }
    }
}


// Using ObservableObject as Environment
class ScreenType: ObservableObject {
    @Published var type: String
    
    init(type: String) {
        self.type = type
    }
}

struct ScreenTypeKey: EnvironmentKey {
    static var defaultValue = ScreenType(type: "First")
}

extension EnvironmentValues {
    var screenType: ScreenType {
        get {
            self[ScreenTypeKey.self]
        } set {
            self[ScreenTypeKey.self] = newValue
        }
    }
}




// Example Use of Custom Environment
struct CustomEnvironmentUsages: View {
    @Environment(\.sunlight) var sunlight
    
    // Using PointValue as key/value pair for environment
    @Environment(\.point) var pointValueAsKeyValue
    
    // Directly using it as environment
    private var value = PointValue(value: 10.0)
    
    @StateObject var type: ScreenType = ScreenType(type: "First")
    
    @State private var navPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                Text("Starting Shpae: \(sunlight)")
                Text("Point value directly: \(value.value)")
                Text("point Value as key/value: \(pointValueAsKeyValue.value)")
                
                Button("Next Screen") {
                    navPath.append(1)
                }
                .padding()
            }
            .navigationDestination(for: Int.self, destination: { value in
                CustomEnvironmentUsages2()
            })
            .navigationTitle("ScreenOne")
        }
        .environment(value)         // Directly can use. without creating a custom environment key and value as it is @Observable
        .environment(\.point, pointValueAsKeyValue)         // As key value pair.
//        .environment(type)                              // will not allowed in SwiftUI
        .environment(\.screenType, type)
    }
}


struct CustomEnvironmentUsages2: View {
    @Environment(PointValue.self) var value
    @Environment(\.point) var valueAsKeyValue
    @Environment(\.screenType) private var screenType
    
    var body: some View {
        VStack {
            Text("Point value directly: \(value.value)")
            Text("point Value as key/value: \(valueAsKeyValue.value)")
            Text("Screen Type: \(screenType.type)")
            
            Button("Change") {
//                value.value = 20
                screenType.type = "SEC"
            }
            
            NavigationLink("Next") {
                CustomEnvironmentUsages3()
            }
            
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 100, height: 100)
                .foregroundStyle(screenType.type == "SEC" ? .red : .green)
            
            //MARK: BEHAVIOUR OF ENVIRONEMT WITH OBSERVABLEOBJECT AND OBSERVABLE MACRO
            /*
             Here the screenType is of ObservableObject and if I will change its type then you can see the color of the rectangle will not change to red, because here UI will not notify on chnage of screen type.
             
             
             But in case of Observable macro (vaule here), when you change it, the UI will update becasue Observable is attached to UI
             */
        }
        .navigationTitle("Sec Screen")
    }
}

struct CustomEnvironmentUsages3: View {
    @Environment(\.screenType) private var screenType
    
    var body: some View {
        VStack {
            Text("Screen Type: \(screenType.type)")
        }
        .navigationTitle("Third Screen")
    }
}


// MARK: Important : @Entry macro swift
// https://swiftwithmajid.com/2024/07/09/introducing-entry-macro-in-swiftui/
// We can use @Entry macro to replace EnvironmentValues extenstion
// @Entry macro will totally replace the computed property inside EnvironmentValues Extension


public enum UserState {
    public init(hasActiveSubscription: Bool, isEligibleForIntroOffer: Bool) {
        if hasActiveSubscription {
            self = .pro
        } else if isEligibleForIntroOffer {
            self = .new
        } else {
            self = .churned
        }
    }
    
    case new
    case pro
    case churned
}


struct UserStateEnvironmentKey: EnvironmentKey {
    static var defaultValue: UserState = .new
}

extension EnvironmentValues {
    public var userState: UserState {
        get { self[UserStateEnvironmentKey.self] }
        set { self[UserStateEnvironmentKey.self] = newValue }
    }
}

extension EnvironmentValues {
    @Entry var userState2 = UserState.new
    @Entry var screenType2 = ScreenType(type: "First")
}

// Usage:
struct EmtryMacro: View {
    @State var userState = UserState.new
    
    var body: some View {
        VStack {
            Text("Hii")
        }
        .environment(\.userState2, userState)
    }
}

#Preview(body: {
    CustomEnvironmentUsages()
})


// MARK: If I use ObservableObject I have to mark object creation as @StateObject and @ObservedObject. But in case of @Observable how can I identify which one is @StateObejct and which one is @ObservedObject

/*
 Old system (Combine-based) — you had to say who owns it
 @StateObject var model = Model()     // owns it
 @ObservedObject var model: Model     // borrows it


 SwiftUI could not infer ownership, so you had to tell it.

 New system (@Observable) — ownership is implicit

 With @Observable, there is no @StateObject or @ObservedObject.

 Instead, SwiftUI follows this rule:

 🧠 The view that creates the object owns it
 🧠 Any view that receives it does not

 Example 1: View OWNS the object (StateObject equivalent)
 struct ParentView: View {
     @State private var model = PointValue()

     var body: some View {
         ChildView(model: model)
     }
 }


 Here:

 • ParentView owns model

 • @State replaces @StateObject

 • Lifetime is tied to the view

 ✅ This is the StateObject equivalent

 Example 2: View BORROWS the object (ObservedObject equivalent)
 struct ChildView: View {
     let model: PointValue

     var body: some View {
         Text("\(model.value)")
     }
 }


 Here:

 • ChildView does not own model

 • No wrapper needed

 • SwiftUI still observes changes

 ✅ This is the ObservedObject equivalent

 Example 3: Environment injection (most common)
 .environment(PointValue())

 struct AnyView: View {
     @Environment(PointValue.self) var model
 }


 Here:

 • The environment owns the object

 • All child views borrow it

 • No ownership annotations needed

 • This replaces both:

 */


// MARK: .navigationDestination(item: <#T##Binding<Optional<Hashable>>#>, destination: <#T##(Hashable) -> View#>):

/**
 .navigationDestination(item:destination:) is the state-driven (optional-binding) navigation API in NavigationStack.

 It sits between NavigationLink and NavigationPath in terms of power.

 Let’s break it down clearly.

 What this API is
 .navigationDestination(
     item: Binding<T?>,
     destination: (T) -> some View
 )
 where T : Hashable

 Meaning in plain English

 “When this optional value becomes non-nil, navigate to the destination built from it.
 When it becomes nil, pop back.”

 Why this exists

 This solves two common problems:

 ❌ NavigationLink eagerly creates views

 ❌ NavigationPath is overkill for simple flows

 This API gives you:

 ✅ Lazy view creation

 ✅ Simple state-driven navigation

 ✅ No manual path management

 Basic example
 struct ContentView: View {
     @State private var selectedUser: User?

     var body: some View {
         NavigationStack {
             Button("Open User") {
                 selectedUser = User(id: 1)
             }
             .navigationDestination(item: $selectedUser) { user in
                 UserDetailView(user: user)
             }
         }
     }
 }

 What happens
 | Action                     | Result                                  |
 | -------------------------- | --------------------------------------- |
 | `selectedUser = User(...)` | Pushes `UserDetailView`                 |
 | `selectedUser = nil`       | Pops back                               |
 | Back button                | Sets `selectedUser = nil` automatically |

 
 Why this is lazy (important)

 The destination view is NOT created until:

 selectedUser != nil


 Unlike NavigationLink, nothing is built until navigation actually happens.

 ✔ Solves eager-loading issues
 ✔ Perfect for heavy views

 Required constraints
 1️⃣ The item must be Hashable
 struct User: Hashable {
     let id: Int
 }

 2️⃣ It must be optional
 @State private var selectedUser: User?

 Multiple destinations (enum pattern)
 enum Route: Hashable {
     case profile(Int)
     case settings
 }

 @State private var route: Route?

 .navigationDestination(item: $route) { route in
     switch route {
     case .profile(let id):
         ProfileView(id: id)
     case .settings:
         SettingsView()
     }
 }


 This gives:

 One active destination

 One source of truth

 Comparison with other APIs
 | API                            | Lazy | Supports multiple stack | Programmatic | Complexity |
 | ------------------------------ | ---- | ----------------------- | ------------ | ---------- |
 | `NavigationLink`               | ❌    | ❌                       | ❌            | Low        |
 | `navigationDestination(item:)` | ✅    | ❌ (1 level)             | ✅            | Medium     |
 | `NavigationPath`               | ✅    | ✅                       | ✅            | High       |

 When to use this API
 ✅ Perfect for:

 Modal-style push navigation

 One-level drill-down

 “Tap → detail → back”

 Heavy destination views

 ❌ Not good for:

 Multi-step flows

 Deep linking

 Restoring navigation stacks

 Common mistake ❌
 .navigationDestination(item: $user) { _ in
     DetailView()
 }


 If user changes while visible, SwiftUI may re-create the view.

 ✔ Fix: treat item as navigation state, not data storage.

 Mental model 🧠

 Optional value = navigation state
 nil = not on stack
 non-nil = pushed view

 One-line takeaway

 .navigationDestination(item:) is the cleanest lazy navigation API when you only need one active destination.
 */



/**
 struct UserStateEnvironmentKey: EnvironmentKey {
     static var defaultValue: UserState = .new
 }

 extension EnvironmentValues {
     public var userState: UserState {
         get { self[UserStateEnvironmentKey.self] }
         set { self[UserStateEnvironmentKey.self] = newValue }
     }
 }

 extension EnvironmentValues {
     @Entry var userState2 = UserState.new
 }

 
 I want to use both userState and userState2 in a single view, so will it behave different for different values, give an example of that and how one key
 
 
 1️⃣ What userState is (classic EnvironmentKey)
 struct UserStateEnvironmentKey: EnvironmentKey {
     static var defaultValue: UserState = .new
 }

 extension EnvironmentValues {
     var userState: UserState {
         get { self[UserStateEnvironmentKey.self] }
         set { self[UserStateEnvironmentKey.self] = newValue }
     }
 }

 Key points

 UserStateEnvironmentKey is a unique identity

 userState is backed by that specific key

 SwiftUI environment lookup is key-based, not type-based

 So this:

 .environment(\.userState, .loggedIn)


 only affects views that read \Environment(\.userState)

 2️⃣ What userState2 is (@Entry macro)
 extension EnvironmentValues {
     @Entry var userState2 = UserState.new
 }

 Key points

 @Entry generates a brand-new EnvironmentKey under the hood

 That key is not UserStateEnvironmentKey

 Even though:

 same type (UserState)

 same default value (.new)

 They are completely independent environment entries

 Think of it as SwiftUI generating something like:

 struct UserState2EnvironmentKey: EnvironmentKey {
     static let defaultValue = UserState.new
 }


 …but hidden from you.

 3️⃣ Using BOTH in the same view (they can differ)
 struct ContentView: View {
     @Environment(\.userState) var userState
     @Environment(\.userState2) var userState2

     var body: some View {
         VStack {
             Text("userState: \(userState.description)")
             Text("userState2: \(userState2.description)")
         }
     }
 }

 Setting different values
 ContentView()
     .environment(\.userState, .loggedIn)
     .environment(\.userState2, .guest)

 Result
 userState: loggedIn
 userState2: guest


 ✅ They do NOT sync
 ✅ They do NOT override each other
 ✅ They behave independently

 4️⃣ Why one EnvironmentKey cannot be “valid for two”

 This is the crucial rule:

 SwiftUI environment identity is the key type, not the value type

 So even though:

 UserState
 UserState.new


 are identical, the keys are:

 UserStateEnvironmentKey

 (hidden) UserState2EnvironmentKey

 They are different types, so SwiftUI treats them as different slots.
 */

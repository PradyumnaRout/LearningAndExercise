//
//  ImplicitExplicitAnimation.swift
//  LearningAndExercise
//
//  Created by hb on 26/12/25.
//

import Foundation
import SwiftUI
/**
 Implicit Animation
 Explicit Animation
 Transaction
 Animatable
 */
// https://medium.com/@midhlag55/swiftui-animations-the-basics-of-animations-and-transitions-5dfae5ce4268
// https://medium.com/@viralswift/mastering-swiftui-animations-transitions-a-deep-dive-with-examples-41ee4b63c88a
// https://holyswift.app/difference-between-implicit-and-explicit-animations-in-swiftui/
// https://www.swiftwithvincent.com/blog/animation-vs-withanimation-whats-the-difference


//MARK: Implicit Animation in SwiftUI
/**
 • Implicit animation in swift is declared with .animation or .transaction modifier on view branches.
 • Indicating what transaction should be created when the state changes.
 • The transaction can be seen as a context that SwiftUI uses to calculate animations when processing state changes
 • It allows us to declare a scoped animation that will only apply to the view to which it's been attached.
 • So the implicit animation is a locally scoped animation.
 */

struct ImplicitAnimation: View {
    @State private var isExpand: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            RoundedRectangle(cornerRadius: 0)
                .frame(height: isExpand ? 500 : 100)
//                .animation(.default, value: isExpand)   // Locally Scoped / Implicit animation
            // In that case you see in case of expand collapse the size of the rectangle the rectangle is animating properly but the image and text above/below the rectanlge are jumping. That is happening because we only apply the animation scope to the rectangle.
            
            // There is two way to overcome it. one is add the implicit animation to the whole VStack or use explicit animation.
            
            Text("Hello, world!")
            
            Button{
                isExpand.toggle()
            } label: {
                Text("Change Size")
            }.buttonStyle(.borderedProminent)
        }
        .animation(.default, value: isExpand)
        .padding()
    }
}

// MARK: Explicit Animation
/**
 • In explicit animation SwiftUI will start dispatching the transaction produced by the explicit animation starting form the root view no matter the location of the withAnimation.
 • So if you want to update some state and animate everyting on the state change, withAnimation can do that, because it is scoped to the root.
 • If you want to make sure that a view does not get animated by the fuction withAnimation(), the way to do is to use the modifier .transaction() to remove any animation that would be about to be executed, and the view will be opted-out form global animation
 */

struct ExplicitAnimation: View {
    @State private var isExpand: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            RoundedRectangle(cornerRadius: 0)
                .frame(height: isExpand ? 100 : 50)
                .foregroundStyle(.red)
                .transaction { transaction in
                    transaction.animation = nil
                }
            // You can see now the height of the red rectangle is not animating, it is jumpling now.
            
            RoundedRectangle(cornerRadius: 0)
                .frame(height: isExpand ? 100 : 50)
                .foregroundStyle(.blue)
            
            Text("Hello, world!")
            
            Button{
                withAnimation(.default) {
                    isExpand.toggle()
                }
            } label: {
                Text("Change Size")
            }.buttonStyle(.borderedProminent)
        }
        .padding()
    }
}




// MARK: Transaction:
// https://swiftwithmajid.com/2020/10/07/transactions-in-swiftui/
// https://medium.com/@midhlag55/swiftui-animations-the-basics-of-animations-and-transitions-5dfae5ce4268
// https://medium.com/@viralswift/mastering-swiftui-animations-transitions-a-deep-dive-with-examples-41ee4b63c88a
/**
 https://fatbobman.com/en/posts/mastering-transaction/
 What is the difference between .animation and .transaction modifiers?
 
 The .animation modifier is a convenient version of the .transaction modifier. Similarly, withAnimation for “explicit animations” is a convenient version of withTransaction.
 
 For example, we can create a version of the .animation modifier that is associated with specific values for iOS 13 using the following code.
 
 
 What is Transaction?
 
 Transaction is a context of the current state-processing update. SwiftUI creates a transaction for every state change. Transaction contains the animation that SwiftUI will apply during the state chagne and the property indicating wehenever this transaction disables all the animations defined by the child view.
 
 
• Use Transactoin when you need full control over animation
• When you want to override the animation created by .animation or withAnimation.
 */

struct AnimatedView: View {
    let scale: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .scaleEffect(scale)
            .animation(.spring)
    }
}

// As we know, animation modifier applies animation to all the child views of the applied view. Apple suggests us to use this modifier on leaf views rather than container views. This approach allows us to specify animation only for the views that we need.

struct TransactionAnimatedView: View {
    @State private var scale = false
    
    var body: some View {
        AnimatedView(scale: scale ? 0.5 : 1)
            .onTapGesture {
                scale.toggle()
            }
    }
}

// Using animation modifier on child view has one downside. We can't control that animation. For example we are not able to replace the spring animation with a linear one. This is where we can use transactions to override animations defined in child view.


struct TransactionAnimatedView2: View {
    @State private var scale = false
    
    var body: some View {
        AnimatedView(scale: scale ? 0.5 : 1)
            .onTapGesture {
                var transaction = Transaction(animation: .linear)
                transaction.disablesAnimations = true
                
                withTransaction(transaction) {
                    scale.toggle()
                }
            }
    }
}

// As you can see in the example above, we use the withTransaction function to wrap our mutations with a custom transaction. The new transaction disables all the animations defined inside a view hierarchy and enables a linear animation.

//MARK:  Transaction Modifier:
// Now we know how to create a custom transaction for a complete view hierarchy. There is also a way to modify the current transaction for a concrete view using the transaction modifier. Let’s see how we can use it.

struct TransactionModifier: View {
    @State private var scale = false
    
    var body: some View {
        VStack {
            AnimatedView(scale: scale ? 0.5 : 1)
//                .transaction { transaction in                 // Implict transaction
//                    transaction.animation = .spring()
//                }
            
            AnimatedView(scale: scale ? 0.5 : 1)
//                .transaction { transaction in                 // Implict transaction
//                    transaction.disablesAnimations = true
//                }
        }.onTapGesture {
            // Explicit Transaction
            var transaction = Transaction(animation: .interactiveSpring)
            transaction.disablesAnimations = true
            
            withTransaction(transaction) {
                scale.toggle()
            }
        }
    }
}
// The transaction modifier accepts a closure with the inout instance of Transaction struct. We can modify the current transaction inside this closure as we need it. In the example above, we completely disable animations for one view and replace animation for another view.


struct OverrideAnimation: View {
    @State private var isZoomed = false
    
    var body: some View {
        VStack {
            // Explicit Transaction.
//            Button("Toggle Zoom") {
//                var transaction = Transaction(animation: .linear)
//                transaction.disablesAnimations = true
//                
//                withTransaction(transaction) {
//                    isZoomed.toggle()
//                }
//            }
            
            Button("Toggle Zoom") {
                isZoomed.toggle()
            }
            
            Spacer()
                .frame(height: 100)
            
            Text("Zoom Text")
                .font(.title)
                .scaleEffect(isZoomed ? 3 : 1)
                .animation(.easeInOut(duration: 2), value: isZoomed)
                .transaction { transaction in       // Implicit transaction
                    transaction.disablesAnimations = true
                    transaction.animation = .linear
                }
        }
    }
}


// MARK: Transition:
// Transitions in SwiftUI control how views enter or exit the view hierarchy. You can apply transitions to individual views or to entire view hierarchies.


// MARK: Animatable / AnimatablePair
// https://digitalbunker.dev/mastering-animatable-and-animatablepair-swiftui/   (Recommended)
// https://swiftwithmajid.com/2025/07/08/introducing-animatable-macro-in-swiftui/   (Animatable Macro)
// https://fatbobman.com/en/posts/animatable-protocol-taming-unruly-swiftui-animation/  (A advance example)

/**
 /// A type that describes how to animate a property of a view.
 @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
 public protocol Animatable {

     /// The type defining the data to animate.
     associatedtype AnimatableData : VectorArithmetic

     /// The data to animate.
     var animatableData: Self.AnimatableData { get set }
 }
 */

struct SimpleRectangle: Shape, Animatable {
    var width: CGFloat
    var height: CGFloat
    
    // Ultimately, I want to animate the width and height together, but I can only return one value (i.e. var animatableData: Double). So, let's see what happens when I modify just the width:
    // With this addition, we finally have animation, but you'll notice that the change to the height is applied immediately and then the width is animated. Progress, I guess?
    // We're heading in the right direction, but since Animatable will only allow us to return one value - either width or height - we'll have to use another solution to animate these properties in sync.
    // Here AnimatablePair Comes into picture
    
    // If we want to synchronize the animation of the multiple properties together, we need to use AnimationPair instead:
    /**
    var animatableData: Double {
        get { width }
        set { width = newValue }
    }
     */
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(width, height)
        } set {
            width = newValue.first
            height = newValue.second
        }
    }
    // Great! The width and height are finally animating together!
    // Now, that we have a way of synchronizing the animation of 2 properties, we can start to build some really cool animations.
    // If you find yourself needing to synchronize more than 2 properties, you can extend AnimatablePair like this:
    
    /**
     var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
         get {
             AnimatablePair(AnimatablePair(width, height), labelScale)
         }
         set {
             width = newValue.first.first
             height = newValue.first.second
             someOtherProperty = newValue.second
         }
     }
     */
        
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: (rect.width - width) / 2, y: (rect.height - height) / 2, width: width, height: height))
        return path
    }
}

struct AnimatablePredefinedObject: View {
    @State private var width: CGFloat = 50
    @State private var height: CGFloat = 50
    
    var body: some View {
        // Luckily for us, all Shape's in SwiftUI already conform to Animatable
        RoundedRectangle(cornerRadius: 0)
            .fill(.blue)
            .frame(width: width, height: height)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 2.0)) {
                    width = CGFloat.random(in: 50...250)
                    height = CGFloat.random(in: 50...250)
                }
            }
    }
}

struct AnimatableCustomObject: View {
    @State private var width: CGFloat = 50
    @State private var height: CGFloat = 50
    
    var body: some View {
        SimpleRectangle(width: width, height: height)
            .fill(.blue)
            .onTapGesture {
                // In custom object Animatable will not work. Because custom shape does not confirm Animatable Protocol.
                // To handle this, we need to use the Animatable protocol to explicitly tell SwiftUI how to interpolate these properties.
                // all we need to do is tweak the implementation of animatableData.
                withAnimation(.easeInOut(duration: 2.0)) {
                    width = CGFloat.random(in: 50...250)
                    height = CGFloat.random(in: 50...250)
                }
            }
    }
}


//MARK: Morphing Shapes:
struct MorphingShape: Shape, Animatable {
    var size: CGFloat
    var cornerRadius: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(size, cornerRadius)
        } set {
            size = newValue.first
            cornerRadius = newValue.second
        }
    }
        
    func path(in rect: CGRect) -> Path {
        let adjustedSize = min(size, rect.width, rect.height)
        let rect = CGRect(
            x: (rect.width - adjustedSize) / 2,
            y: (rect.height - adjustedSize) / 2,
            width: adjustedSize,
            height: adjustedSize
        )
        return Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
}


struct MorphingShapeTest: View {
    @State private var size: CGFloat = 100
    @State private var cornerRadius: CGFloat = 50
    
    var body: some View {
        MorphingShape(size: size, cornerRadius: cornerRadius)
            .fill(.green)
            .frame(width: 200, height: 200)
            .onTapGesture {
                withAnimation(
                    .spring(
                        duration: 1.0,
                        bounce: 0.5,
                        blendDuration: 1.0
                    )) {
                        size = CGFloat.random(in: 50...150)
                        cornerRadius = CGFloat.random(in: 0...75)
                    }
            }
    }
}


// MARK: Synchronizing Text:

// As we have already seen, there are several types of animation and trnasitions that do not have built-in interpolation mechanism in SwiftUI and require the implementatino of the Animatable Protocol.

// • Custom Shapes: If you create custom shapes with properties that need to animate(eg: path points), you need to conform to Animatable to provide smooth transitions.

// • Complex Property Combinations: When you have mutliple properties that need to animate together, such as the position and size of a shape, or the corner radius and shadow of a view.

// • Non0Numeric Properties: Properties that are not inherently numeric, such as color components or certiain enum values, require custom interpolation.

// • Non-Standard Animation: Any non standard or complex animation that involve more than simple position, size, rotation, or opacity changes typically require Animatable.

// In this example, we aim to animate changes to the Text component's content.
// Without using Animatable or AnimatablePair, SwiftUI defaults to a fade animation, which looks clunky:

// We can apply Animatable using a ViewModifier alos.



struct AnimatableTextView: View, Animatable {
    var value1: Double
    var value2: Double
    
    // Without using Animatable or AnimatablePair, SwiftUI defaults to a fade animation, which looks clunky:
    // Once we add Animatable and AnimatablePair, the animation looks much better, as SwiftUI can now use animatableData to accurately interpolate between the starting and ending values:
    
    // Animatable may not work with Int, because Animatable macro only works with types conforming to the VectorArithmetic protocol.
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(value1, value2)
        } set {
            value1 = newValue.first
            value2 = newValue.second
        }
    }

    var body: some View {
        VStack {
            Text(String(format: "%.2f", value1))
                .padding()
                .foregroundStyle(.red)
            Text(String(format: "%.2f", value2))
                .padding()
                .foregroundStyle(.blue)
        }
        .font(.largeTitle)
    }
}

struct ContentAnimatableText: View {
    @State private var value1: Double = 0.0
    @State private var value2: Double = 0.0
    @State private var animate: Bool = false
    
    var body: some View {
        VStack {
            AnimatableTextView(value1: value1, value2: value2)
            
            Button("Animate Values") {
                withAnimation(.easeInOut(duration: 3)) {
                    value1 = animate ? 100.0 : 0.0
                    value2 = animate ? 200.0 : 0.0
                }
                animate.toggle()
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}



// MARK: Animatable Macro:
// Let create the previous example using Animatable Macro

// By default, the Animatable macro tries to animate all the stored properties of the type, but you can exclude some of them by using the AnimatableIgnored macro.

//@Animatable
struct AnimatableMacroTextView: View {
    var value1: Float
    var value2: Float
    
//    @AnimatableIgnored
    var title: String
    
    var body: some View {
        VStack {
            
            Text(title)
                .padding()
                .font(.headline)
            
            Text(String(format: "%.2f", value1))
                .padding()
                .foregroundStyle(.red)
            Text(String(format: "%.2f", value2))
                .padding()
                .foregroundStyle(.blue)
        }
        .font(.largeTitle)
    }
}


struct ContentAnimatableTextUsingMacro: View {
    @State private var value1: Float = 0.0
    @State private var value2: Float = 0.0
    @State private var title: String = "Hello World"
    @State private var animate: Bool = false
    
    var body: some View {
        VStack {
            AnimatableMacroTextView(value1: value1, value2: value2, title: title)
            
            Button("Animate Values") {
                withAnimation(.easeInOut(duration: 3)) {
                    value1 = animate ? 100.0 : 0.0
                    value2 = animate ? 200.0 : 0.0
                    title = "Hii"
                }
                animate.toggle()
            }
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}



// MARK: Animatable Modifier
struct ProgressScaleModifier: AnimatableModifier {
    var progress: CGFloat   // 0 → 1 (or any range you want)

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(0.5 + progress * 0.5) // example effect
            .opacity(progress)
    }
}


struct MultiProgressModifier: AnimatableModifier {
    var x: CGFloat
    var y: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(x, y) }
        set {
            x = newValue.first
            y = newValue.second
        }
    }

    func body(content: Content) -> some View {
        content.offset(x: x, y: y)
    }
}


/*
 ❌ What is NOT animatable

 Color
 String
 Bool
 Arrays
 Structs without animatableData

 Only numeric types or AnimatablePair trees work:

 CGFloat
 Double
 Angle
 CGSize
 CGRect
 AnimatablePair
 */





#Preview {
    ContentAnimatableText()
}

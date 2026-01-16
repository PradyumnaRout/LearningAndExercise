//
//  GeometryReaderDetail.swift
//  LearningAndExercise
//
//  Created by hb on 13/01/26.
//

import SwiftUI

/**
 | Property                  | Description                    |
 | ------------------------- | ------------------------------ |
 | `geometry.size`           | Width & height available       |
 | `geometry.frame(in:)`     | Position in a coordinate space |
 | `geometry.safeAreaInsets` | Safe area values               |

 */
// MARK: 1️⃣ GeometryReader as a View (Inside Layout)
// ⚠️ Important Behavior: GeometryReader always expands to all available space.
// It does not size itself to its content — it takes as much space as its parent allows.
struct GeometryReaderAsView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text("Width: \(geo.size.width)")
                Text("Height: \(geo.size.height)")
                
                Circle()
                    .frame(width: 100, height: 100)
                    .position(x: geo.size.width / 2,
                              y: geo.size.height / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.2))
        }
    }
}



// MARK: 2️⃣ GeometryReader in Background
// Using GeometryReader as a background is extremely common for measuring a view's size without affecting layout.
// Why?
// A normal GeometryReader expands and breaks layout.
// A background GeometryReader does not affect layout.


// Here
// GeometryReader sits behind the Text
// It reads the actual size of the Text
// It does NOT change layout
struct BackgroundGeometryReader: View {
    @State private var width: CGFloat = 0
    
    var body: some View {
        Text("Hello Geometry")
            .padding()
            .background(
                GeometryReader(content: { geo in
//                    Color.clear
//                        .onAppear {
//                            width = geo.size.width
//                        }
                    // Responsive use:
                    RoundedRectangle(cornerRadius: geo.size.height / 2)
                        .fill(Color.blue)
                })
            )
            .overlay(
                Text("Width: \(Int(width))")
                    .foregroundColor(.red)
                    .padding(.top, 150)
            )
    }
}


// MARK: 3️⃣ GeometryReader in Overlay
// Overlay works the same way as background but places the geometry on top.
// Example: Overlay Badge Positioned with Geometry

struct OverlayGeometryReader: View {
    var body: some View {
        Text("Inbox")
            .padding()
            .background(Color.gray.opacity(0.2))
            .overlay(
                GeometryReader { geo in
                    Text("5")
                        .font(.caption)
                        .padding(6)
                        .background(Color.red)
                        .clipShape(Circle())
                        .position(
                            x: geo.size.width - 10,
                            y: 10
                        )
                }
            )
    }
}

// ✅ Use background/overlay GeometryReader for measurements
// ✅ Avoid nesting many GeometryReaders (performance)
// ✅ Prefer .frame(maxWidth: .infinity) over GeometryReader when possible
// ✅ Use it only when dynamic layout info is required


// Key Takeaway

// ✅ GeometryReader in overlay is a safe and recommended way to measure size
// ✅ It avoids layout expansion problems
// ✅ It gives exact rendered dimensions


//MARK:  Why GeometryReader Sometimes Fails in Background or Overlay
//Case 1 — Background Returns .zero but Overlay Works

// Happens when:
// View has no intrinsic size yet
// View is lazily loaded
// View is conditionally rendered
// View is inside a List, LazyVStack, ScrollView

/**
 Text("Hello")
     .background(
         GeometryReader { geo in
             Color.red.opacity(0.2)
                 .onAppear {
                     print("Background:", geo.size)
                 }
         }
     )

 Sometimes prints: Background: (0.0, 0.0)
 
 But overlay works:
 Text("Hello")
     .overlay(
         GeometryReader { geo in
             Color.blue.opacity(0.2)
                 .onAppear {
                     print("Overlay:", geo.size)
                 }
         }
     )

 Why?

 Some views resolve their size after background is attached.
 Overlay is attached later in the rendering pipeline.

 So overlay sees the final size, background sees an early pass.
 */

// Case 2 — Overlay Returns .zero but Background Works
// This happens when:

// Overlay content is conditionally hidden
// Overlay is clipped
// Overlay is inside mask
// Overlay is inside compositingGroup
/**
 Text("Hello")
     .overlay(
         GeometryReader { geo in
             Color.clear
                 .onAppear {
                     print("Overlay:", geo.size)
                 }
         }
         .hidden()   // ❌ collapses overlay layout
     )
 Hidden overlays collapse to zero.
 Background still works.
 */

// MARK: Animations & Transitions
// Use this pattern for maximum reliability:
/*
 .overlay(
     GeometryReader { geo in
         Color.clear
             .allowsHitTesting(false)
             .onAppear {
                 print("Size:", geo.size)
             }
             .onChange(of: geo.size) { newSize in
                 print("Updated:", newSize)
             }
     }
 )
 */

// Why overlay?
// Attached after layout
// Works better in lazy stacks
// More stable during animations


// MARK: 🔒 Even More Reliable: PreferenceKey (Apple’s Pattern)
// Apple internally uses this
/*
 struct SizeKey: PreferenceKey {
     static var defaultValue: CGSize = .zero
     static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
         value = nextValue()
     }
 }

 Text("Hello")
     .background(
         GeometryReader { geo in
             Color.clear
                 .preference(key: SizeKey.self, value: geo.size)
         }
     )
     .onPreferenceChange(SizeKey.self) { size in
         print("Final size:", size)
     }
 
 ➡️ This waits until layout stabilizes.
 */


struct ExampleGeometryReader: View {
    @State private var height: CGFloat = 0.0
    @State private var width: CGFloat = 0.0
    @State private var scollOffset: CGFloat = 0.0
    
    var body: some View {
        ScrollView(.vertical) {
            //MARK: You can place it to top for better offset change
            /*
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        height = geo.size.height
                        width = geo.size.width
                        scollOffset = geo.frame(in: .named("scroll")).minY
                    }
                    .onChange(of: geo.frame(in: .named("scroll")).minY) { oldValue, newValue in
                        scollOffset = geo.frame(in: .named("scroll")).minY
                    }
            }
            .frame(height: 1)
             */
            
            
            VStack {
                ForEach(0...20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.cyan.opacity(0.3))
                        .frame(height: 200)
                }
            }
            .overlay(alignment: .top){
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { oldValue, newValue in
                            height = geo.size.height
                            width = geo.size.width
                            scollOffset = geo.frame(in: .named("scroll")).minY
                        }
                }
                .frame(height: 1)
            }
            .padding()
        }
        .coordinateSpace(name: "scroll")
        .overlay {
            VStack {
                Text("Height:: \(height)")
                Text("Width:: \(width)")
                Text("y Position:: \(scollOffset)")
            }
            .foregroundStyle(.black)
        }
    }
}


#Preview {
//    ExampleGeometryReader()
    MyView()
}


// MARK: Global and Custom Coordinate Space
struct CoordinateSpace: View {
    var body: some View {
//        GeometryReader { geo in
//            Text("Hello")
//                .onAppear {
//                    print(geo.frame(in: .global))
//                    // (x: 0.0, y: 62.0, width: 402.0, height: 778.0)
//                }
//        }
        
        
        ScrollView {
            VStack {
                GeometryReader { geo in
                    Text("Hello")
                        .onAppear {
                            print(geo.frame(in: .named("MoodSpace")))
                            // (x: 0.0, y: 0.0, width: 402.0, height: 100.0)
                        }
                }
                .frame(height: 100)
            }
        }
        .coordinateSpace(name: "MoodSpace")
    }
}


// MARK: SCROLL VIEW OFFSET READER
//https://danielsaidi.com/blog/2023/02/06/adding-scroll-offset-tracking-to-a-swiftui-scroll-view

enum ScrollOffsetNameSpace {
    static let nameSpace = "scrollView"
}

struct ScrollOffsetPreferenceKeys: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value = nextValue()
    }
}


struct ScrollViewOffsetTracker: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKeys.self,
                    value: geo.frame(in: .named(ScrollOffsetNameSpace.nameSpace))
                        .origin
                )
        }
        .frame(height: 0)
    }
}


private extension ScrollView {
    func withOffsetTracking(action: @escaping (_ offset: CGPoint) -> Void) -> some View {
        self
            .coordinateSpace(name: ScrollOffsetNameSpace.nameSpace)
            .onPreferenceChange(ScrollOffsetPreferenceKeys.self, perform: action)
    }
}

// We can now put things together by using the offset tracking view and the scroll extension:

/*
 ScrollView(.vertical) {
     ZStack(alignment: .top) {
         ScrollViewOffsetTracker()
         // Insert scroll view content here
     }
 }
 .withOffsetTracking(action: { print("Offset: \($0)") })
 */

// The offset is now continuously sent to the action as the scroll view is scrolled. You can use this to fade out content in the header, present additional views, etc.


public struct ScrollViewWithOffset<Content: View>: View {

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll ?? { _ in }
        self.content = content
    }

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onScroll: ScrollAction
    private let content: () -> Content

    public typealias ScrollAction = (_ offset: CGPoint) -> Void

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                ScrollViewOffsetTracker()
                content()
            }
        }
        .withOffsetTracking(action: onScroll)
    }
}

// You can then just use ScrollViewWithOffset instead of having to specify all required components every time you want to use offset tracking:

struct MyView: View {

    @State
    private var scrollOffset: CGPoint = .zero
    
    var body: some View {
        NavigationView {
            ScrollViewWithOffset(onScroll: handleScroll) {
                LazyVStack {
                    ForEach(1...100, id: \.self) { _ in
                        Divider()
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.2))
                            .frame(height: 100)
                    }
                }
            }.navigationTitle("offsetTitle")
                .overlay {
                    Text("\(self.scrollOffset)")
                }
        }
    }

    func handleScroll(_ offset: CGPoint) {
        self.scrollOffset = offset
        print("Offset:: \(offset)")
    }
}

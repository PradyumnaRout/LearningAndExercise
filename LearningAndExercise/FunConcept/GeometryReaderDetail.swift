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

#Preview {
    OverlayGeometryReader()
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

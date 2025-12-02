//
//  DragGesture.swift
//  LearningAndExercise
//
//  Created by hb on 25/11/25.
//
//https://www.hackingwithswift.com/books/ios-swiftui/how-to-use-gestures-in-swiftui

//https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/

import SwiftUI

struct DragGestureTansition: View {
    
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
//    @State private var fingerLocation: CGPoint? // 1
    @GestureState private var fingerLocation: CGPoint? = nil
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.location = value.location
            }
    }
    
    var fingerDrag: some Gesture { // 2
        DragGesture()
//            .onChanged { value in
//                self.fingerLocation = value.location
//            }
//            .onEnded { value in
//                self.fingerLocation = nil
//            }
        
        // Reset finger location automatically on ended. As it is @GestureState.
            .updating($fingerLocation) { value, fingerLocation, transaction in
                fingerLocation = value.location
            }
    }
    
    var body: some View {
        ZStack { // 3
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.pink)
                .frame(width: 100, height: 100)
                .position(location)
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag) // 4
                )
            if let fingerLocation = fingerLocation { // 5
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
    }
}

struct DragGestureExample2: View {
    
    @State private var offset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero
    
    let boxHeight: CGFloat = 500
    let boxWidth: CGFloat = 300
    let rectSize: CGFloat = 100
    
    // How far the rectangle is allowed to move
    var maxOffsetHeight: CGFloat { (boxHeight - rectSize) / 2 }
    var maxOffsetWidth: CGFloat { (boxWidth - rectSize) / 2 }
    
    var dragOne: some Gesture {
        DragGesture()
            .onChanged { value in
//                offset = CGSize(
//                    width: baseOffset.width + value.translation.width,
//                    height: baseOffset.height + value.translation.height
//                )
                
                // 1. Compute the new unbounded offset
                var newOffset = CGSize(
                    width: baseOffset.width + value.translation.width,
                    height: baseOffset.height + value.translation.height
                )
                
                // 2. Clamp (keep inside bounds)
                newOffset.width = min(max(newOffset.width, -maxOffsetWidth), maxOffsetWidth)
                newOffset.height = min(max(newOffset.height, -maxOffsetHeight), maxOffsetHeight)
                
                // 3. Apply
                offset = newOffset
                
            }
            .onEnded { _ in
                baseOffset = offset
            }
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.green)
            .frame(width: rectSize, height: rectSize)
            .offset(offset)
            .gesture(dragOne)
    }
}

//struct DragGestureExample2_iOS18: View {
//    @State private var offset: CGSize = .zero
//    @State private var baseOffset: CGSize = .zero
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 5)
//            .fill(.green)
//            .frame(width: 100, height: 100)
//            .offset(offset)
//            .gesture(SwiftUI.DragGesture())
//            .onGesture(SwiftUI.DragGesture.self) { event in
//                switch event.phase {
//                case .began(let v):
//                    // optional: can use v.startLocation if needed
//                    break
//                case .active(let v):
//                    offset = CGSize(
//                        width: baseOffset.width + v.translation.width,
//                        height: baseOffset.height + v.translation.height
//                    )
//                case .ended(_):
//                    baseOffset = offset
//                case .cancelled:
//                    offset = baseOffset
//                @unknown default:
//                    break
//                }
//            }
//    }
//}

#Preview {
    DragGestureExample2()
}

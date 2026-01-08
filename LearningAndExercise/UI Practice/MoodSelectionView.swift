//
//  MoodSelectionView.swift
//  LearningAndExercise
//
//  Created by hb on 07/01/26.
//

import SwiftUI

enum Emotions: String, Identifiable, CaseIterable {
    
    case cowBoy = "Cowboy"
    case angry = "Angry"
    case grinning = "Grinning"
    case worried = "Worried"
    
    var id: String {
        self.rawValue
    }
}

struct MoodSelectionView: View {
    @Namespace private var ns
    @State private var rectFrame: CGRect = .zero
    @State private var hStackFrame: CGRect = .zero
    @State private var emojiFrames: [Emotions: CGRect] = [:]
    @State private var selectedMood: Emotions? = .cowBoy
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .overlay(alignment: .bottom) {
                    Image("Board")
                        .resizable()
                        .frame(height: UIScreen.main.bounds.height * 0.85)
                }
                .ignoresSafeArea()
            
            VStack(spacing: 100) {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.opacity(0.0))
                    .frame(width: 150, height: 150)
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    rectFrame = geo.frame(in: .named("MoodSpace"))
                                    print("Rectangle onAppear:", rectFrame)
                                    print("Rect MidX: \(rectFrame.midX)")
                                    print("Rect MidY: \(rectFrame.midY)")

                                }
                                .preference(
                                    key: RectFrameKey.self,
                                    value: geo.frame(in: .named("MoodSpace"))
                                )
                        }
                    )
                
                HStack(spacing: 40) {
                    ForEach(Emotions.allCases, id: \.id) { mood in
                        emojiView(for: mood)
                    }
                }
            }
            .padding()
            .coordinateSpace(name: "MoodSpace")

        }
    }

    @ViewBuilder
    private func emojiView(for mood: Emotions) -> some View {
        ZStack {
            Image(mood.rawValue)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 50, height: 50)
                .onTapGesture {
                    if selectedMood == mood {
                        withAnimation(.bouncy(duration: 0.5)) {
                            selectedMood = nil
                        }
                    } else {
                        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.05)) {
                            selectedMood = mood
                        }
                    }
                }
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                hStackFrame = geo.frame(in: .named("MoodSpace"))
                                emojiFrames[mood] = geo.frame(in: .named("MoodSpace"))
                                print("HStack onAppear:", hStackFrame)
                            }
                            .preference(
                                key: HStackFrameKey.self,
                                value: geo.frame(in: .named("MoodSpace"))
                            )
                    }
                )
                .background {
                    VStack {
                        Image(mood.rawValue)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text(mood.rawValue)
                    }
                    .opacity(mood == selectedMood ? 1.0 : 0.0)
                    .frame(
                        width: mood == selectedMood ? 150 : 0,
                        height: mood == selectedMood ? 150 : 0
                    )
                    .offset(
                        x: mood == selectedMood ? rectFrame.midX - (emojiFrames[mood]?.midX ?? 0) : 0,
                        y: mood == selectedMood ? rectFrame.midY - (emojiFrames[mood]?.midY ?? 0) : 0
                    )
                    
                }
            
            if selectedMood == mood {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 95)
                    .matchedGeometryEffect(id: "selection", in: ns)
                    .zIndex(-1)
            }
        }
    }
}


struct RectFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct HStackFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

//        .onPreferenceChange(RectFrameKey.self) { value in
//            rectFrame = value
//            print("Rectangle:", rectFrame)
//        }
//        .onPreferenceChange(HStackFrameKey.self) { value in
//            hStackFrame = value
//            print("HStack:", hStackFrame)
//        }


#Preview {
    MoodSelectionView()
}


/**
 VStack(alignment: .center, spacing: 50) {
     ZStack {
         RoundedRectangle(cornerRadius: 120)
             .frame(width: 120, height: 120)
             .foregroundStyle(.gray.opacity(0.4))
         if animate {
             Image(selectedMood.rawValue)
                 .resizable()
                 .aspectRatio(1, contentMode: .fit)
                 .frame(width: width, height: height)
                 .matchedGeometryEffect(id: "mood", in: animation)
         }
     }
     
     ZStack {
         RoundedRectangle(cornerRadius: 20)
             .frame(width: 50, height: 50)
             .foregroundStyle(.gray.opacity(0.4))
         if !animate {
             Image(selectedMood.rawValue)
                 .resizable()
                 .aspectRatio(1, contentMode: .fit)
                 .frame(width: width, height: height)
                 .matchedGeometryEffect(id: "mood", in: animation)
         }
     }
     Button("animate") {
         withAnimation {
             animate.toggle()
             if animate {
                 width = 120
                 height = 120
             } else {
                 width = 50
                 height = 50
             }
         }
     }

 */


enum SelectedCirlce: String, CaseIterable {
    case first, second, third, four
    
    var id: String {
        self.rawValue
    }
}


struct SelectedCircleView: View {
    @Namespace private var ns
    @State private var selectedCircle: SelectedCirlce = .first

    var body: some View {
        HStack(spacing: 30) {
            ForEach(SelectedCirlce.allCases, id: \.id) { circle in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 40, height: 40)

                    if selectedCircle == circle {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black)
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "selection", in: ns)
                    }
                }
                .onTapGesture {
                    withAnimation(.bouncy) {
                        selectedCircle = circle
                    }
                }
            }
        }
    }
}

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-synchronize-animations-from-one-view-to-another-with-matchedgeometryeffect

struct MatchedGeometryExampleOne: View {
    @Namespace private var namespace
    @State private var toggle: Bool = false
    
    var frame: Double {
        toggle ? 300 : 44
    }
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.blue)
                    .frame(width: frame, height: frame)
                if !toggle {
                    Text("Matched Geometry")
                        .font(.headline)
                        .matchedGeometryEffect(id: "animate", in: namespace)
                }
                Spacer()
            }
            if toggle {
                Text("Matched Geometry")
                    .font(.headline)
                    .matchedGeometryEffect(id: "animate", in: namespace)
            }
            
            
        }
        .padding()
        .onTapGesture {
            withAnimation(.spring()) {
                toggle.toggle()
            }
        }
    }
}

//
//  ExpandCollapseHeader.swift
//  LearningAndExercise
//
//  Created by hb on 09/12/25.
//


import SwiftUI


// MARK: - Globals (you already had these)

var edges = UIApplication.shared.windows.first?.safeAreaInsets
var screen = UIScreen.main.bounds

// MARK: - PreferenceKey

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Main View

struct PageScoll: View {
    
    @StateObject private var headerData = HeaderViewModel()
    
    var colors: [Color] = [.red, .blue, .green, .yellow, .cyan]
    
    // Disable bouncing
    init() {
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Header View
            HeaderView()
                .zIndex(1)
                .offset(y: headerData.headerOffset)
            
            // Content View
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(colors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundStyle(color)
                            .frame(width: screen.width - 30, height: 450)
                    }
                }
                .padding(.top, 48)
                .overlay(alignment: .top) {
                    // GeometryReader reports minY via PreferenceKey
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .global).minY
                        return Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: minY)
                    }
                    .frame(height: 1)
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { minY in
                handleScroll(minY: minY)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Scroll handling
    
    private func handleScroll(minY: CGFloat) {
        // Storing initial MinY value...
        if headerData.startMinY == 0 {
            headerData.startMinY = minY
        }
        
        // Getting exact offset value by subtracting current form start
        let offset = headerData.startMinY - minY
        
        // Getting scroll Direction
        if offset > headerData.offset {
            
            // if Top, Hiding header view...
            // clearing bottom offset
            headerData.bottomScrollOffset = 0
            
            if headerData.topScrollOffset == 0 {
                // storing initially to subtract the maxOffset.
                headerData.topScrollOffset = offset
            }
            
            let progress = (headerData.topScrollOffset + getMaxOffset()) - offset
            
            let offsetCondition = (headerData.topScrollOffset + getMaxOffset()) >= getMaxOffset() && getMaxOffset() - progress <= getMaxOffset()
            
            let headerOffset = offsetCondition ? -(getMaxOffset() - progress) : -getMaxOffset()
            headerData.headerOffset = headerOffset
        }
        
        if offset < headerData.offset {
            
            // if Bottom, revealing header view...
            // Clearing top scroll value and setting bottom
            
            headerData.topScrollOffset = 0
            
            if headerData.bottomScrollOffset == 0 {
                headerData.bottomScrollOffset = offset
            }
            
            // Moving if little bit of screen is swiped down.
            // for eg 40 offset
            
            withAnimation(.easeInOut(duration: 0.25)) {
                let headerOffset = headerData.headerOffset
                
                headerData.headerOffset = headerData.bottomScrollOffset > offset + 40 ? 0 : (headerOffset != -getMaxOffset() ? 0 : headerOffset)
            }
        }
        
        // THIS WAS THE KEY FIX - Update offset at the END
        headerData.offset = offset
    }
    
    // Getting max Top offset including Top Safe area
    private func getMaxOffset() -> CGFloat {
        return headerData.startMinY + (edges?.top ?? 0) + 10
    }
}


// MARK: - Preview

#Preview {
    PageScoll()
}


// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            
//            Image("logolargeNewGreen")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 122, height: 30)
            
            Text("Scroll Demo")
                .font(.title)
            
            Spacer()
            
            HStack(spacing: 18) {
                Button(action: {
                    print("Clicked on Filter.")
                }) {
                    Image("filterLine")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                
                Button(action: {
                    print("Clicked on notification.")
                }) {
                    Image("notification")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 25)
        .background(.white)
    }
}
//
class HeaderViewModel: ObservableObject {
    
    // Top Capture start MinY value for calculations...
    @Published var startMinY: CGFloat = 0
    
    @Published var offset: CGFloat = 0
    
    @Published var headerOffset: CGFloat = 0
    
    // It will be used for getting top and bottom offsets for header view...
    @Published var topScrollOffset: CGFloat = 0
    @Published var bottomScrollOffset: CGFloat = 0
}




// MARK: - Using Geometry reader, can cause lag in case of large contnet
/*
 struct PageScoll: View {
     
     @StateObject private var headerData = HeaderViewModel()
     
     var colors: [Color] = [.red, .blue, .green, .yellow, .cyan]
     
     // Disable bouncing
     init() {
         UIScrollView.appearance().bounces = false
     }
     var body: some View {
         ZStack(alignment: .top) {
             // Header View
             HeaderView()
                 .zIndex(1)
                 .offset(y: headerData.headerOffset)
             
 //            Content View
             ScrollView(.vertical) {
                 VStack(spacing: 0) {
                     ForEach(colors, id: \.self) { color in
                         RoundedRectangle(cornerRadius: 0)
                             .foregroundStyle(color)
                             .frame(width: screen.width - 30, height: 450)
                     }
                 }
                 .padding(.top, 48)
                 .overlay(alignment: .top) {
                     // Geometry reader for getting offset values...
                     GeometryReader { proxy -> Color in
                         
                         let minY = proxy.frame(in: .global).minY
                         
                         DispatchQueue.main.async {
                             // Storing initial MinY value...
                             if headerData.startMinY == 0 {
                                 headerData.startMinY = minY
                             }
                             
                             // Getting exact offset value by subtracting current form start
                             let offset = headerData.startMinY - minY
                             
                             // Getting scroll Direction
                             if offset > headerData.offset {
                                 
                                 // if Top, Hiding header view...
                                 // clearing bottom offset
                                 headerData.bottomScrollOffset = 0
                                 
                                 if headerData.topScrollOffset == 0 {
                                     // storing initially to subtract the maxOffset.
                                     headerData.topScrollOffset = offset
                                 }
                                 
                                 let progress = (headerData.topScrollOffset + getMaxOffset()) - offset
                                 
                                 // All conditions were going to use ternary operater, because if else while swiping first ignore some conditions.
                                 let offsetCondition = (headerData.topScrollOffset + getMaxOffset()) >= getMaxOffset() && getMaxOffset() - progress <= getMaxOffset()
                                 
                                 let headerOffset = offsetCondition ? -(getMaxOffset() - progress) : -getMaxOffset()
                                 print(headerOffset)
                                 headerData.headerOffset = headerOffset
                             }
                             
                             if offset < headerData.offset {
                                 
                                 // if Bottom, reveling header view...
                                 // Clearing top scroll value and setting bottom
                                 
                                 headerData.topScrollOffset = 0
                                 
                                 if headerData.bottomScrollOffset == 0 {
                                     headerData.bottomScrollOffset = offset
                                 }
                                 
                                 // Moving if little bit of screen is swiped down.
                                 // for eg 40 offset
                                 
                                 withAnimation(.easeInOut(duration: 0.25)) {
                                     let headerOffset = headerData.headerOffset
                                     
                                     headerData.headerOffset = headerData.bottomScrollOffset > offset + 40 ? 0 : (headerOffset != -getMaxOffset() ? 0 : headerOffset)
                                 }
                             }
                             
                             headerData.offset = offset
                         }
                         
                         return Color.clear
                     }
                     .frame(height: 1)
                 }
             }
             .scrollIndicators(.hidden)
         }
     }
     
     // Getting max Top offset including Top Safe area
     func getMaxOffset() -> CGFloat {
         return headerData.startMinY + (edges?.top ?? 0) + 10
     }
 }
 */

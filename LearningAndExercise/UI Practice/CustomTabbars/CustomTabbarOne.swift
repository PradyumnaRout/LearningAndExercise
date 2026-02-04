//
//  CustomTabbarOne.swift
//  LearningAndExercise
//
//  Created by hb on 02/02/26.
//

import SwiftUI

struct CustomTabbarContentOne: View {
    var body: some View {
        Home()
    }
}


#Preview {
    CustomTabbarContentOne()
}


struct Home: View {
    @State var selectedTab: Tab = .add
    @State var xValue: CGFloat = 0
    @Namespace private var namespace
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Color.black
                        .ignoresSafeArea()
                        .tag(tab)
                }
            }
            
            // Custom Tab
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Spacer()
                    Button {
                        withAnimation(.smooth) {
                            selectedTab = tab
                            updateXValue()
                        }
                    } label: {
                        VStack {
                            Image(systemName: tab.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.black)
                                .padding(15)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            Circle()
                                                .fill(Color.white)
                                                .matchedGeometryEffect(id: "TAB_BG", in: namespace)
                                        }
                                    }
                                )
                                .rotationEffect(.degrees(selectedTab == tab ? -15 : 0))
//                                .background(Color.white.opacity(selectedTab == tab ? 1 : 0))
//                                .clipShape(Circle())
                                .font(.caption.bold())
                                .offset(y: selectedTab == tab ? -20 : 0)
                            
                            Text(tab.name)
                                .foregroundStyle(.black)
                                .fontWeight(.bold)
                                .offset(y: selectedTab == tab ? -12 : -8)
                        }
                        .frame(height: 50)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .background(
                CustomShpae2(midPoint: xValue)
                    .fill(.white)
            )
        }
        .ignoresSafeArea()
        .onAppear {
            updateXValue()
        }
    }
}

extension Home {
    private func updateXValue() {
        let tabWidth = UIScreen.main.bounds.width / CGFloat(Tab.allCases.count)
        let selectedIndex = Tab.allCases.firstIndex(of: selectedTab) ?? 0
        xValue = tabWidth * CGFloat(selectedIndex) + tabWidth / 2
    }
}


enum Tab: String, Hashable, CaseIterable {
    case profile, saved, add, search, menu
    
    var name: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .profile:
            return "person"
        case .saved:
            return "bookmark"
        case .add:
            return "plus"
        case .search:
            return "magnifyingglass"
        case .menu:
            return "menucard"
        }
    }
}


struct CustomShapePreview: View {
    var body: some View {
        CustomShpae1(xValue: 170)
            .fill(.teal)
            .frame(width: UIScreen.main.bounds.width, height: 150)

    }
}

#Preview("Custom Shpae") {
//    CustomShapePreview()
    CustomShpae2(midPoint: 100)
        .frame(height: 200)
}


// Custom Shape
struct CustomShpae1: Shape {
    var xValue: CGFloat
    
    var animatableData: CGFloat {
        get { xValue }
        set { xValue = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            
            
            let center = xValue
            path.move(to: CGPoint(x: center - 70, y: 0))
            
            let to1 = CGPoint(x: center, y: 40)
            let control1 = CGPoint(x: center - 25, y: 0)
            let control2 = CGPoint(x: center - 40, y: 35)
            
            let to2 = CGPoint(x: center + 70, y: 0)
            let control3 = CGPoint(x: center + 40, y: 35)
            let control4 = CGPoint(x: center + 25, y: 0)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
            
        }
    }
}

// Custom shape 2
struct CustomShpae2: Shape {
    var midPoint: CGFloat
    
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            // Base rectangle
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            // Curve cut-out
            let curveWidth: CGFloat = 140
            let curveHeight: CGFloat = 40
            
            let startX = midPoint - curveWidth / 2
            let endX   = midPoint + curveWidth / 2
            
            path.move(to: CGPoint(x: startX, y: 0))
            
            path.addCurve(
                to: CGPoint(x: midPoint, y: curveHeight),
                control1: CGPoint(x: midPoint - 40, y: 0),
                control2: CGPoint(x: midPoint - 40, y: curveHeight)
            )
            
            path.addCurve(
                to: CGPoint(x: endX, y: 0),
                control1: CGPoint(x: midPoint + 40, y: curveHeight),
                control2: CGPoint(x: midPoint + 40, y: 0)
            )
        }
    }
}

// Custom Tab Shape
struct TabShape: Shape {
    var midPoint: CGFloat
    
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            // Base rectangle
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            // now Drawing upward curve shape
            path.move(to: .init(x: midPoint - 60, y: 0))
            
            let to1 = CGPoint(x: midPoint, y: -25)
            let control1 = CGPoint(x: midPoint - 25, y: 0)
            let control2 = CGPoint(x: midPoint - 25, y: -25)
            
            let to2 = CGPoint(x: midPoint + 60, y: 0)
            let control3 = CGPoint(x: midPoint + 25, y: -25)
            let control4 = CGPoint(x: midPoint + 25, y: 0)

            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}



struct CurveUpShape: Shape {
    var midPoint: CGFloat
    
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            // Rectangle base
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            // Curve UP (bump)
            let curveWidth: CGFloat = 140
            let curveHeight: CGFloat = 35
            
            let startX = midPoint - curveWidth / 2
            let endX   = midPoint + curveWidth / 2
            
            path.move(to: CGPoint(x: startX, y: 0))
            
            path.addCurve(
                to: CGPoint(x: midPoint, y: -curveHeight),
                control1: CGPoint(x: midPoint - 40, y: 0),
                control2: CGPoint(x: midPoint - 40, y: -curveHeight)
            )
            
            path.addCurve(
                to: CGPoint(x: endX, y: 0),
                control1: CGPoint(x: midPoint + 40, y: -curveHeight),
                control2: CGPoint(x: midPoint + 40, y: 0)
            )
        }
    }
}


struct PillTabShape: Shape {
    var midPoint: CGFloat
    
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Rectangle base
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            let width: CGFloat = 120
            let height: CGFloat = 45
            
            let startX = midPoint - width / 2
            let endX = midPoint + width / 2
            
            path.move(to: CGPoint(x: startX, y: 0))
            
            path.addCurve(
                to: CGPoint(x: midPoint, y: -height),
                control1: CGPoint(x: startX + 30, y: 0),
                control2: CGPoint(x: midPoint - 30, y: -height)
            )
            
            path.addCurve(
                to: CGPoint(x: endX, y: 0),
                control1: CGPoint(x: midPoint + 30, y: -height),
                control2: CGPoint(x: endX - 30, y: 0)
            )
        }
    }
}


struct DeepNotchTabShape: Shape {
    var midPoint: CGFloat
    
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Base rectangle
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            let width: CGFloat = 130
            let depth: CGFloat = 50
            
            let startX = midPoint - width / 2
            let endX = midPoint + width / 2
            
            path.move(to: CGPoint(x: startX, y: 0))
            
            path.addCurve(
                to: CGPoint(x: midPoint, y: depth),
                control1: CGPoint(x: startX + 20, y: 0),
                control2: CGPoint(x: midPoint - 30, y: depth)
            )
            
            path.addCurve(
                to: CGPoint(x: endX, y: 0),
                control1: CGPoint(x: midPoint + 30, y: depth),
                control2: CGPoint(x: endX - 20, y: 0)
            )
        }
    }
}

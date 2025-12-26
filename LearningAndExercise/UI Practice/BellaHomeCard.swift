//
//  BellaHomeCard.swift
//  LearningAndExercise
//
//  Created by hb on 24/12/25.
//

import SwiftUI
import Foundation

let screenBound = UIScreen.main.bounds

struct BellaHomeCard: View {
    let strokeWidth: CGFloat = 2
    @State private var vStackHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.brown.opacity(0.8)
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                // Profile circle
                ZStack {
                    Circle()
                        .fill(.white)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                        .padding(4)
                    
                    Image(.wallpOne)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .contentShape(Circle())
                        .clipped()
                        .padding(8)
                }
                .frame(width: vStackHeight + 20, height: vStackHeight + 20)
                .zIndex(5)
                .background(alignment: .bottomTrailing) {
                    Capsule()
                        .fill(.white)
                        .frame(width: 20, height: 40)
                        .offset(x: 1.12, y: -24.6)
                }

                
                
                Spacer()
                
                // Proifle Data
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        itemVstack(title: "ITEMS", count: "54")
                        itemVstack(title: "OUTFITS", count: "24")
                        itemVstack(title: "TOTAL SPEND", count: "$6500")
                    }
                    .background(
                        Capsule()
                            .fill(.white)
                            .padding(.vertical, -10)
                            .padding(.trailing, -10)
                            .padding(.leading, -(screenBound.width * 0.188))

                    )
                    .offset(x: -8, y: 2)
                    
                    
                    // Completion Block
                    HStack(spacing: 10) {
                        Text("Complete Profile")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .padding(.leading, (screenBound.width * 0.1))
                    .background(
//                        Capsule()
//                            .fill(.blue)
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                        .cornerRadius(60, corners: [.bottomRight, .topRight])
                        .padding(.top, -25)
                    )
                    .offset(x: -(screenBound.width * 0.14), y: 9)
                    .frame(width: screenBound.width * 0.6)
                    .zIndex(-1)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: HeightPreferenceKey.self,
                                        value: geo.size.height)
                    }
                )
            }
            .onPreferenceChange(HeightPreferenceKey.self) {
                vStackHeight = $0
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func itemVstack(title: String, count: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .lineLimit(1)
                .foregroundStyle(.black.opacity(0.6))
                .font(.system(size: 14, weight: .medium))
            Text(count)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    BellaHomeCard()
//    TestCustomPath()
}


// Extension to support specific corner rounding
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct TestCustomPath: View {
    var body: some View {
        VStack {
//            Triangle()
//                .stroke()
            
//            Trapezoid()
//                .fill(Color.black)
//                .overlay(
//                    Trapezoid().stroke(Color.black, lineWidth: 2)
//                )
            
//            AddArc()
//                .stroke(
//                    LinearGradient(
//                        colors: [.indigo, .green, .yellow],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    ),
//                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
//                )
            
//            AddCurveTwo()
//                .stroke(lineWidth: 8)
//                .foregroundColor(.indigo)
            
            ResponsivePath()
                .stroke(
                        LinearGradient(
                            colors: [.indigo, .green, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                .frame(width: screen.width)

        }
    }
}



// MARK: CUSTOM PATH IN IOS : https://xavier7t.com/custom-shapes-in-swiftui

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        //var path = Path()     // You can use path variable instead of Path Closure.
        Path { path in
            path.move(to: CGPoint(x: 150, y: 0))
            path.addLine(to: CGPoint(x: 10, y: 100))
            path.addLine(to: CGPoint(x: 150, y: 100))
            path.addLine(to: CGPoint(x: 150, y: 0))
            // or path.closeSubpath() //for the last line closing the shape
        }
    }
}


struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addLines([
                .init(x: 50, y: 0),
                .init(x: 150, y: 0),
                .init(x: 150, y: 100),
                .init(x: 0, y: 100)
            ])
        }
    }
}

struct AddArc: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: .init(x: 100, y: 50),
                radius: 50,
                startAngle: .init(degrees: 0),
                endAngle: .init(degrees: 90),// 360 for full circle
                clockwise: true
            )
        }
    }
}

struct AddCurve: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .init(x: 50, y: 0))
            path.addCurve(to: .init(x: 200, y: 0), control1: .init(x: 125, y: 60), control2: .init(x: 125, y: 60))
        }
    }
}


struct AddCurveTwo: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .init(x: 50, y: 100))
            path.addCurve(to: .init(x: 250, y: 50), control1: .init(x: 125, y: -120), control2: .init(x: 125, y: 160))
//            path.addQuadCurve(to: <#T##CGPoint#>, control: <#T##CGPoint#>)
        }
    }
}

struct MyCustomSahpe: Shape {
    // Constant size
//    func path(in rect: CGRect) -> Path {
//        Path { path in
//            path
//                .addArc(
//                    center: .init(x: 100, y: 100),
//                    radius: 50,
//                    startAngle: .init(degrees: -70),
//                    endAngle: .init(degrees: 40),
//                    clockwise: true
//                )
//                        
//            path
//                .addCurve(
//                    to: .init(
//                        x: 171,
//                        y: 108
//                    ),
//                    control1: .init(
//                        x: 165,
//                        y: 99
//                    ),
//                    control2: .init(
//                        x: 169,
//                        y: 110
//                    )
//                )
//            
//            path.addLine(to: .init(x: 250, y: 107))
//            
//            path
//                .addCurve(
//                    to: .init(
//                        x: 250,
//                        y: 50
//                    ),
//                    control1: .init(
//                        x: 280,
//                        y: 99
//                    ),
//                    control2: .init(
//                        x: 280,
//                        y: 60
//                    )
//                )
//            
//            path.addLine(to: .init(x: 100, y: 51))
//            
//        }
//    }
    
    // Half Sape
//    func path(in rect: CGRect) -> Path {
//        Path { path in
//            let centerX = rect.midX * 0.5
//            let centerY = rect.midY
//            let radius = min(rect.width, rect.height) * 0.2
//            
//            // Arc
//            path
//                .addArc(
//                    center: .init(x: centerX, y: centerY),
//                    radius: radius,
//                    startAngle: .init(degrees: -70),
//                    endAngle: .init(degrees: 40),
//                    clockwise: true
//                )
//            
//            // Curve connecting arc to line
//            let curveEndX = centerX + radius * 1.42
//            let curveEndY = centerY + radius * 0.08
//            let control1X = centerX + radius * 1.3
//            let control1Y = centerY - radius * 0.01
//            let control2X = centerX + radius * 1.38
//            let control2Y = centerY + radius * 0.1
//            
//            path
//                .addCurve(
//                    to: .init(x: curveEndX, y: curveEndY),
//                    control1: .init(x: control1X, y: control1Y),
//                    control2: .init(x: control2X, y: control2Y)
//                )
//            
//            // Horizontal line
//            path.addLine(to: .init(x: rect.maxX, y: curveEndY))
//        }
//    }
    
    // Full shape
    func path(in rect: CGRect) -> Path {
        Path { path in
            let centerX = rect.midX * 0.5
            let centerY = rect.midY
            let radius = min(rect.width, rect.height) * 0.2
            
            let bottomOffset = rect.height * 0.096
            let bottomY = centerY - bottomOffset
            
            // Left Arc
            path.addArc(
                center: .init(x: centerX, y: centerY),
                radius: radius,
                startAngle: .init(degrees: -70),
                endAngle: .init(degrees: 40),
                clockwise: true
            )
            
            // Curve from arc to horizontal line
            let curveEndX = centerX + radius * 1.42
            let curveEndY = centerY + radius * 0.08
            
            path.addCurve(
                to: .init(x: curveEndX, y: curveEndY),
                control1: .init(x: centerX + radius * 1.3, y: centerY - radius * 0.01),
                control2: .init(x: centerX + radius * 1.38, y: centerY + radius * 0.1)
            )
            
            // Bottom horizontal line
            let topLineEndX = rect.maxX * 0.85
            path.addLine(to: .init(x: topLineEndX, y: curveEndY))
                        
            // Right curved line going down (OUTSIDE CURVE)
                let rightCurveEndY = centerY + radius * 0.5
                path.addCurve(
                    to: .init(x: topLineEndX, y: bottomY),
                    control1: .init(x: topLineEndX + radius * 0.65, y: curveEndY),
                    control2: .init(x: topLineEndX + radius * 0.65, y: bottomY)
                )
            
            // Top horizontal line going left
            let bottomLineStartX = centerX + radius * 0.42
            path.addLine(to: .init(x: bottomLineStartX-2.5, y: bottomY))
        }
    }
}


struct ResponsivePath: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Scale all dimensions proportionally
            let scale = min(rect.width, rect.height) / 300 // Base size of 300
            
            let centerX = rect.width * 0.3
            let centerY = rect.height * 0.5
            let radius = min(rect.width, rect.height) * 0.2

            let bottomOffset = rect.height * 0.096
            let bottomY = centerY - bottomOffset
            
            // Left Arc
            path.addArc(
                center: .init(x: centerX, y: centerY),
                radius: radius,
                startAngle: .init(degrees: -70),
                endAngle: .init(degrees: 40),
                clockwise: true
            )
            
            // Curve from arc to horizontal line
            let curveEndX = centerX + radius * 1.42
            let curveEndY = centerY + radius * 0.08
            
            path.addCurve(
                to: .init(x: curveEndX, y: curveEndY),
                control1: .init(x: centerX + radius * 1.3, y: centerY - radius * 0.01),
                control2: .init(x: centerX + radius * 1.38, y: centerY + radius * 0.1)
            )
            
            // Bottom horizontal line
            let topLineEndX = rect.maxX * 0.85
            path.addLine(to: .init(x: topLineEndX, y: curveEndY))
            
            // Right curved line going down (OUTSIDE CURVE)
            path.addCurve(
                to: .init(x: topLineEndX, y: bottomY),
                control1: .init(x: topLineEndX + radius * 0.65, y: curveEndY),
                control2: .init(x: topLineEndX + radius * 0.65, y: bottomY)
            )
            
            // Top horizontal line going left
            let bottomLineStartX = centerX + radius * 0.42
            path.addLine(to: .init(x: bottomLineStartX - 2.5 * scale, y: bottomY))
        }
    }
}

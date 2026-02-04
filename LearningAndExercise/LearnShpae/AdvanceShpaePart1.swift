//
//  AdvanceShpaePart1.swift
//  LearningAndExercise
//
//  Created by hb on 02/02/26.
//

import SwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 1, lineJoin: .round)
private let shoulderRatio: CGFloat = 0.65

struct ArrowNative: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let shoulderX = rect.minX + (rect.width * shoulderRatio)
        let rowHeight = rect.height / 3
        let row1Y = rect.minY + rowHeight
        let row2Y = row1Y + rowHeight

        path.move(to: CGPoint(x: rect.minX, y: row1Y))
        path.addLine(to: CGPoint(x: shoulderX, y: row1Y))
        path.addLine(to: CGPoint(x: shoulderX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: shoulderX, y: rect.maxY))
        path.addLine(to: CGPoint(x: shoulderX, y: row2Y))
        path.addLine(to: CGPoint(x: rect.minX, y: row2Y))
        path.closeSubpath()

        return path
    }
}


struct GridLayoutArrowDemo_Harness: View {
    var body: some View {
        VStack(spacing: 50) {
            HarvestNotificationCard()
        }
    }
}


#Preview {
    GridLayoutArrowDemo_Harness()
}


struct CustomCurve: Shape {
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






struct HarvestNotificationCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Harvest\nSeason\nBegins")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                    .lineSpacing(2)
                
                Text("The hops are look...")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("4 hours ago")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Image("harvest_image") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
        }
        .padding(20)
//        .background(.red)
        .background(
            Image("Subtract")
                .resizable()
        )
        .frame(width: 350, height: 200)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}



struct CardBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 30
        let cutoutRadius: CGFloat = 65 // Adjust based on image size
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: rect.height - cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        
        // Bottom line to right
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
        
        // Right line up to the cutout
        path.addLine(to: CGPoint(x: rect.width, y: cutoutRadius + 20))
        
        // The "Cutout" curve
        path.addArc(center: CGPoint(x: rect.width, y: 0), radius: cutoutRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        // Top line to left
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
        
        path.closeSubpath()
        return path
    }
}


struct HarvestCard: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 1. The Main Content Box
            VStack(alignment: .leading, spacing: 12) {
                Text("Harvest\nSeason\nBegins")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("The hops are look...")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("4 hours ago")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
            }
            .padding(30)
            .frame(width: 300, height: 320, alignment: .leading)
            .background(
                CardBackground()
                    .fill(Color.white)
                    .overlay(
                        CardBackground()
                            .stroke(Color.blue.opacity(0.7), lineWidth: 2)
                    )
            )
            
            // 2. The Floating Image
            Image("harvest_image") // Replace with your asset name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .offset(x: 20, y: -20) // Hangs off the edge slightly
        }
        .padding()
    }
}

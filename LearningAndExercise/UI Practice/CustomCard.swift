//
//  CustomCard.swift
//  LearningAndExercise
//
//  Created by hb on 29/01/26.
//

import SwiftUI

struct CustomCard: View {
    
    let cardColor = Color(red: 0.45, green: 0.8, blue: 0.82)
    let circleColor = Color(red: 0.98, green: 0.85, blue: 0.38)
    
    // Logic: The 'gap' is the difference between cutoutSize and circleRadius
    let cutoutSize: CGFloat = 120
    let gap: CGFloat = 16 // Space between the shape and the circle
    let cornerRadius: CGFloat = 30
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 1. The Teal Shape with the cutout
            CutoutShape(cornerRadius: cornerRadius, cutoutRadius: cutoutSize)
                .fill(cardColor)
                .overlay(
                    CutoutShape(cornerRadius: cornerRadius, cutoutRadius: cutoutSize)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            // 2. The Yellow Circle
            // Its size is (Cutout - Gap) * 2 to keep it centered in the arc
            Circle()
                .fill(circleColor)
                .frame(width: (cutoutSize - gap) * 1.3, height: (cutoutSize - gap) * 1.3)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
            // Position it so its center is exactly at the top-right corner of the rect
                .offset(x: (cutoutSize - gap * 5.5), y: -(cutoutSize - gap * 5.5))
        }
        .frame(width: 250, height: 250)
        // Clip to ensure the top-right part of the circle outside the card area is visible
        // or removed depending on your preference.
    }
}



#Preview {
    CustomCard()
}


struct CutoutShape: Shape {
    var cornerRadius: CGFloat
    var cutoutRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top edge where the cutout begins
        path.move(to: CGPoint(x: rect.width - cutoutRadius, y: 0))
        
//        // The cutout arc (smooth transition)
//        path.addArc(center: CGPoint(x: rect.width, y: 0),
//                    radius: cutoutRadius,
//                    startAngle: Angle(degrees: 180),
//                    endAngle: Angle(degrees: 90),
//                    clockwise: true)
        
        // 1. Move to the top edge where the cut begins
        path.move(to: CGPoint(x: rect.width - cutoutRadius * 0.9, y: 0))
        
        // 2. THE CUTTING CIRCLE EFFECT
        // We use a control point at the very top-right corner (rect.width, 0).
        // This pulls the line toward the corner before curving it back to the right edge.
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: cutoutRadius * 0.9),
            control: CGPoint(x: rect.width * 0.5, y: cutoutRadius * 1.0)
        )
        // Note: For a more "circular" look, we adjust the control point
        // slightly away from the absolute corner.

        // Bottom right corner
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)

        // Bottom left corner
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)

        // Top left corner
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        path.closeSubpath()
        return path
    }
}



/*
ZStack(alignment: .topTrailing) {
    RoundedRectangle(cornerRadius: 20)
        .frame(width: 250, height: 300)
        .foregroundStyle(.teal)
        .overlay {
            Circle()
                .frame(width: 160, height: 160)
                .offset(x: 85, y: -100)
                .blendMode(.destinationOut)
                .overlay {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 150, height: 150)
                        .offset(x: 85, y: -100)
                }
        }
        .compositingGroup()
}
 */

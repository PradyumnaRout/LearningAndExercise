//
//  ViewBasedOnIFCondition.swift
//  LearningAndExercise
//
//  Created by hb on 11/11/25.
//

import Foundation
import SwiftUI

struct GoldButtonModifer: ViewModifier {
    
    let fontWeight: Font.Weight
    let font: Font
    let foreGroundColor: Color
    let backgroundColor: Color?
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let strokeWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .fontWeight(fontWeight)
            .font(font)
            .foregroundStyle(foreGroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .if(backgroundColor != nil) { view in
                view.background(backgroundColor!, in: Capsule(style: .continuous))
            }
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.black, lineWidth: 1)
            )
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
            // What will happen inside the closure on call side is transform(self)
        } else {
            self
        }
    }
}

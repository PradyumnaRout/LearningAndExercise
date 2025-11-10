//
//  Textfield + Modifiers.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 22/06/25.
//

import SwiftUI

struct TextFieldBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(alignment: .bottom) {
                Color(uiColor: .secondaryLabel).opacity(0.5)
                    .frame(height: 0.5)
                    .padding(.horizontal)
            }
            .padding(.horizontal, 8)
    }
}

extension View {
    func textFieldBackground() -> some View {
        self.modifier(TextFieldBackground())
    }
}




struct Shake: AnimatableModifier {
    var shakes: CGFloat = 0
    
    var animatableData: CGFloat {
        get {
            shakes
        } set {
            shakes = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * 5)
    }
}

extension View {
    func shake(with shakes: CGFloat) -> some View {
        modifier(Shake(shakes: shakes))
    }
}

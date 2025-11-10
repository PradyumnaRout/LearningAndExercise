//
//  Button + Modifiers.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 22/06/25.
//

import SwiftUI

// Custom View modifier for textfield background.


struct CustomButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.vertical, 15)
            .frame(width: AppConstants.screenWidth * 0.3)
            .background(
                Color.blue
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
    }
}

extension View {
    func backgroundButton() -> some View {
        self.modifier(CustomButton())
    }
}

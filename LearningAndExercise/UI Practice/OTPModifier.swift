//
//  OTPModifier.swift
//  LearningAndExercise
//
//  Created by hb on 27/01/26.
//

import SwiftUI

struct OtpModifier: ViewModifier {
    
    var isFocused: Bool
    var otp: String
    var backgroundColor: Color
    var focusColor: Color
    var emptyFieldColor: Color
    var otpFieldColor: Color
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
        
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? focusColor : emptyFieldColor, lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke((!isFocused && !otp.isEmpty) ? otpFieldColor : Color.clear, lineWidth: 2)
            )
    }
}

extension View {
    
    func crazyOtpView(isFocused: Bool, otp: String, backgroundColor: Color, focusColor: Color, emptyFieldColor: Color, otpFieldColor: Color, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        self
            .modifier(OtpModifier(isFocused: isFocused, otp: otp, backgroundColor: backgroundColor, focusColor: focusColor, emptyFieldColor: emptyFieldColor, otpFieldColor: otpFieldColor, width: width, height: height, cornerRadius: cornerRadius))
    }
}

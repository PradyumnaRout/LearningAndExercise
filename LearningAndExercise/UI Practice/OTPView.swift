//
//  OTPView.swift
//  LearningAndExercise
//
//  Created by hb on 27/01/26.
//


import SwiftUI
import Combine


struct VerifyOtp: View {
    @State private var otp: [String] = Array(repeating: "", count: 6)
    
    var body: some View {
        OtpView(otp: $otp, count: 6)
            .frame(maxWidth: .infinity)
    }
}



struct OtpView: View {
    
    @Binding var otp: [String]
    @FocusState private var focusedIndex: Int?
    
    var otpCount: Int
    var backgroundColor: Color = Color(uiColor: .systemBackground)
    var focusColor: Color = Color.blue
    var emptyFieldColor: Color = Color.gray
    var otpFieldColor: Color = Color.green
    var width: CGFloat = 50
    var height: CGFloat = 60
    var cornerRadius: CGFloat = 10
    
    private var firstEmptyIndex: Int {
        otp.firstIndex(where: { $0.isEmpty }) ?? (otpCount - 1)
    }
    
    init(otp: Binding<[String]>, count: Int) {
        self.otpCount = count
        self._otp = otp
    }
    
//    init() {
//        _otp = State(initialValue: Array(repeating: "", count: otpCount))
//    }
    
//    init(backgroundColor: Color, focusColor: Color, emptyFieldColor: Color, otpFieldColor: Color, width: CGFloat, height: CGFloat, cornerRadius: CGFloat, otpCount: Int) {
//        self.backgroundColor = backgroundColor
//        self.focusColor = focusColor
//        self.emptyFieldColor = emptyFieldColor
//        self.otpFieldColor = otpFieldColor
//        self.width = width
//        self.height = height
//        self.cornerRadius = cornerRadius
//        self.otpCount = otpCount
////        _otp = State(initialValue: Array(repeating: "", count: otpCount))
//    }
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<otpCount, id: \ .self) { index in
                //                TextField("", text: $otp[index])
                OTPTextField(
                    text: $otp[index],
                    onChange: { newValue in
                        if !newValue.isEmpty && index < 5 {
                            focusedIndex = index + 1
                        }
                    },
                    onBackspace: {
                        if otp[index].isEmpty && index > 0 {
                            focusedIndex = index - 1
                        }
                    },
                    isFocused: focusedIndex == index
                )
                .disabled(index != firstEmptyIndex && otp[index].isEmpty)
                .onTapGesture {
                    focusedIndex = firstEmptyIndex
                }
                .crazyOtpView(
                    isFocused: focusedIndex == index,
                    otp: otp[index],
                    backgroundColor: backgroundColor,
                    focusColor: focusColor,
                    emptyFieldColor: emptyFieldColor,
                    otpFieldColor: otpFieldColor,
                    width: width,
                    height: height,
                    cornerRadius: cornerRadius
                )
                .focused($focusedIndex, equals: index)
                .onChange(of: otp[index]) {oldValue, newValue in
                    updateOptField(oldValue: oldValue, newValue: newValue, index: index)
                }
            }
        }
        .padding()
    }
    
    private func updateOptField(oldValue: String, newValue: String, index: Int) {
        var validString = ""
        /**
         print("old Value :: \(oldValue)")
         print("new Value :: \(newValue)")
         print("validString :: \(validString)")
         print("WholeString:: \(otp)")
         */
        if newValue.count > 1 {
            let firstValue = String(newValue.prefix(1))
            validString = validateNumber(value: firstValue)
        } else {
            validString = validateNumber(value: newValue)
        }
        
        if !validString.isEmpty {
            otp[index] = validString
        } else {
            otp[index] = ""
        }
        
        if !validString.isEmpty, index < (otpCount - 1) {
            focusedIndex = index + 1
        } else if (validString.isEmpty) && (!validateNumber(value: oldValue).isEmpty) {
            if (index > 0) {
                focusedIndex = index - 1
            }
        } else if !validString.isEmpty, index == (otp.count - 1) {
            focusedIndex = nil
            // TODO: works like api calls for verify.ef
        }

    }
    
    private func validateNumber(value: String) -> String {
        let filtered = value.filter { "0123456789".contains($0) }
        return filtered
    }
}

#Preview {
    OtpView(otp: .constant(Array(repeating: "", count: 6)), count: 6)
}



// Move to previous field by click backspace on empty field.


struct OTPTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: OTPTextField

        init(_ parent: OTPTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

            if let text = textField.text, (text + string).count > 1 {
                let char = String(string.prefix(1))
                DispatchQueue.main.sync { [weak self] in
                    textField.text = char
                    self?.parent.text = char
                    self?.parent.onChange?(char)
                }
                return false
            }

            return true
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.text = textField.text ?? ""
                self?.parent.onChange?(self?.parent.text ?? "")
            }
        }
    }

    @Binding var text: String
    var onChange: ((String) -> Void)?
    var onBackspace: (() -> Void)?
    var isFocused: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let tf = BackspaceTextField()
        tf.delegate = context.coordinator
        tf.keyboardType = .numberPad
        tf.textAlignment = .center
        tf.font = UIFont.systemFont(ofSize: 24)

        tf.onBackspace = onBackspace   // 🔥 this is the magic

        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

final class BackspaceTextField: UITextField {
    var onBackspace: (() -> Void)?

    override func deleteBackward() {
        if text?.isEmpty ?? true {
            onBackspace?()
        }
        super.deleteBackward()
    }
}

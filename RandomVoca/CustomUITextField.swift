import SwiftUI
import UIKit

struct CustomUITextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomUITextField

        init(_ parent: CustomUITextField) {
            self.parent = parent
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onCommit?() // 키보드 내려가지 않게 false 반환
            return false
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)? = nil
    @Binding var isFirstResponder: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

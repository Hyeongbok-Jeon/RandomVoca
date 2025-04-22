import SwiftUI
import UIKit

struct CustomUITextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomUITextField

        init(_ parent: CustomUITextField) {
            self.parent = parent
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onCommit?()
            return false // 키보드 내리지 않음
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)? = nil
    @Binding var isFirstResponder: Bool

    // ✅ UIView 내부 포커스 상태 추적용 플래그
    private class FocusStateHolder {
        var isFocused: Bool = false
    }
    private let focusStateHolder = FocusStateHolder()

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

        // ✅ 중복 호출 방지를 위해 현재 포커스 상태 비교 후 제어
        DispatchQueue.main.async {
            if isFirstResponder {
                if !focusStateHolder.isFocused {
                    uiView.becomeFirstResponder()
                    focusStateHolder.isFocused = true
                }
            } else {
                if focusStateHolder.isFocused {
                    uiView.resignFirstResponder()
                    focusStateHolder.isFocused = false
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

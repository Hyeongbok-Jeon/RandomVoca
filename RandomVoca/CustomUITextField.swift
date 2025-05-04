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
      return true // 키보드 내림
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
      parent.text = textField.text ?? ""
    }
    
    // ✅ 포커스가 될 때 바인딩 업데이트 (더 이상 직접 설정하지 않음)
    func textFieldDidBeginEditing(_ textField: UITextField) {
      // DispatchQueue.main.async {
      //     self.parent.isFirstResponder = true
      // }
    }
    
    // ✅ 포커스를 잃을 때 바인딩 업데이트 (더 이상 직접 설정하지 않음)
    func textFieldDidEndEditing(_ textField: UITextField) {
      // DispatchQueue.main.async {
      //     self.parent.isFirstResponder = false
      // }
    }
  }
  
  @Binding var text: String
  var placeholder: String
  var onCommit: (() -> Void)? = nil
  @Binding var isFocused: Bool // ✅ @FocusState와 연결할 바인딩
  
  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .next
    textField.delegate = context.coordinator
    textField.textAlignment = .center
    textField.autocapitalizationType = .none
    
    // ✅ 추가
    //        textField.adjustsFontSizeToFitWidth = true
    //        textField.minimumFontSize = 12
    
    return textField
  }
  
  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
    uiView.placeholder = placeholder
    // ✅ 포커스는 SwiftUI에 맡기고, 여긴 텍스트와 placeholder만 업데이트
    
    // 가로 방향의 압축 저항 우선순위를 낮춥니다.
    uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

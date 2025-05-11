//
//  KeyboardResponder.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 5/11/25.
//

import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
  @Published var isKeyboardVisible: Bool = false
  private var cancellables: Set<AnyCancellable> = []

  init() {
    let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
      .map { _ in true }
    let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
      .map { _ in false }

    Publishers.Merge(willShow, willHide)
      .receive(on: RunLoop.main)
      .assign(to: \.isKeyboardVisible, on: self)
      .store(in: &cancellables)
  }
}

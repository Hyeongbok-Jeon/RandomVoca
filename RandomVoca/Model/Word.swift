//
//  Word.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import Foundation

// Word 객체 정의 (Codable 채택)
class Word: Codable, Identifiable, Equatable {
    var id = UUID()  // List에서 고유 식별자로 사용
    var name: String
    var meaning: String
    
    init(name: String, meaning: String) {
        self.name = name
        self.meaning = meaning
    }
    
    // Equatable 채택을 위한 메서드
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.id == rhs.id
    }
}

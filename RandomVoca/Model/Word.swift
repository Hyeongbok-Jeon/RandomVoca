//
//  Word.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import Foundation

// Word 객체 정의 (Codable 채택)
class Word: Codable, Identifiable, Equatable {
    var id: UUID  // List에서 고유 식별자로 사용
    var name: String
    var meaning: String
    var isKnowWord: Bool
    
    init(id: UUID = UUID(), name: String, meaning: String, isKnowWord: Bool) {
        self.id = id
        self.name = name
        self.meaning = meaning
        self.isKnowWord = isKnowWord
    }
    
    // 디코딩 할 때 자동으로 UUID가 없으면 생성되도록 설정
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID() // UUID가 없으면 새로 생성
        self.name = try container.decode(String.self, forKey: .name)
        self.meaning = try container.decode(String.self, forKey: .meaning)
        self.isKnowWord = try container.decode(Bool.self, forKey: .isKnowWord)
    }
    
    // Equatable 채택을 위한 메서드
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.id == rhs.id
    }
}

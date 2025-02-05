//
//  VocaGroup.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 2/5/25.
//

import Foundation

struct VocaGroup: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var words: [Word]
}

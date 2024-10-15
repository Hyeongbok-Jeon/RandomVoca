import Foundation

struct WordsGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var words: [Word]
}

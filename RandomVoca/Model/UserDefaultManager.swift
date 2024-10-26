import Foundation

class UserDefaultsManager {
    static let key = "SavedWords"
    
    // 단어 리스트를 UserDefaults에 저장하는 함수
    static func saveWords(_ words: [Word]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(words) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // UserDefaults에서 단어 리스트를 불러오는 함수
    static func loadWords() -> [Word] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            return decodedWords.sorted { $0.name < $1.name }
        }
        return []
    }
}

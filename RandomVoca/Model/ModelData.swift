import Foundation

class ModelData {
    static let shared = ModelData() // 싱글톤 패턴으로 전역 인스턴스 관리
    private let key = "SavedWords"

    private init() { }

    // 단어 저장 함수
    func saveWords(_ words: [Word]) {
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // 단어 불러오기 함수
    func loadWords() -> [Word] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            return decodedWords.sorted { $0.name < $1.name }
        }
        return []
    }
}

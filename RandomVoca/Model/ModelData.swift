import Foundation

@Observable
class ModelData {
    var words: [Word] = [] {
        didSet { saveWords() }
    }

    init() {
        loadWords()
    }

    // 단어 데이터 저장 함수
    func saveWords() {
        let key = "SavedWords"
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // 단어 데이터 로드 함수
    func loadWords() {
        let key = "SavedWords"
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            words = decodedWords.sorted { $0.name < $1.name }
        }
    }
}

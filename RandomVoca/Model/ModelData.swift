import Foundation

class ModelData: ObservableObject {
    @Published var words: [Word] = [] {
        didSet {
            saveWords() // words가 변경될 때마다 자동으로 저장
//            loadWords()
        }
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
    
//    func sortWords() -> [W] {
//        return words.sorted { $0.name < $1.name }
//    }
    
    func getSampleWords() -> [Word] {
        return [
            Word(name: "betray", meaning: "배신하다", isKnowWord: false, knowTime: 0),
            Word(name: "apply", meaning: "지원하다", isKnowWord: false, knowTime: 0),
            Word(name: "focus", meaning: "집중하다", isKnowWord: false, knowTime: 0),
            Word(name: "conversation", meaning: "대화", isKnowWord: false, knowTime: 0),
            Word(name: "experience", meaning: "경험", isKnowWord: false, knowTime: 0),
            Word(name: "communicate", meaning: "소통하다", isKnowWord: false, knowTime: 0),
            Word(name: "explain", meaning: "설명하다", isKnowWord: false, knowTime: 0),
            Word(name: "decide", meaning: "결정하다", isKnowWord: false, knowTime: 0),
            Word(name: "improve", meaning: "개선하다", isKnowWord: false, knowTime: 0),
            Word(name: "understand", meaning: "이해하다", isKnowWord: false, knowTime: 0),
            Word(name: "agree", meaning: "동의하다", isKnowWord: false, knowTime: 0),
            Word(name: "disagree", meaning: "동의하지 않다", isKnowWord: false, knowTime: 0),
            Word(name: "important", meaning: "중요한", isKnowWord: false, knowTime: 0),
            Word(name: "suggestion", meaning: "제안", isKnowWord: false, knowTime: 0),
            Word(name: "problem", meaning: "문제", isKnowWord: false, knowTime: 0),
            Word(name: "solution", meaning: "해결책", isKnowWord: false, knowTime: 0),
            Word(name: "opinion", meaning: "의견", isKnowWord: false, knowTime: 0),
            Word(name: "recommendation", meaning: "추천", isKnowWord: false, knowTime: 0),
            Word(name: "plan", meaning: "계획", isKnowWord: false, knowTime: 0),
            Word(name: "enjoy", meaning: "즐기다", isKnowWord: false, knowTime: 0)
        ]
    }
}

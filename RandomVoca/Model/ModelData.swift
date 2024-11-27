import Foundation

class ModelData: ObservableObject {
    @Published var words: [Word] = [] {
        didSet {
            saveWords() // words가 변경될 때마다 자동으로 저장
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
    
    func getSampleWords() -> [Word] {
        return [
            Word(name: "betray", meaning: "배신하다", isKnowWord: false, knowTime: 0),
            Word(name: "apply", meaning: "지원하다", isKnowWord: false, knowTime: 0),
            Word(name: "celebrate", meaning: "축하하다", isKnowWord: false, knowTime: 0),
            Word(name: "choose", meaning: "선택하다", isKnowWord: false, knowTime: 0),
            Word(name: "complain", meaning: "불평하다", isKnowWord: false, knowTime: 0),
            Word(name: "decide", meaning: "결정하다", isKnowWord: false, knowTime: 0),
            Word(name: "deny", meaning: "부인하다", isKnowWord: false, knowTime: 0),
            Word(name: "explain", meaning: "설명하다", isKnowWord: false, knowTime: 0),
            Word(name: "guess", meaning: "추측하다", isKnowWord: false, knowTime: 0),
            Word(name: "hurry", meaning: "서두르다", isKnowWord: false, knowTime: 0),
            Word(name: "imagine", meaning: "상상하다", isKnowWord: false, knowTime: 0),
            Word(name: "improve", meaning: "개선하다", isKnowWord: false, knowTime: 0),
            Word(name: "interrupt", meaning: "방해하다", isKnowWord: false, knowTime: 0),
            Word(name: "invite", meaning: "초대하다", isKnowWord: false, knowTime: 0),
            Word(name: "offer", meaning: "제안하다", isKnowWord: false, knowTime: 0),
            Word(name: "pretend", meaning: "척하다", isKnowWord: false, knowTime: 0),
            Word(name: "protect", meaning: "보호하다", isKnowWord: false, knowTime: 0),
            Word(name: "realize", meaning: "깨닫다", isKnowWord: false, knowTime: 0),
            Word(name: "recommend", meaning: "추천하다", isKnowWord: false, knowTime: 0),
            Word(name: "reduce", meaning: "줄이다", isKnowWord: false, knowTime: 0),
            Word(name: "refuse", meaning: "거절하다", isKnowWord: false, knowTime: 0),
            Word(name: "regret", meaning: "후회하다", isKnowWord: false, knowTime: 0),
            Word(name: "remember", meaning: "기억하다", isKnowWord: false, knowTime: 0),
            Word(name: "respect", meaning: "존경하다", isKnowWord: false, knowTime: 0),
            Word(name: "return", meaning: "돌아오다", isKnowWord: false, knowTime: 0),
            Word(name: "share", meaning: "공유하다", isKnowWord: false, knowTime: 0),
            Word(name: "shout", meaning: "외치다", isKnowWord: false, knowTime: 0),
            Word(name: "suggest", meaning: "제안하다", isKnowWord: false, knowTime: 0),
            Word(name: "survive", meaning: "생존하다", isKnowWord: false, knowTime: 0),
            Word(name: "trust", meaning: "믿다", isKnowWord: false, knowTime: 0),
            Word(name: "understand", meaning: "이해하다", isKnowWord: false, knowTime: 0),
            Word(name: "visit", meaning: "방문하다", isKnowWord: false, knowTime: 0),
            Word(name: "agree", meaning: "동의하다", isKnowWord: false, knowTime: 0),
            Word(name: "arrive", meaning: "도착하다", isKnowWord: false, knowTime: 0),
            Word(name: "assist", meaning: "돕다", isKnowWord: false, knowTime: 0),
            Word(name: "avoid", meaning: "피하다", isKnowWord: false, knowTime: 0),
            Word(name: "borrow", meaning: "빌리다", isKnowWord: false, knowTime: 0),
            Word(name: "bring", meaning: "가져오다", isKnowWord: false, knowTime: 0),
            Word(name: "build", meaning: "짓다", isKnowWord: false, knowTime: 0),
            Word(name: "carry", meaning: "운반하다", isKnowWord: false, knowTime: 0),
            Word(name: "catch", meaning: "잡다", isKnowWord: false, knowTime: 0),
            Word(name: "change", meaning: "변경하다", isKnowWord: false, knowTime: 0),
            Word(name: "clean", meaning: "청소하다", isKnowWord: false, knowTime: 0),
            Word(name: "close", meaning: "닫다", isKnowWord: false, knowTime: 0),
            Word(name: "connect", meaning: "연결하다", isKnowWord: false, knowTime: 0),
            Word(name: "control", meaning: "통제하다", isKnowWord: false, knowTime: 0),
            Word(name: "create", meaning: "창조하다", isKnowWord: false, knowTime: 0),
            Word(name: "decide", meaning: "결정하다", isKnowWord: false, knowTime: 0)
        ]
    }
}

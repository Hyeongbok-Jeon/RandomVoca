import Foundation
import SwiftUI

class ModelDataV2: ObservableObject {
    @Published var words: [WordEntity] = []

    init() {
        loadWords()
    }

    // ✅ Core Data에서 단어 불러오기
    func loadWords() {
        words = CoreDataHelper.shared.fetchWords()

#if DEBUG
        loadWordsFromJSON()
#else
        // Core Data에 데이터가 없으면 JSON에서 불러오기
        if words.isEmpty {
            print("⚠️ Core Data에 데이터가 없음. JSON에서 불러옵니다.")
            loadWordsFromJSON()
        } else {
            print("✅ Core Data에서 단어 \(words.count)개 불러옴")
        }
#endif
    }

    // ✅ JSON에서 불러와 Core Data에 저장
    func loadWordsFromJSON() {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            print("❌ JSON 파일을 찾을 수 없음")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedWords = try JSONDecoder().decode([[String: String]].self, from: data)

            // ✅ Core Data 기존 데이터 삭제 (Debug 모드일 때만)
#if DEBUG
            clearCoreData()
#endif
            
            // ✅ JSON 데이터를 Core Data에 저장
            let context = CoreDataHelper.shared.context
            for wordData in decodedWords {
                let newWord = WordEntity(context: context)
                newWord.id = UUID()  // ✅ Core Data의 UUID 자동 생성
                newWord.name = wordData["name"] ?? "Unknown"
                newWord.pronunciation = wordData["pronunciation"] ?? "Unknown"
                newWord.meaning = wordData["meaning"] ?? "Unknown"
            }
            
            // ✅ 저장
            CoreDataHelper.shared.saveContext()

            // ✅ 다시 Core Data에서 불러오기
            words = CoreDataHelper.shared.fetchWords()
            print("✅ JSON에서 단어 \(words.count)개 저장 완료")

        } catch {
            print("❌ JSON 디코딩 오류:", error)
        }
    }
    
    // ✅ Core Data 데이터 삭제 함수 (Debug 모드에서 기존 데이터를 초기화)
    private func clearCoreData() {
        let context = CoreDataHelper.shared.context
        let fetchRequest = WordEntity.fetchRequest()

        do {
            let existingWords = try context.fetch(fetchRequest)
            for word in existingWords {
                context.delete(word)
            }
            try context.save()
            print("🗑 Core Data 초기화 완료 (Debug 모드)")
        } catch {
            print("❌ Core Data 초기화 실패:", error)
        }
    }
}

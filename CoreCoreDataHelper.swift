import CoreData
import SwiftUI

class CoreDataHelper {
    static let shared = CoreDataHelper() // 싱글턴 인스턴스
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "WordModel")
        
        // ✅ Core Data 저장소 개수 확인
        print("🛠 Core Data 저장소 개수: \(container.persistentStoreDescriptions.count)")
        
        for store in container.persistentStoreDescriptions {
            print("✅ Core Data 스토어 위치: \(store.url?.absoluteString ?? "알 수 없음")")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ Core Data 로드 실패:", error)
            } else {
                print("✅ Core Data 로드 성공: \(storeDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    func insertWords(words: [Word]) {
        for word in words {
            let newWord = WordEntity(context: context)
            newWord.name = word.name
        }
        
        saveContext()

        // ✅ 저장된 데이터 개수 확인
        let request: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        do {
            let savedWords = try context.fetch(request)
            print("✅ 저장 후 Core Data 단어 개수: \(savedWords.count)")
            for word in savedWords {
                print("👉 저장된 단어: \(word.name ?? "이름 없음")")
            }
        } catch {
            print("❌ 데이터 저장 후 fetch 실패:", error)
        }
    }

    // ✅ 모든 단어 가져오기
    func fetchWords() -> [WordEntity] {
        print("✅ WordEntity fetch 요청 시작")

        let request: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        do {
            let fetchedWords = try context.fetch(request)
            print("✅ 불러온 단어 개수: \(fetchedWords.count)")
            for word in fetchedWords {
                print("👉 단어: \(word.name ?? "이름 없음")")
            }
            return fetchedWords
        } catch {
            print("❌ 단어 불러오기 실패:", error)
            return []
        }
    }

    // ✅ Core Data 저장
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data 저장 완료")
            } catch {
                print("❌ Core Data 저장 실패:", error)
            }
        } else {
            print("⚠️ 변경된 데이터 없음")
        }
    }
}

import StoreKit

@MainActor
class DonationManager: ObservableObject {
  @Published var products: [Product] = []

  init() {
    Task {
      await fetchProducts()
    }
  }

  func fetchProducts() async {
    do {
      let storeProducts = try await Product.products(for: ["donation_1100"])
      products = storeProducts
    } catch {
      print("❌ 상품 불러오기 실패: \(error)")
    }
  }

  func donate(_ product: Product) async {
    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        switch verification {
        case .verified(let transaction):
          print("✅ 후원 완료: \(transaction.productID)")
          await transaction.finish()
        case .unverified:
          print("⚠️ 후원 인증 실패")
        }
      case .userCancelled:
        print("🛑 사용자 취소")
      case .pending:
        print("⌛ 결제 보류 중")
      default:
        break
      }
    } catch {
      print("❌ 구매 실패: \(error)")
    }
  }
}

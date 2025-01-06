import StoreKit
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    @Published var hasLifetimePurchase: Bool = false
    let entriesLimit = 10  // Limit for the number of entries
    let collectionsLimit = 3 // Limit for the number of collections

    init() {
        checkSubscription()
        listenForTransactions()
    }

    func purchase() {
        Task {
            do {
                guard let product = try await Product.products(for: ["diaryLifetime"]).first else {
                    print("Product not found")
                    return
                }
                let result = try await product.purchase()
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await transaction.finish()
                        DispatchQueue.main.async {
                            self.hasLifetimePurchase = true
                            self.savePurchaseToPhp(price: transaction.price?.description ?? "0.0")
                        }
                    case .unverified(_, let error):
                        print("Unverified transaction: \(error.localizedDescription)")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                case .pending:
                    print("Purchase is pending.")
                @unknown default:
                    print("Unknown purchase result.")
                }
            } catch {
                print("Failed to purchase product: \(error)")
            }
        }
    }

    func checkSubscription() {
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result, transaction.productID == "diaryLifetime" {
                    DispatchQueue.main.async {
                        self.hasLifetimePurchase = true
                    }
                }
            }
        }
    }

    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    if transaction.productID == "diaryLifetime" {
                        DispatchQueue.main.async {
                            self.hasLifetimePurchase = true
                            self.savePurchaseToPhp(price: transaction.price?.description ?? "0.0")
                        }
                        await transaction.finish()
                    }
                case .unverified(_, _):
                    break
                }
            }
        }
    }

    func restorePurchases() {
        Task {
            do {
                try await AppStore.sync()
                print("Restore purchases initiated successfully.")
            } catch {
                print("Failed to restore purchases: \(error)")
            }
        }
    }

    private func savePurchaseToPhp(price: String) {
        guard let url = URL(string: "https://pokediaryapp.com/api/guardar_compra.php") else { return }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "precio", value: price)
        ]

        guard let requestURL = urlComponents?.url else { return }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error in savePurchaseToPhp: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    print("Purchase saved successfully via PHP endpoint.")
                }
            }
        }.resume()
    }
}

import StoreKit
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    @Published var hasLifetimePurchase: Bool = false
    let entriesLimit = 10

    init() {
        checkSubscription()
        listenForInitialTransactions()
    }

   

    func checkSubscription() {
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    DispatchQueue.main.async {
                        if transaction.productID == "pokeDiaryLifetime" {
                            self.hasLifetimePurchase = true
                           
                        }
                    }
                }
            }
        }
    }

    func purchase(productID: String) {
        Task {
            do {
                guard let product = try await Product.products(for: [productID]).first else { return }
                let result = try await product.purchase()
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await transaction.finish()
                        DispatchQueue.main.async {
                            self.hasLifetimePurchase = true
                           
                            self.savePurchasesPhp(price: transaction.price?.description ?? "0.0")
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

    func listenForInitialTransactions() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    DispatchQueue.main.async {
                        self.hasLifetimePurchase = true
                        
                        self.savePurchasesPhp(price: transaction.price?.description ?? "0.0")
                    }
                    await transaction.finish()
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

    private func savePurchasesPhp(price: String) {
       

        guard let url = URL(string: "https://rayjewelry.us/pokeDiary/guardar_compra.php") else { return }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "precio", value: price),
           
        ]

        guard let requestURL = urlComponents?.url else { return }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("ERROR \(error)")
                }
                return
            }

          

           
        }.resume()
    }

    
}

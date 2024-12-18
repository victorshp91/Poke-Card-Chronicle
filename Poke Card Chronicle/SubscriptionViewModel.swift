import StoreKit
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    @Published var hasLifetimePurchase: Bool = false

    init() {
        checkSubscription()
        // Listen for updates immediately at launch
        listenForInitialTransactions()
    }

    private func saveSubscriptionToLocalStorage() {
        // Guardar información de suscripción en almacenamiento local o algún otro lugar según la lógica deseada
    }

    func checkSubscription() {
        Task {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    DispatchQueue.main.async {
                        if transaction.productID == "pokeDiaryUnlimited" {
                            self.hasLifetimePurchase = true
                            self.saveSubscriptionToLocalStorage()
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
                            self.saveSubscriptionToLocalStorage()
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
                        self.saveSubscriptionToLocalStorage()
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
}

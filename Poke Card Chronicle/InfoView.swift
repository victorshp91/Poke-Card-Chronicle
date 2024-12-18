import SwiftUI

struct InfoView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @State var showPayWall: Bool = false
    var body: some View {
        List {
            Section(header: Text("App Information")) {
                Text("Privacy Policy")
                    .font(.subheadline)
                    .padding(.top)

                Button(action: {
                    // Open privacy policy
                }) {
                    Text("View More")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Text("Contact Support")
                    .font(.subheadline)
                    .padding(.top)

                Button(action: {
                    // Open support
                }) {
                    Text("Support")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }

                if  subscriptionViewModel.hasLifetimePurchase {
                    Text("Unlimited Subscription Status")
                        .font(.headline)
                        .foregroundColor(.green)

                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Unlimited Pokémon Diary entries")
                    }

                } else {
                    VStack(spacing: 16) {
                        Text("Unlock Unlimited Access")
                            .font(.headline)
                            .foregroundColor(.red)

                        Button(action: {
                            // Navigate to Paywall
                            showPayWall = true
                        }) {
                            Text("Subscribe Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showPayWall) {
            PaywallView(subscriptionViewModel: subscriptionViewModel)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(subscriptionViewModel: SubscriptionViewModel())
    }
}

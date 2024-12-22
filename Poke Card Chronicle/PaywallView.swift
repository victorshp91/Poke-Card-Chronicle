import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var animateIcon = false
    @State private var animateButton = false
    @State private var showSuccessMessage = false
    @State private var showPolicy = false
    @State private var showTerms = false
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
                .padding(16)
            }

            Text("Unlock Unlimited Poké Diary!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
                .multilineTextAlignment(.center)

            Spacer()

            ZStack {
                // Fondo animado
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateIcon)

                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .fill(Color.white)
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(360))

                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .fill(Color.red)
                    .frame(width: 180, height: 180)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: 180, height: 6)
                    .offset(y: 0)

                Circle()
                    .fill(Color.black)
                    .frame(width: 40, height: 40)

                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
            }
            .shadow(radius: 10)
            .onAppear {
                animateIcon = true
            }

            Spacer()

            Text("Keep track of all your Pokémon card adventures without limits. Purchase now to unlock unlimited entries. The free version allows only \(subscriptionViewModel.entriesLimit) entries across all cards.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Unlimited diary entries across all cards")
                }
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("One-time purchase, no subscriptions")
                }
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.blue)
                    Text("Join hundreds of users who already have unlimited access")
                }
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("The $29.99 offer is available for a limited time")
                }
            }
            .font(.headline)
            .padding(.vertical)
            .padding(.horizontal, 5)

            Spacer()

            Button(action: {
                subscriptionViewModel.purchase(productID: "pokeDiaryLifetime")
            }) {
                Text("Unlock for just $29.99")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .scaleEffect(animateButton ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateButton)
            }
            .padding(.horizontal)
            .onAppear {
                animateButton = true
            }

            Button(action: {
                subscriptionViewModel.restorePurchases()
            }) {
                Text("Already purchased? Restore your purchases")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            
            HStack {
                Button("Privacy Policy") {
                    showPolicy = true
                }
                Button("Terms & Conditions") {
                    showTerms = true
                }
                
            }.padding(.top)
            .foregroundColor(.accentColor)
            .sheet(isPresented: $showPolicy){
                PrivacyPolicyView()
            }.sheet(isPresented: $showTerms){
                TermsAndConditionsView()
            }

            Spacer()
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(
                title: Text("Success!"),
                message: Text("You now have unlimited access to Poké Diary."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onReceive(subscriptionViewModel.$hasLifetimePurchase) { status in
            if status  {
                showSuccessMessage = true
            }
        }
    }
}

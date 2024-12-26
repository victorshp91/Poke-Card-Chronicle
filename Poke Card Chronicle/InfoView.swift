import SwiftUI

struct InfoView: View {
    @StateObject var subscriptionViewModel: SubscriptionViewModel
    @State var showPayWall: Bool = false
    @State var showSupport: Bool = false
    @State var showPrivacy: Bool = false
    var appVersion: String {
            // Obtiene la versión desde el archivo Info.plist
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            return "Version \(version) (Build \(build))"
        }
    var body: some View {
       
            List {
                Section {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Privacy Policy")
//                            .font(.subheadline)
//                        
//                        Button(action: {
//                            showPrivacy = true
//                        }) {
//                            Text("View More")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contact Support")
                            .font(.subheadline)
                        
                        Button(action: {
                            showSupport = true
                        }) {
                            Text("Get Support")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                
                
                Section {
                    if subscriptionViewModel.hasLifetimePurchase {
                        HStack{
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unlimited Status")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                
                               
                                Text("Unlimited Pokémon Collections & Diary Entries")
                                    .font(.subheadline)
                                
                            }
                            Spacer()
                            Image("subscription")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text("Unlock Unlimited Access")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.leading)
                                    
                                    
                                    
                                    
                                    Text("Unlimited diary entries & collections across all cards. Free version allows only \(subscriptionViewModel.entriesLimit) entries & \(subscriptionViewModel.collectionsLimit) collections across all cards.").foregroundStyle(.secondary).font(.footnote)
                                }
                                Spacer()
                                Image("subscription")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height:45)
                            }
                            
                            
                            Button(action: {
                                showPayWall = true
                            }) {
                                Text("Purchase Now")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Section {
                    infoSection(title: "Privacy", icon: "lock.icloud", content: """
                        Your data are securely stored in your private iCloud with Apple's privacy standards. This means you can access this information from other devices, such as another iPhone, iPad, or Mac, using the same iCloud account.
                        """)
                }
                
                Section{
                    HStack{
                        VStack(alignment: .leading) {
                            
                            
                            Text("App Version")
                                .font(.headline)
                            
                            
                            Text(appVersion)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            
                        }
                        Spacer()
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                            
                }
                
                Section {
                    // Disclaimer Section
                    infoSection(title: "Disclaimer", icon: "info.circle", content: """
                        Poke Chronicle Cards - Diary is an independent, unofficial app and is not affiliated with, endorsed, sponsored, or specifically approved by any company. All product names, logos, and brands are the property of their respective owners.

                        Poke Chronicle Cards - Diary is designed for fans of trading cards and is intended for educational and entertainment purposes only. The app provides tools for managing and exploring trading card collections, including decks, market prices, and card details.

                        **Disclaimer:**
                        
                        - **Pokémon**: The Pokémon brand and all related images, names, and logos are trademarks of Nintendo, Game Freak, and Creatures. This app is not affiliated with or endorsed by these companies.
                        
                        - **Data**: The data provided by the app, including card information and market prices, is sourced from third-party services and may not always be accurate or up-to-date.
                        
                        - **Privacy**: Poke Chronicle Cards - Diary respects your privacy. Please refer to our Privacy Policy for details on how your data is collected, used, and protected.

                        By using Poke Chronicle Cards - Diary, you acknowledge and agree to these terms. If you have any questions or concerns, please contact us through our support channels.
                        """)
                }
                
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("APP INFO - SUPPORT")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showPayWall) {
                PaywallView(subscriptionViewModel: subscriptionViewModel)
            }
            .sheet(isPresented: $showSupport){
                SupportFormView()
            }.sheet(isPresented: $showPrivacy){
                PrivacyPolicyView()
            }
            .navigationBarItems(
                
                trailing: Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            )
            
        
        
        
    }
    
    // Función para crear secciones de información
    private func infoSection(title: String, icon: String, content: String, @ViewBuilder additionalContent: () -> AnyView = { AnyView(EmptyView()) }) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                  
                Text(title)
                    .font(.title3.bold())
                   
            }
            Text(content)
                .font(.body)
                .foregroundColor(.primary) // Color que se adapta a ambos modos
            additionalContent() // Contenido adicional (como el botón de compartir)
        }
        
        
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(subscriptionViewModel: SubscriptionViewModel())
    }
}

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .cards
    @StateObject var viewModel: CardViewModel = CardViewModel()
    @StateObject var subscriptionVm = SubscriptionViewModel()
    @AppStorage("showOnBoardingScreen") var showOnBoardingScreen = true
    @State var showTabBar: Bool = true

    var body: some View {
        ZStack {
            
            // Contenido de las vistas
            NavigationStack {
                
                CardListView(subscriptionViewModel: subscriptionVm, viewModel: viewModel)
            }
                        .opacity(selectedTab == .cards ? 1 : 0)
                        .scaleEffect(selectedTab == .cards ? 1 : 0.9)
                        //.animation(.easeInOut(duration: 0.3))
                        
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
                

            NavigationStack{
                AllEntriesView(viewModel: viewModel)
            }
                    .opacity(selectedTab == .allEntries ? 1 : 0)
                    .scaleEffect(selectedTab == .allEntries ? 1 : 0.9)
                    .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
            
                
            NavigationStack {
                FavoriteCardListView(isScrolling: $showTabBar, viewModel: viewModel, subscriptionViewModel: subscriptionVm)
            }
                    
                        .opacity(selectedTab == .favorites ? 1 : 0)
                        .scaleEffect(selectedTab == .favorites ? 1 : 0.9)
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
            
            NavigationStack {
                InfoView(subscriptionViewModel: subscriptionVm)
            }
                    
            .opacity(selectedTab == .about ? 1 : 0)
            .scaleEffect(selectedTab == .about ? 1 : 0.9)
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
                
            

            // Tab Bar flotante
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, isCollapsed: $showTabBar)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }.tint(.red)
        .edgesIgnoringSafeArea(.bottom) // Para que el Tab Bar flote
        .fullScreenCover(isPresented: $showOnBoardingScreen){
            
            OnboardingView(subscriptionViewModel: subscriptionVm, showOnBoardingScreen: $showOnBoardingScreen)
                .presentationDetents([.large])
        }
        
    }
}



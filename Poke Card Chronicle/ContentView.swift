import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .cards
    @StateObject var viewModel: CardViewModel = CardViewModel()

    var body: some View {
        ZStack {
            // Contenido de las vistas
            NavigationStack {
                
                    CardListView(viewModel: viewModel)
            }
                        .opacity(selectedTab == .cards ? 1 : 0)
                        .scaleEffect(selectedTab == .cards ? 1 : 0.9)
                        //.animation(.easeInOut(duration: 0.3))
                        
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
                

                
                    Text("MMG")
                        .opacity(selectedTab == .notifications ? 1 : 0)
                        .scaleEffect(selectedTab == .notifications ? 1 : 0.9)
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
                

                
                    Text("MMG")
                        .opacity(selectedTab == .favorites ? 1 : 0)
                        .scaleEffect(selectedTab == .favorites ? 1 : 0.9)
                        .animation(Animation.easeInOut(duration: 0.2), value: selectedTab)
                
            

            // Tab Bar flotante
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom) // Para que el Tab Bar flote
    }
}

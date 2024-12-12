import SwiftUI
import SDWebImageSwiftUI



struct Response: Decodable {
    let cards: [Card]
}

struct Set: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
}

struct Card: Identifiable, Decodable {
    let id: String
    let name: String
    let small_image_url: String
    let large_image_url: String
    let set_name: String
}

struct CardListView: View {
    

    
    @StateObject var viewModel: CardViewModel
    
    @State private var selectedSet: Set? = nil
    @State private var searchText: String = ""
    @State private var isSearchBarPresented: Bool = false


    private func getSetLogoURL(for setID: String) -> URL? {
        URL(string: "https://images.pokemontcg.io/\(setID)/logo.png")
    }

    private var filteredCards: [Card] {
        viewModel.cards.filter {
            (selectedSet == nil || $0.set_name == selectedSet!.id) &&
            (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
       
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading data...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                } else {
                    
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                                            ForEach(filteredCards) { card in
                                                NavigationLink(destination: CardEntryView(card: card, setName: setName(from: viewModel.sets , for: card.set_name))) { // Pasando el nombre del conjunto correspondiente
                                                    CardView(card: card, sets: viewModel.sets)
                                                    
                                                }
                                            }
                                        }
                                        
                    .padding(.horizontal)
                    .padding(.top, 100)
                }
            }
                    
                    .navigationBarTitle("Cards", displayMode: .inline)
                    .navigationBarItems(
                        leading: Text("\(filteredCards.count)")
                            .font(.headline)
                            .foregroundColor(.gray),
                        trailing: Button(action: { withAnimation { isSearchBarPresented.toggle() } }) {
                            Image(systemName: "magnifyingglass")
                        }
                    )
                    .overlay(
                        SearchBarView(text: $searchText, isPresented: $isSearchBarPresented)
                            .opacity(isSearchBarPresented ? 1 : 0)
                            .transition(.slide)
                            .zIndex(isSearchBarPresented ? 1 : 0),
                        alignment: .top
                    )
                    .overlay(
                        isSearchBarPresented && !viewModel.cards.isEmpty ? nil :
                        HStack {
                            Picker("Select Set", selection: $selectedSet) {
                                Text("All").tag(nil as Set?)
                                ForEach(viewModel.sets) { set in
                                    Text(set.name).tag(set as Set?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                            WebImage(url: selectedSet != nil ? getSetLogoURL(for: selectedSet!.id) : URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Pokémon_Trading_Card_Game_logo.svg/2560px-Pokémon_Trading_Card_Game_logo.svg.png")) { phase in
                                if let image = phase.image {
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 50)
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .frame(height: 75)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(10),
                        alignment: .top
                    )
                
            
            
        
        
    }



struct SearchBarView: View {
    @Binding var text: String
    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            TextField("Search cards...", text: $text)
            Button(action: { withAnimation { isPresented = false; text = "" } }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        .padding(10)
        .frame(height: 75)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(10)
    }
}

    struct CardView: View {
        let card: Card
        let sets: [Set]
        @State var animate = false
        
        var body: some View {
            VStack {
                WebImage(url: URL(string: card.small_image_url)) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
                            .transition(.scale)
                    } else {
                        ProgressView()
                            .frame(width: 150, height: 200)
                    }
                }
                Text(card.name)
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(.top, 4)
                    .frame(maxWidth: 150)
                    .multilineTextAlignment(.center)
                
                
                Text("\(setName(from: sets, for: card.set_name))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                    .frame(maxWidth: 150)
                    .multilineTextAlignment(.center)
                
            }
            .onAppear(perform: {
                animate = true
            })
            
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : 0.7)
                .animation(Animation.easeInOut(duration: 0.2), value: animate)
        }
        
    }
}

 func setName(from: [Set], for setID: String) -> String {
     return from.first { $0.id == setID }?.name ?? "Unknown Set"
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(viewModel: CardViewModel())
            .environmentObject(CardViewModel())
    }
}


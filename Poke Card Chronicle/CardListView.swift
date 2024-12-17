import SwiftUI
import SDWebImageSwiftUI



struct Response: Decodable {
    let cards: [Card]
}

struct Set: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
}

struct Card: Identifiable, Decodable, Hashable {
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
    @State private var actualSearch: String = ""
    @State private var isSearchBarPresented: Bool = false
    @Binding  var isScrolling: Bool
    
    @State private var showOnlyDiaryEntries: Bool = false // Controla si se filtran las cartas con DiaryEntry

    private var filteredCards: [Card] {
            let diaryEntriesSet = fetchAllDiaryEntriesIDs() // Pre-calculate DiaryEntry IDs
            
            return viewModel.cards.filter { card in
                let matchesSet = selectedSet == nil || card.set_name == selectedSet!.id
                let matchesSearch = actualSearch.isEmpty || card.name.localizedCaseInsensitiveContains(actualSearch)
                let hasDiaryEntry = diaryEntriesSet.contains(card.id)

                return matchesSet && matchesSearch && (!showOnlyDiaryEntries || hasDiaryEntry)
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
                    } else if filteredCards.isEmpty {
                        // Mostrar mensaje si no hay cartas para mostrar
                        VStack {
                            Image("noData")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                            Text("No cards to display")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                            ForEach(filteredCards) { card in
                                NavigationLink(destination: CardDiaryView(card: card, setName: setName(from: viewModel.sets , for: card.set_name), setId: card.set_name, viewModel: viewModel)) {
                                    CardView(card: card, sets: viewModel.sets)
                                    
                                    
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 100)
                    }
        }.scrollDismissesKeyboard(.immediately)
         
            .frame(maxWidth: .infinity)
            .navigationBarTitle("Cards", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Text("\(filteredCards.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                   
                ,
                trailing: HStack{
                    Button(action: {
                        showOnlyDiaryEntries.toggle()
                    }) {
                        Image(systemName: showOnlyDiaryEntries ? "book.fill" : "book")
                            .foregroundColor(.red)
                    }
                    Button(action: { withAnimation { isSearchBarPresented = true } }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.red)
                    }
                    
                }
            )
            .overlay(
                HStack{
                    SearchBarView(text: $searchText, isPresented: $isSearchBarPresented, actualSearch: $actualSearch, textPlaceHolder: "Search cards...")
                        .opacity(isSearchBarPresented ? 1 : 0)
                        .transition(.slide)
                        .zIndex(isSearchBarPresented ? 1 : 0)
                   if  isSearchBarPresented {
                        
                       Button(action: { actualSearch = searchText}){
                           Text("GO")
                               .padding()
                                   .background(.red)
                                   .foregroundStyle(.white)
                                   .cornerRadius(10)
                                   .padding(.trailing)
                        }
                       
                        
                    }
                    
                },
                alignment: .top
            )
            .overlay(
                !viewModel.isLoading &&  !viewModel.isLoadingSet && isSearchBarPresented ? nil :
                    HStack {
                        
                        // Botón para alternar visibilidad
                        Button(action: {
                            withAnimation {
                                isScrolling.toggle() // Cambiar el estado
                            }
                        }) {
                            Image(systemName: !isScrolling ? "chevron.right" : "chevron.left")
                            
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        if !isScrolling {
                            // Contenido del SetBar (Picker y WebImage)
                            Picker("Select Set", selection: $selectedSet) {
                                Text("All Sets").tag(nil as Set?)
                                ForEach(viewModel.sets) { set in
                                    Text(set.name).tag(set as Set?)
                                }
                            }.tint(.red)
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Spacer()
                        if selectedSet != nil {
                            // WebImage siempre visible
                            WebImage(url:  getSetLogoURL(for: selectedSet!.id) ) { phase in
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
                        } else {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 50)
                        }
                        
                        
                        
                        
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .frame(height: 75)
                    .frame(maxWidth: !isScrolling ? .infinity:150)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(10)
                
                    .animation(.easeInOut, value: !isScrolling),
                alignment: .top)
        
        
        
        
        
    }
    
    
    
    
    

    
    func fetchAllDiaryEntriesIDs() -> [String] {
            // Función que retorna los IDs de las cartas con DiaryEntry
            let fetchRequest = DiaryEntry.fetchRequest()
            if let results = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as [DiaryEntry] {
                return results.map { $0.cardId ?? "" }
            }
            return []
        }
}

 func setName(from: [Set], for setID: String) -> String {
     return from.first { $0.id == setID }?.name ?? "Unknown Set"
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(viewModel: CardViewModel(), isScrolling: Binding.constant(false))
            .environmentObject(CardViewModel())
    }
}


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
    @State private var isSetBarVisible: Bool = true // Controla la visibilidad del SetBar
    @State private var selectedSet: Set? = nil
    @State private var searchText: String = ""
    @State private var isSearchBarPresented: Bool = false
    
    
    @State private var showOnlyDiaryEntries: Bool = false // Controla si se filtran las cartas con DiaryEntry

    private var filteredCards: [Card] {
            let diaryEntriesSet = fetchAllDiaryEntriesIDs() // Pre-calculate DiaryEntry IDs
            
            return viewModel.cards.filter { card in
                let matchesSet = selectedSet == nil || card.set_name == selectedSet!.id
                let matchesSearch = searchText.isEmpty || card.name.localizedCaseInsensitiveContains(searchText)
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
            } else {
                
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    ForEach(filteredCards) { card in
                        NavigationLink(destination: CardDiaryView(card: card, setName: setName(from: viewModel.sets , for: card.set_name), setId: card.set_name)) { // Pasando el nombre del conjunto correspondiente
                            CardView(card: card, sets: viewModel.sets)
                            
                        }
                    }
                }
                
                .padding(.horizontal)
                .padding(.top, 100)
            }
        }.scrollDismissesKeyboard(.immediately)
        
            .navigationBarTitle("Cards", displayMode: .inline)
            .navigationBarItems(
                leading: HStack {
                    Text("\(filteredCards.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Button(action: {
                        showOnlyDiaryEntries.toggle()
                    }) {
                        Image(systemName: showOnlyDiaryEntries ? "book.fill" : "book")
                            .foregroundColor(.blue)
                    }
                },
                trailing: Button(action: { withAnimation { isSearchBarPresented = true } }) {
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
                !viewModel.isLoading &&  !viewModel.isLoadingSet && isSearchBarPresented ? nil :
                    HStack {
                        
                        // Botón para alternar visibilidad
                        Button(action: {
                            withAnimation {
                                isSetBarVisible.toggle() // Cambiar el estado
                            }
                        }) {
                            Image(systemName: isSetBarVisible ? "chevron.right" : "chevron.left")
                            
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        if isSetBarVisible {
                            // Contenido del SetBar (Picker y WebImage)
                            Picker("Select Set", selection: $selectedSet) {
                                Text("All").tag(nil as Set?)
                                ForEach(viewModel.sets) { set in
                                    Text(set.name).tag(set as Set?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Spacer()
                        
                        // WebImage siempre visible
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
                    .frame(maxWidth: isSetBarVisible ? .infinity:150)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(10)
                
                    .animation(.easeInOut, value: isSetBarVisible),
                alignment: .top)
        
        
        
        
        
    }
    
    
    
    struct SearchBarView: View {
        @Binding var text: String
        @Binding var isPresented: Bool
        @FocusState private var isTextFieldFocused: Bool
        
        var body: some View {
            HStack {
                TextField("Search cards...", text: $text)
                    .focused($isTextFieldFocused)
                    .onChange(of: isPresented) {
                        isTextFieldFocused = isPresented
                    }
                Button(action: { withAnimation { isPresented = false; text = ""; isTextFieldFocused = false } }) {
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
        @State private var entryCount: Int = 0 // Para almacenar la cantidad de entradas
        
        @State var animate = false
        
        var body: some View {
            VStack{
                ZStack(alignment: .bottom) {
                    
                    WebImage(url: URL(string: card.small_image_url))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
                            .transition(.scale)
                    } placeholder: {
                        WebImage(url: URL(string: card.large_image_url))
                            .resizable()
                            .scaledToFit()
                    }
                    
                    // Mostrar el entryCount en la esquina superior derecha
                    if entryCount > 0 {
                        HStack{
                            Image(systemName: "book")
                            Text("\(entryCount)")
                        }.padding()
                            .background(.ultraThinMaterial)
                        
                            .frame(minWidth: 75)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding()
                            .animation(.easeInOut, value: entryCount)
                    }
                    
                }
                
                
                
                
                Text(card.name)
                    .font(.caption).bold()
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
                    entryCount = fetchEntryCount(for: card.id, in: PersistenceController.shared.container.viewContext)
                })
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.7)
                .animation(Animation.easeInOut(duration: 0.2), value: animate)
                
               
            
        }}
    
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
        CardListView(viewModel: CardViewModel())
            .environmentObject(CardViewModel())
    }
}


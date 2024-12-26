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

    init(id: String = "" , name: String = "", small_image_url: String = "", large_image_url: String = " ", set_name: String = "") {
        self.id = id
        self.name = name
        self.small_image_url = small_image_url
        self.large_image_url = large_image_url
        self.set_name = set_name
    }
}

struct CardListView: View {
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @StateObject var viewModel: CardViewModel

    @State private var selectedSet: Set? = nil
    @State private var searchText: String = ""
    @State private var isSearchBarPresented: Bool = false
    @State private var isTopBarPresented: Bool = true
    @State private var showOnlyDiaryEntries: Bool = false
    @State private var filteredCards: [Card] = []
    @State private var showImageFullScreen = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading data...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    } else if filteredCards.isEmpty {
                        NoDataView(message: "No cards to display")
                    } else {
                        LazyVGrid(columns: getGridColumns()) {
                            ForEach(filteredCards) { card in
                                NavigationLink(destination: CardDiaryView(
                                    card: card,
                                    setName: setName(from: viewModel.sets, for: card.set_name),
                                    setId: card.set_name,
                                    viewModel: viewModel,
                                    subscriptionViewModel: subscriptionViewModel
                                )) {
                                    Text("")
                                   CardView(card: card, showImageFullScreen: $showImageFullScreen, cardViewModel: viewModel)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 85)
                    }
                }
                .padding(.top, 100)
            }
            .scrollDismissesKeyboard(.immediately)
            .frame(maxWidth: .infinity)
            .navigationBarTitle(Text("HOME"), displayMode: .inline)
            .navigationBarItems(
                leading: Text("\(filteredCards.count)")
                    .font(.headline)
                    .foregroundColor(.gray),
                trailing: HStack(spacing: 16) {
                    Button(action: { showOnlyDiaryEntries.toggle() }) {
                        Image(systemName: showOnlyDiaryEntries ? "book.fill" : "book")
                            .foregroundColor(.red)
                    }
                    Button(action: { withAnimation { isSearchBarPresented.toggle() } }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.red)
                    }
                }
            )
            .overlay(
                HStack {
                    SearchBarView(text: $searchText, isPresented: $isSearchBarPresented, actualSearch: $searchText, textPlaceHolder: "Search cards...")
                        .opacity(isSearchBarPresented ? 1 : 0)
                        .transition(.slide)
                        .zIndex(isSearchBarPresented ? 1 : 0)
                },
                alignment: .top
            )
            .overlay(
                isSearchBarPresented ? nil : topBarView,
                alignment: .top
            )

            if showImageFullScreen {
                ImageFullScreenView(showFullImage: $showImageFullScreen, cardViewModel: viewModel)
            }
        }
     
        .onChange(of: viewModel.cards) {
            applyFilters() // Vuelve a aplicar los filtros si cambia el arreglo de cartas.
        }
        .onChange(of: searchText) { applyFilters() }
        .onChange(of: selectedSet) {applyFilters() }
        .onChange(of: showOnlyDiaryEntries) {applyFilters() }
    }

    private var topBarView: some View {
        HStack {
            Button(action: { withAnimation { isTopBarPresented.toggle() } }) {
                Image(systemName: isTopBarPresented ? "chevron.right" : "chevron.left")
                    .font(.title2)
                    .foregroundColor(.red)
            }

            if isTopBarPresented {
                Picker("Select Set", selection: $selectedSet) {
                    Text("All Sets").tag(nil as Set?)
                    ForEach(viewModel.sets) { set in
                        Text(set.name).tag(set as Set?)
                    }
                }
                .tint(.red)
                .pickerStyle(MenuPickerStyle())
            }

            Spacer()

            if let logoURL = selectedSet.flatMap({ getSetLogoURL(for: $0.id) }) {
                WebImage(url: logoURL)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 50)
            } else {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 50)
            }
        }
        .padding(10)
        .frame(height: 75)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(10)
    }

    private func applyFilters() {
        let diaryEntriesSet = fetchAllDiaryEntriesIDs()
        filteredCards = viewModel.cards.filter { card in
            let matchesSet = selectedSet == nil || card.set_name == selectedSet!.id
            let matchesSearch = searchText.isEmpty || card.name.localizedCaseInsensitiveContains(searchText)
            let hasDiaryEntry = diaryEntriesSet.contains(card.id)
            return matchesSet && matchesSearch && (!showOnlyDiaryEntries || hasDiaryEntry)
        }
    }

    private func fetchAllDiaryEntriesIDs() -> [String] {
        let fetchRequest = DiaryEntry.fetchRequest()
        if let results = try? PersistenceController.shared.container.viewContext.fetch(fetchRequest) as [DiaryEntry] {
            return results.compactMap { $0.cardId }
        }
        return []
    }
}

func setName(from sets: [Set], for setID: String) -> String {
    return sets.first { $0.id == setID }?.name ?? "Unknown Set"
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(subscriptionViewModel: SubscriptionViewModel(), viewModel: CardViewModel())
            .environmentObject(CardViewModel())
    }
}

import SwiftUI
import CoreData

struct CollectionCardListView: View {
    @State private var showImageFullScreen = false // Estado para mostrar la imagen a tamaño completo
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
    }

    @State private var selectedSortOption: SortOption = .dateDescending
    @State private var isTopBarPresented: Bool = true

    let collection: Collections
    @StateObject var viewModel: CardViewModel
    @StateObject var subscriptionViewModel: SubscriptionViewModel

    // Combina los datos de `collectionToCards` con las cartas completas
    func cardsForCollection() -> [(Card, Date?)] {
        guard let cardRelationships = collection.collectionToCards as? Swift.Set<CardsForCollection> else { return [] }
        
        return cardRelationships.compactMap { relation in
            if let card = viewModel.cards.first(where: { $0.id == relation.cardId }) {
                return (card, relation.date)
            }
            return nil
        }
    }

    // Ordena las cartas combinadas según la opción seleccionada
    func sortCollectionCards(_ cards: [(Card, Date?)]) -> [(Card, Date?)] {
        switch selectedSortOption {
        case .dateDescending:
            return cards.sorted { $0.1 ?? Date() > $1.1 ?? Date() }
        case .dateAscending:
            return cards.sorted { $0.1 ?? Date() < $1.1 ?? Date() }
        case .nameAscending:
            return cards.sorted { $0.0.name < $1.0.name }
        case .nameDescending:
            return cards.sorted { $0.0.name > $1.0.name }
        }
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    let cards = cardsForCollection()
                    if cards.isEmpty {
                        NoDataView(message: "No cards in this collection yet")
                    } else {
                        LazyVGrid(columns: getGridColumns()) {
                            ForEach(sortCollectionCards(cards), id: \.0.id) { card, dateAdded in
                                NavigationLink(
                                    destination: CardDiaryView(
                                        card: card,
                                        setName: setName(from: viewModel.sets, for: card.set_name),
                                        setId: card.set_name,
                                        viewModel: viewModel,
                                        subscriptionViewModel: subscriptionViewModel
                                    )
                                ) {
                                    VStack {
                                        CardView(card: card, showImageFullScreen: $showImageFullScreen, cardViewModel: viewModel)
                                        if let dateAdded = dateAdded {
                                            Text("\(dateAdded, style: .date)")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                                .tint(.primary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 100)
                .navigationBarItems(
                    leading: Text("\(cardsForCollection().count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                   
                )
                .navigationTitle(collection.name ?? "Unnamed Collection")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
            }
            .overlay(
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isTopBarPresented.toggle()
                        }
                    }) {
                        Image(systemName: isTopBarPresented ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    if isTopBarPresented {
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedSortOption = option
                                }) {
                                    Text(option.rawValue)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                                .padding(8)
                                .foregroundStyle(.white)
                                .background(.red)
                                .cornerRadius(15)
                        }
                        Spacer()
                    }
                    Text("\(selectedSortOption.rawValue)").foregroundStyle(.secondary)
                }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .frame(height: 75)
                    .frame(maxWidth: isTopBarPresented ? .infinity : 220)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(10)
                    .animation(.easeInOut, value: isTopBarPresented),
                alignment: .top
            )

            if showImageFullScreen {
                ImageFullScreenView(showFullImage: $showImageFullScreen, cardViewModel: viewModel)
            }
        }
    }
}

//struct CollectionCardListView_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockCollection = Collections()
//        mockCollection.name = "My Collection"
//        
//        CollectionCardListView(
//            collection: mockCollection,
//            viewModel: CardViewModel(),
//            subscriptionViewModel: SubscriptionViewModel()
//        )
//    }
//}

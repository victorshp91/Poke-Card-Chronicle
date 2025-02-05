import SwiftUI
import CoreData

struct CollectionCardListView: View {
    @State private var showImageFullScreen = false // Estado para mostrar la imagen a tamaño completo
    @State private var showDeleteAlert = false // Estado para mostrar el alert de eliminación
    @State private var isTopBarPresented: Bool = true
    @Environment(\.presentationMode) var presentationMode
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
    }

    @State private var selectedSortOption: SortOption = .dateDescending
    @State private var showCollectionDescription: Bool = false
    @State private var showEditCollection: Bool = false
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
                                        setName: setName(from: viewModel.sets, for: card.set_id),
                                        setId: card.set_id,
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
                .navigationTitle(collection.name?.capitalized ?? "Unnamed Collection")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
                .navigationBarItems(
                    trailing:
                        
                        Menu {
                            
                            ShareCollectionButton(cardIds: cardsForCollection().map { $0.0.id }, collection: collection)
                            
                            Button(action: {
                                showEditCollection = true
                            }){
                                Label("Edit", systemImage: "square.and.pencil.circle")

                               
                            }
                            
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                Label("Delete", systemImage: "trash.circle")
                                
                            }
                            
                            Button(action: {
                                showCollectionDescription = true
                            }){
                                Label("About", systemImage: "info.circle")
                                
                            }
                            
                            
                        } label: {
                            Image(systemName: "ellipsis.circle.fill").bold()
                                .foregroundColor(.red)
                                .padding(8)
                        }
                        
                        
                        
                        
                        
                )
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
        .sheet(isPresented: $showEditCollection) {
            
            CreateCollectionView(cardViewModel: viewModel, collectionToEdit: collection)
            
        }
        .sheet(isPresented: $showCollectionDescription) {
            ScrollView(.vertical) {
                HStack{
                    VStack(alignment: .leading, spacing: 5) {
                        Text("About \(collection.name ?? "No Name") Collection")
                            .font(.headline)
                        
                        
                        Text(collection.about ?? "No description")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        
                        
                        Spacer()
                    }
                    Spacer()
                }.padding()
            }.frame(maxWidth: .infinity)
            
            .presentationDetents([.height(250)])
            
                
            
            
           
        }
        
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Collection"),
                message: Text("Are you sure you want to delete this collection and all its cards?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteCollectionAndCards(collection: collection)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

   
}

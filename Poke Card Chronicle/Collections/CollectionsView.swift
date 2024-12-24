//
//  CollectionsGridView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/22/24.
//


import SwiftUI
import CoreData

struct CollectionsGridView: View {
    // FetchRequest to retrieve collections from Core Data sorted by creationDate
    @FetchRequest(
        entity: Collections.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Collections.date, ascending: false)]
    ) var collections: FetchedResults<Collections>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @StateObject var cardViewModel: CardViewModel
    @StateObject var subscriptionViewModel: SubscriptionViewModel
    @State var showAddCollectionSheet: Bool = false
    var body: some View {
        
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Add new collection button
                    Button(action: {
                        showAddCollectionSheet = true
                    }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Add")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 175)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: FavoriteCardListView(viewModel: cardViewModel, subscriptionViewModel: subscriptionViewModel)) {
                        VStack(alignment: .center, spacing: 20) {
                            
                            // Agrupa el AccordionPokemonCardsView en una View principal para gestionar correctamente los gestos
                            AccordionPokemonCardsView(cardsId: cardViewModel.favorites.sorted(by: {
                                card1, card2 in
                                return card1.date ?? Date() > card2.date ?? Date()
                            })
                            .prefix(3) // Limita los resultados a las primeras tres cartas
                            .compactMap { $0.cardId }) // Mapea cada carta a su `cardId`, filtrando posibles valores nil
                            .offset(x: cardViewModel.favorites.isEmpty || cardViewModel.favorites.count == 1 ? 0 : -15)
                            Text("Favorites")
                                .foregroundColor(.primary)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 175)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    
                    ForEach(collections, id: \.self) { collection in
                        NavigationLink(destination: CollectionCardListView(collection: collection, viewModel: cardViewModel, subscriptionViewModel: subscriptionViewModel)) {
                            VStack(alignment: .center, spacing: 20) {
                                
                                
                                
                                
                                // Convierte la relación Core Data a un array, ordénala y procesa los IDs
                                let cards = (collection.collectionToCards as? Swift.Set<CardsForCollection>)?
                                    .sorted(by: { $0.date ?? Date() > $1.date ?? Date() }) // Ordena por fecha
                                    .prefix(3) // Limita a 3 cartas
                                    .compactMap { $0.cardId } ?? [] // Convierte a array de IDs
                                    
                                
                                AccordionPokemonCardsView(cardsId: cards)
                                    .offset(x: cards.isEmpty || cards.count == 1 ? 0 : -15)
                                
                                Text(collection.name ?? "Unnamed")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                            
                            .frame(maxWidth: .infinity, minHeight: 175)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .padding(.vertical, 10)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 75)
            }
            .navigationTitle("COLLECTIONS")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddCollectionSheet) {
                CreateCollectionView(cardViewModel: cardViewModel)
            }
        
        
    }
    
    
}

struct CollectionsGridView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsGridView(cardViewModel: CardViewModel(), subscriptionViewModel: SubscriptionViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

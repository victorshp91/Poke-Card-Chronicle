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
    
    var body: some View {
        
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Add new collection button
                    Button(action: {
                        addNewCollection()
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
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 175)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                    
                    // Display existing collections
                    ForEach(collections, id: \.self) { collection in
                        VStack {
                            Image(systemName: "tray.full")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                            Text(collection.name ?? "Unnamed")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 175)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("COLLECTIONS")
            .navigationBarTitleDisplayMode(.inline)
        
        
    }
    
    private func addNewCollection() {
        // Create a new collection in Core Data
        let newCollection = Collections(context: PersistenceController.shared.container.viewContext)
        newCollection.name = "New Collection \(collections.count + 1)"
        newCollection.date = Date() // Set the current date
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save new collection: \(error)")
        }
    }
}

struct CollectionsGridView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionsGridView(cardViewModel: CardViewModel(), subscriptionViewModel: SubscriptionViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

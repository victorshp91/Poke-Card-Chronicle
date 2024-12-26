//
//  CardViewModel.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/12/24.
//


import Combine
import SwiftUI
import CoreData

class CardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cardFullScreen: Card = Card()
    @Published var cards: [Card] = []
    @Published var selectedSet: Set? = nil
    @Published var sets: [Set] = []
    @Published var isLoading: Bool = true
    @Published var isLoadingSet: Bool = true
    @Published var favorites: [Favorites] = []
    @Published var collections: [Collections] = []
    
    

    // MARK: - URLs
    private let cardsJsonURL = URL(string: "https://pokediaryapp.com.rayjewelry.us/api/pokemon_cards.json")!
    private let setsJsonURL = URL(string: "https://pokediaryapp.com.rayjewelry.us/api/pokemon_set.json")!

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Initializer
    init() {
        fetchSets()
        fetchCards()
        fetchFavorites()
        fetchCollections()
    }

    // MARK: - Fetch Functions
    func fetchCollections() {
        let request: NSFetchRequest<Collections> = Collections.fetchRequest()
        do {
            collections = try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            print("Error fetching collections: \(error)")
        }
    }

    func fetchCards() {
        URLSession.shared.dataTask(with: cardsJsonURL) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        withAnimation {
                            self.cards = decodedResponse.cards.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("Failed to decode JSON:", error)
                }
            } else if let error = error {
                print("Failed to fetch data:", error)
            }
        }.resume()
    }

    func fetchSets() {
        URLSession.shared.dataTask(with: setsJsonURL) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([Set].self, from: data)
                    DispatchQueue.main.async {
                        withAnimation {
                            self.sets = decodedResponse.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                            self.isLoadingSet = false
                        }
                    }
                } catch {
                    print("Failed to decode JSON:", error)
                }
            } else if let error = error {
                print("Failed to fetch data:", error)
            }
        }.resume()
    }

    func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        do {
            favorites = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }

    // MARK: - Collection Management
    
    
    
    func deleteCollectionAndCards(collection: Collections) {
        if let cards = collection.collectionToCards?.allObjects as? [CardsForCollection] {
            for card in cards {
                PersistenceController.shared.container.viewContext.delete(card)
            }
        }
        PersistenceController.shared.container.viewContext.delete(collection)
        fetchCollections()
        try? PersistenceController.shared.container.viewContext.save()
    }

    func addCardToCollection(cardId: String, collection: Collections) {
        let newCardForCollection = CardsForCollection(context: PersistenceController.shared.container.viewContext)
        newCardForCollection.cardId = cardId
        newCardForCollection.date = Date()
        collection.addToCollectionToCards(newCardForCollection)

        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func removeCardFromCollection(cardId: String, collection: Collections) {
        if let existingRelation = collection.collectionToCards?.compactMap({ $0 as? CardsForCollection }).first(where: { $0.cardId == cardId }) {
            collection.removeFromCollectionToCards(existingRelation)
            do {
                try PersistenceController.shared.container.viewContext.save()
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func isCardInAnyCollection(cardId: String) -> Bool {
        return collections.contains(where: {
            $0.collectionToCards?.contains(where: { ($0 as AnyObject).cardId == cardId }) ?? false
        })
    }

    func isCardInCollection(cardId: String, collection: Collections) -> Bool {
        return collection.collectionToCards?.contains(where: { ($0 as AnyObject).cardId == cardId }) ?? false
    }
    
    
    func countCollectionsContainingCard(cardId: String) -> Int {
        return collections.filter {
            $0.collectionToCards?.contains {
                ($0 as? CardsForCollection)?.cardId == cardId
            } ?? false
        }.count
    }
    
    func countCards(in collection: Collections) -> Int {
        return collection.collectionToCards?.count ?? 0
    }

    // MARK: - Favorites Management
    func isFavorite(cardId: String) -> Bool {
        return favorites.contains(where: { $0.cardId == cardId })
    }

    func saveFavorite(cardId: String) {
        if let favorite = favorites.first(where: { $0.cardId == cardId }) {
            PersistenceController.shared.container.viewContext.delete(favorite)
        } else {
            let newFavorite = Favorites(context: PersistenceController.shared.container.viewContext)
            newFavorite.cardId = cardId
            newFavorite.date = Date()
            newFavorite.id = UUID()
        }

        do {
            try PersistenceController.shared.container.viewContext.save()
            fetchFavorites()
        } catch {
            print("Failed to save favorite: \(error)")
        }
    }
}

// MARK: - Utility Functions
func getSetLogoURL(for setID: String) -> URL? {
    URL(string: "https://images.pokemontcg.io/\(setID)/logo.png")
}

func getSmallImageURL(for cardId: String) -> URL? {
    let components = cardId.split(separator: "-")
    guard components.count == 2 else {
        return nil
    }
    let setPart = components[0]
    let cardNumberPart = components[1]
    return URL(string: "https://images.pokemontcg.io/\(setPart)/\(cardNumberPart).png")
}

func fetchEntryCount(for cardId: String, in context: NSManagedObjectContext) -> Int {
    let fetchRequest: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "cardId == %@", cardId)

    do {
        return try context.count(for: fetchRequest)
    } catch {
        print("Failed to fetch entry count: \(error)")
        return 0
    }
}

func deleteEntry(_ entry: DiaryEntry) {
    if let images = entry.entryToImages as? Swift.Set<ImageEntry> {
        for image in images {
            PersistenceController.shared.container.viewContext.delete(image)
        }
    }
    PersistenceController.shared.container.viewContext.delete(entry)

    do {
        try PersistenceController.shared.container.viewContext.save()
    } catch {
        print("Error deleting entry: \(error.localizedDescription)")
    }
}

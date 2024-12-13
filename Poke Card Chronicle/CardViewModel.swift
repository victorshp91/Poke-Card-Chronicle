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
    @Published var cards: [Card] = [] // Estado compartido para las cartas
    @Published var selectedSet: Set? = nil // Estado compartido para el set seleccionado
    @Published  var sets: [Set] = []
    @Published  var isLoading: Bool = true
    @Published var isLoadingSet: Bool = true
     let cardsJsonURL = URL(string: "https://rayjewelry.us/chronicle/pokemon_cards.json")!
     let setsJsonURL = URL(string: "https://rayjewelry.us/chronicle/pokemon_set.json")!
    
  
   
    init() {
       
        fetchSets()
        fetchCards()
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
                            self.sets = decodedResponse.reversed()
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
    
   
     
}

func getSetLogoURL(for setID: String) -> URL? {
   URL(string: "https://images.pokemontcg.io/\(setID)/logo.png")
}

func fetchEntryCount(for cardId: String, in context: NSManagedObjectContext) -> Int {
    let fetchRequest: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "cardId == %@", cardId)
    
    do {
        let count = try context.count(for: fetchRequest)
        return count
    } catch {
        print("Failed to fetch entry count: \(error)")
        return 0
    }
}

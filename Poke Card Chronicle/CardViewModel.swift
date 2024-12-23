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
    @Published var cardFullScreen: Card = Card()
    @Published var cards: [Card] = [] // Estado compartido para las cartas
    @Published var selectedSet: Set? = nil // Estado compartido para el set seleccionado
    @Published  var sets: [Set] = []
    @Published  var isLoading: Bool = true
    @Published var isLoadingSet: Bool = true
    @Published var favorites: [Favorites] = [] // Array de favoritos
     let cardsJsonURL = URL(string: "https://rayjewelry.us/chronicle/pokemon_cards.json")!
     let setsJsonURL = URL(string: "https://rayjewelry.us/chronicle/pokemon_set.json")!
    
    @Environment(\.colorScheme) var colorScheme
   
    init() {
       
        fetchSets()
        fetchCards()
        fetchFavorites()
        
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
            // Cargar favoritos desde Core Data o cualquier fuente de datos
            let fetchRequest: NSFetchRequest<Favorites> = Favorites.fetchRequest()
            do {
                favorites = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
               
            } catch {
                print("Failed to fetch favorites: \(error)")
            }
        }
    
    
    // Esta función busca la carta directamente en el array del viewModel
    func isFavorite(cardId: String) -> Bool {
           return favorites.contains(where: { $0.cardId == cardId })
       }
   
    func saveFavorite(cardId: String) {
            if let favorite = favorites.first(where: { $0.cardId == cardId }) {
                // Eliminar la carta de favoritos si ya está en favoritos
                PersistenceController.shared.container.viewContext.delete(favorite)
            } else {
                // Agregar la carta a favoritos si no está presente
                let newFavorite = Favorites(context: PersistenceController.shared.container.viewContext)
                newFavorite.cardId = cardId
                newFavorite.date = Date()
                newFavorite.id = UUID()
            }

            do {
                try PersistenceController.shared.container.viewContext.save()
                fetchFavorites() // Actualizar la lista de favoritos después de guardar
            } catch {
                print("Failed to save favorite: \(error)")
            }
        }
     
}

func getSetLogoURL(for setID: String) -> URL? {
   URL(string: "https://images.pokemontcg.io/\(setID)/logo.png")
}


// Función que genera la URL para obtener la imagen pequeña de una carta según su ID.
func getSmallImageURL(for cardId: String) -> URL? {
    // Dividir el `cardId` en dos partes separadas por el guion "-" (por ejemplo, "sv4-26" se convierte en ["sv4", "26"]).
    let components = cardId.split(separator: "-")
    
    // Verificar que el resultado tiene exactamente dos partes. Si no, devolvemos `nil` porque el formato es inválido.
    guard components.count == 2 else {
        return nil
    }
    
    // Asignar la primera parte (antes del "-") a `setPart`.
    let setPart = components[0]
    
    // Asignar la segunda parte (después del "-") a `cardNumberPart`.
    let cardNumberPart = components[1]
    
    // Construir la URL usando ambas partes. La primera parte (`setPart`) representa el set de cartas,
    // y la segunda parte (`cardNumberPart`) representa el número de la carta dentro del set.
    return URL(string: "https://images.pokemontcg.io/\(setPart)/\(cardNumberPart).png")
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

func deleteEntry(_ entry: DiaryEntry) {
    // Si tienes relaciones específicas a manejar
    if let images = entry.entryToImages as? Swift.Set<ImageEntry> {
        for image in images {
            PersistenceController.shared.container.viewContext.delete(image)
        }
    }
    
    // Luego eliminar la entrada principal
    PersistenceController.shared.container.viewContext.delete(entry)
        
    do {
        try PersistenceController.shared.container.viewContext.save()
    } catch {
        // Manejar errores aquí
        print("Error al eliminar la entrada: \(error.localizedDescription)")
    }
}





import SwiftUI
import CoreData

struct ShareCollectionButton: View {
    let cardIds: [String]
    var collection: Collections?
    @State private var shareId: String?
    
    var body: some View {
        Button(action: {
            sharePage()
        }){
            Label("Share \(collection?.shareId ?? "")", systemImage: "square.and.arrow.up")
        }
        .onAppear {
            shareId = collection?.shareId
            print("ShareID actual:", shareId ?? "nil")
        }
    }
    
    func sharePage() {
        if cardIds.isEmpty {
            presentAlert(message: "Cannot share because there are no cards in the collection.")
            return
        }
        
        if let existingShareId = collection?.shareId {
            print("Using existing shareId:", existingShareId)
            updateShareData(existingShareId)
            return
        }
        
        print("Creating new shareId...")
        
        let baseUrl = "https://pokediaryapp.com/api/collection.php"
        let idsString = cardIds.joined(separator: ",")
        
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "ids", value: idsString),
            URLQueryItem(name: "title", value: collection?.name ?? "Unnamed Collection"),
            URLQueryItem(name: "description", value: collection?.about ?? "Check out my Pokémon card collection!"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud HTTP:", error)
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ShareResponse.self, from: data)
                print("ShareId recibido del servidor:", response.shareId)
                
                DispatchQueue.main.async {
                    if let collection = collection {
                        saveShareId(response.shareId, for: collection)
                        self.shareId = response.shareId
                    }
                    shareWithId(response.shareId)
                }
            } catch {
                print("Error decodificando respuesta:", error)
                print("Datos recibidos:", String(data: data, encoding: .utf8) ?? "No se pueden mostrar los datos")
            }
        }.resume()
    }
    
    private func updateShareData(_ shareId: String) {
        print("Actualizando colección con shareId:", shareId)
        let baseUrl = "https://pokediaryapp.com/api/collection.php"
        let idsString = cardIds.joined(separator: ",")
        let title = collection?.name ?? "Unnamed Collection"
        let description = collection?.about ?? "Check out my Pokémon card collection!"
        
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "ids", value: idsString),
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "description", value: description),
            URLQueryItem(name: "id", value: shareId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "action", value: "update")
        ]
        
        guard let url = urlComponents?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud HTTP:", error)
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ShareResponse.self, from: data)
                print("ShareId actualizado en el servidor:", response.shareId)
                
                DispatchQueue.main.async {
                    shareWithId(response.shareId)
                }
            } catch {
                print("Error decodificando respuesta:", error)
                print("Datos recibidos:", String(data: data, encoding: .utf8) ?? "No se pueden mostrar los datos")
            }
        }.resume()
    }
    
    private func saveShareId(_ shareId: String, for collection: Collections) {
        let context = PersistenceController.shared.container.viewContext
        
        context.perform {
            collection.shareId = shareId
            print("Intentando guardar shareId:", shareId)
            
            guard !collection.isDeleted else {
                print("Error: La colección ha sido eliminada")
                return
            }
            
            do {
                try context.save()
                print("ShareId guardado exitosamente:", shareId)
                
                context.refresh(collection, mergeChanges: true)
                if let savedShareId = collection.shareId {
                    print("Verificación: ShareId en CoreData:", savedShareId)
                }
            } catch {
                print("Error guardando en CoreData:", error)
                context.rollback()
            }
        }
    }
    
    private func shareWithId(_ shareId: String) {
        let shareUrl = "https://pokediaryapp.com/api/collection.php?id=\(shareId)"
        guard let url = URL(string: shareUrl) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

struct ShareResponse: Codable {
    let shareId: String
}

import Foundation
import SwiftUI
import CoreData

class RenderImage: ObservableObject {
    @Published var renderedImage = Image(systemName: "photo") // Para almacenar la imagen generada
    @Published var downloadedImage: Image? = nil
    @Published var downloadedImageSet: Image? = nil

    func downloadImage(cardImageUrl url: String, card: Card, diaryEntry: DiaryEntry, setImageUrl urlSet: String) {
        guard let imageUrl = URL(string: url), let setImageUrl = URL(string: urlSet) else { return }

        let group = DispatchGroup()

        // Start downloading the card image
        group.enter()
        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.downloadedImage = Image(uiImage: uiImage)
                    group.leave()
                }
            } else {
                group.leave()
            }
        }.resume()

        // Start downloading the set image
        group.enter()
        URLSession.shared.dataTask(with: setImageUrl) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.downloadedImageSet = Image(uiImage: uiImage)
                    group.leave()
                }
            } else {
                group.leave()
            }
        }.resume()

        // Wait for both downloads to complete
        group.notify(queue: .main) {
            // Ensure that the call to render is made on the main actor
            Task { @MainActor in
                self.render(card: card, diaryEntry: diaryEntry)
            }
        }
    }

    @MainActor private func render(card: Card, diaryEntry: DiaryEntry) {
        let renderer = ImageRenderer(content: cardImageShareView(entry: diaryEntry, card: card, downloadedImage: downloadedImage, cardLogo: downloadedImageSet))

        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

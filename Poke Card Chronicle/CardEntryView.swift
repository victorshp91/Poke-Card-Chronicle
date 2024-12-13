import SwiftUI
import SDWebImageSwiftUI
import UIKit
import CoreData

struct CardEntryView: View {
    let card: Card // ID de la carta como string
    let setName: String
    @State private var entryText: String = "" // Entry text
    @State private var entryTitle: String = ""
    @State private var selectedDate: Date = Date() // Selected date
    @State private var selectedImages: [UIImage] = [] // Array to hold selected images
    @State private var showImagePicker: Bool = false // To toggle image picker
    @State private var showSuccessAlert: Bool = false // Alert for success
  
    
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    private let context = PersistenceController.shared.container.viewContext // Core Data context

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
            }

            Section(header: Text("Title")) {
                VStack(spacing: 10) {
                    TextEditor(text: $entryTitle)
                        .frame(height: 40)
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: entryTitle) {
                            if entryTitle.count > 55 {
                                entryTitle = String(entryTitle.prefix(55))
                            }
                        }

                    HStack {
                        Text("Remaining:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(55 - entryTitle.count)")
                            .font(.caption)
                            .foregroundColor(entryTitle.count > 55 ? .red : .gray)
                    }
                }
            }

            Section(header: Text("Diary Entry")) {
                VStack(spacing: 10) {
                    TextEditor(text: $entryText)
                        .frame(height: 100)
                        .padding(5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onChange(of: entryText) {
                            if entryText.count > 255 {
                                entryText = String(entryText.prefix(255))
                            }
                        }

                    HStack {
                        Text("Remaining:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(255 - entryText.count)")
                            .font(.caption)
                            .foregroundColor(entryText.count > 255 ? .red : .gray)
                    }
                }
            }

            Section(header:
                HStack {
                    Text("Add Photos")
                    Spacer()
                    if selectedImages.count != 3 {
                        Button(action: { showImagePicker.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .cornerRadius(10)

                                Button(action: {
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.red)
                                        .cornerRadius(20)
                                }
                                .padding(5)
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImages) {
            ImagePicker(images: $selectedImages)
        }
        .navigationBarItems(trailing: Button(action: saveEntry) {
            Text("Save")
                .font(.headline)
                .foregroundColor(isFormValid() ? .blue : .gray)
        }
        .disabled(!isFormValid()))
        .navigationTitle("Entry \(card.name)")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("Success"), message: Text("Your entry has been saved"), dismissButton: .default(Text("OK")) {
                presentationMode.wrappedValue.dismiss() // Close the view
            })
        }

    }

    private func isFormValid() -> Bool {
        // Ensure required fields are not empty
        return !entryTitle.isEmpty && !entryText.isEmpty
    }

    private func saveEntry() {
        guard isFormValid() else {
            
            return
        }

        let newEntry = DiaryEntry(context: context)
        newEntry.id = UUID()
        newEntry.entryTitle = entryTitle
        newEntry.entryText = entryText
        newEntry.entryDate = selectedDate
        newEntry.cardId = card.id // Asociación usando solo el ID

        // Guardar imágenes como entidades separadas en ImageEntry
        let imageEntries = selectedImages.map { image in
            let imageEntry = ImageEntry(context: context)
            imageEntry.id = UUID()
            imageEntry.image = image.jpegData(compressionQuality: 1.0) // Convertir a Data
            return imageEntry
        }

        // Asociar imágenes al nuevo Entry
        newEntry.images = NSSet(array: imageEntries)

        do {
            try context.save()
            showSuccessAlert = true
        } catch {
            print(error.localizedDescription)
            
        }
    }

    private func loadImages() {
        // Handle loading of selected images if necessary
    }
}

struct CardEntryView_Previews: PreviewProvider {
    static var previews: some View {
        CardEntryView(card: Card(id: "1", name: "dasd", small_image_url: "", large_image_url: "", set_name: "Dasda"), setName: "150")
    }
}




import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage] // Binding para las imágenes seleccionadas
    @Environment(\.presentationMode) var presentationMode // Para cerrar el picker

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImages = info[.editedImage] as? UIImage {
                parent.images.append(selectedImages)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

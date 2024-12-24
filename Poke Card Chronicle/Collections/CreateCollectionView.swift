//
//  CreateCollectionView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/23/24.
//


import SwiftUI

struct CreateCollectionView: View {
   

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isFormSubmitted: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @StateObject var cardViewModel: CardViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        VStack(spacing: 0) {
                
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                }
                
                if isFormSubmitted {
                    VStack(spacing: 20) {
                        
                        Text("Collection Created!")
                            .font(.headline)
                            .foregroundColor(.green)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)

                        Text("Your collection has been successfully created. You can add Cards to it later.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    Form {
                        Section(header: Text("Collection Name")) {
                            TextField("", text: $name)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .frame(height: 35)
                                .padding(5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)

                         
                                
                        }
                        .listRowBackground(Color.clear)
                        
                        
                        Section(header: Text("Description")) {
                            

                            TextEditor(text: $description)
                                .frame(height: 150)
                                .padding(5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                
                        }
                        .listRowBackground(Color.clear)
                        Button(action: createCollection) {
                            Text("Create Collection")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            Spacer()
            }.background(Color(.systemGroupedBackground))
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Create Collection"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        
    }

    private func createCollection() {
        guard !name.isEmpty, !description.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        let newCollection = Collections(context: PersistenceController.shared.container.viewContext)
        newCollection.name = name
        newCollection.about = description
        newCollection.date = Date()

        do {
            try PersistenceController.shared.container.viewContext.save()
            cardViewModel.fetchCollections()
            isFormSubmitted = true
        } catch {
            alertMessage = "Failed to save collection: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct CreateCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateCollectionView(cardViewModel: CardViewModel())
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .preferredColorScheme(.dark)
            
            CreateCollectionView(cardViewModel: CardViewModel())
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}

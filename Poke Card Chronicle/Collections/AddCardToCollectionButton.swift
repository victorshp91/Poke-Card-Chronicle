import SwiftUI

struct AddCardToCollectionButton: View {
    @State var showMenu: Bool = false // Default is false
    @StateObject var viewModel: CardViewModel
    var cardId: String
    @State private var message: String? // State for the message
    @State private var showMessage: Bool = false // State to control visibility of the message
    @State private var showAddCollection = false
    @State private var searchText: String = ""
    var body: some View {
        Button(action: {
            showMenu.toggle()
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: viewModel.isCardInAnyCollection(cardId: cardId) ? "tray.full" : "tray")
                    .resizable()
                    .scaledToFit()
                    .tint(.secondary)
                    
                
                if viewModel.countCollectionsContainingCard(cardId: cardId) > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.red) // Color del fondo de la insignia
                            .frame(width: 15, height: 15) // Tamaño de la insignia
                        
                        Text("\(viewModel.countCollectionsContainingCard(cardId: cardId))")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .offset(x: 2, y: -1) // Ajusta la posición de la insignia
                }
            }
        }
        .sheet(isPresented: $showMenu) {
            NavigationView {
                VStack{
                    List {
                        ForEach(viewModel.collections
                            .sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
                            .filter {
                                searchText.isEmpty ? true : ($0.name?.lowercased().contains(searchText.lowercased()) ?? false)
                            }, id: \.self) { collection in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(collection.name ?? "Unnamed")
                                            .font(.headline)
                                        Text("\(viewModel.countCards(in: collection)) Cards")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if viewModel.isCardInCollection(cardId: cardId, collection: collection) {
                                        Button(action: {
                                            viewModel.removeCardFromCollection(cardId: cardId, collection: collection)
                                            message = "Card removed from \(collection.name ?? "") collection"
                                            showMessage = true
                                            viewModel.fetchCollections()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                    } else {
                                        Button(action: {
                                            viewModel.addCardToCollection(cardId: cardId, collection: collection)
                                            message = "Card added to \(collection.name ?? "") collection"
                                            showMessage = true
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                          
                            // Botón para agregar una nueva entrada
                            Button(action: {
                                showAddCollection = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.blue)
                            }
                        }.frame(maxHeight: 35)
                    }
                }
                
                .navigationTitle("Select Collection")
                .searchable(text: $searchText)
                .alert(isPresented: $showMessage) {
                    Alert(title: Text(message ?? ""))
                }.sheet(isPresented: $showAddCollection) {
                    
                    CreateCollectionView(cardViewModel: viewModel)
                    
                }
                
            }.presentationDetents([.medium])
        }
    }
}

struct AddCardToCollectionButton_Previews: PreviewProvider {
    static var previews: some View {
        AddCardToCollectionButton(viewModel: CardViewModel(), cardId: "")
    }
}

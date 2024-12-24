import SwiftUI

struct AddCardToCollectionButton: View {
    @State var showMenu: Bool = false // Default is false
    @StateObject var viewModel: CardViewModel
    var cardId: String
    @State private var message: String? // State for the message
    @State private var showMessage: Bool = false // State to control visibility of the message

    @State private var searchText: String = ""
    var body: some View {
        Button(action: {
            showMenu.toggle()
        }) {
            Image(systemName: viewModel.isCardInAnyCollection(cardId: cardId) ? "tray.full.fill" : "tray.full.fill")
                .resizable()
                .scaledToFit()
                .tint(viewModel.isCardInAnyCollection(cardId: cardId) ? .red : .secondary)
        }
        .popover(isPresented: $showMenu) {
            NavigationView {
                List {
                    ForEach(viewModel.collections.filter {
                        searchText.isEmpty ? true : ($0.name?.lowercased().contains(searchText.lowercased()) ?? false)
                    }, id: \.self) { collection in
                        HStack {
                            Text(collection.name ?? "Unnamed")
                            Spacer()
                            if viewModel.isCardInCollection(cardId: cardId, collection: collection) {
                                Button(action: {
                                    viewModel.removeCardFromCollection(cardId: cardId, collection: collection)
                                    message = "Card removed from collection" // Set message
                                    showMessage = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            } else {
                                Button(action: {
                                    viewModel.addCardToCollection(cardId: cardId, collection: collection)
                                    message = "Card added to collection" // Set message
                                    showMessage = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select Collection")
                .searchable(text: $searchText)
                .alert(isPresented: $showMessage) {
                    Alert(title: Text(message ?? ""))
                }
            }
        }
    }
}

struct AddCardToCollectionButton_Previews: PreviewProvider {
    static var previews: some View {
        AddCardToCollectionButton(viewModel: CardViewModel(), cardId: "")
    }
}

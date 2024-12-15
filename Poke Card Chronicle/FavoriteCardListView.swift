//
//  FavoriteCardListView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/14/24.
//


import SwiftUI
import CoreData

struct FavoriteCardListView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.date, ascending: false)])
    private var favorites: FetchedResults<Favorites>
    @StateObject var viewModel: CardViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                ForEach(favorites, id: \.self) { favorite in
                    
                    if let card = viewModel.cards.first(where: { $0.id == favorite.cardId }) {
                        NavigationLink(destination: CardDiaryView(card: card, setName: setName(from: viewModel.sets , for: card.set_name), setId: card.set_name, viewModel: viewModel)) {
                            CardView(card: card, sets: viewModel.sets)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }.padding()
            
                .padding(.bottom, 75)
        }.navigationBarItems(
            leading:
                Text("\(favorites.count)")
                    .font(.headline)
                    .foregroundColor(.gray)
            )
        .navigationTitle("Favorite Cards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FavoriteCardListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCardListView(viewModel: CardViewModel())
    }
}

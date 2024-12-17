//
//  FavoriteCardListView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/14/24.
//


import SwiftUI
import CoreData

struct FavoriteCardListView: View {
    @Binding var isScrolling: Bool
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
    }

    @State private var selectedSortOption: SortOption = .dateDescending
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.date, ascending: false)])
    private var favorites: FetchedResults<Favorites>
    @StateObject var viewModel: CardViewModel
    
    func sortFavorites(_ favorites: [Favorites], cards: [Card]) -> [Favorites] {
        switch selectedSortOption {
        case .dateDescending:
            return favorites.sorted { $0.date ?? Date() > $1.date ?? Date() }
        case .dateAscending:
            return favorites.sorted { $0.date ?? Date() < $1.date ?? Date() }
        case .nameAscending:
            return favorites.sorted { favorite1, favorite2 in
                let name1 = cards.first(where: { $0.id == favorite1.cardId })?.name ?? ""
                let name2 = cards.first(where: { $0.id == favorite2.cardId })?.name ?? ""
                return name1 < name2
            }
        case .nameDescending:
            return favorites.sorted { favorite1, favorite2 in
                let name1 = cards.first(where: { $0.id == favorite1.cardId })?.name ?? ""
                let name2 = cards.first(where: { $0.id == favorite2.cardId })?.name ?? ""
                return name1 > name2
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                ForEach(sortFavorites(Array(favorites), cards: viewModel.cards), id: \.self) { favorite in
                    
                    if let card = viewModel.cards.first(where: { $0.id == favorite.cardId }) {
                        NavigationLink(destination: CardDiaryView(card: card, setName: setName(from: viewModel.sets, for: card.set_name), setId: card.set_name, viewModel: viewModel)) {
                            CardView(card: card, sets: viewModel.sets)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding()
            .padding(.top, 75)
            .padding(.bottom, 75)
        }
        
        .navigationBarItems(
            leading:
                Text("\(favorites.count)")
                    .font(.headline)
                    .foregroundColor(.gray),
            trailing: Image(systemName: "heart.fill").foregroundStyle(.red)
        )
        .navigationTitle("Favorite Cards")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .overlay(
            HStack(spacing: 10) {
                if !isScrolling {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedSortOption = option
                            }) {
                                Text(option.rawValue)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    Spacer()
                }
                Text("\(selectedSortOption.rawValue)").foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .frame(height: 75)
            .frame(maxWidth: !isScrolling ? .infinity : 220)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding(10)
            .animation(.easeInOut, value: !isScrolling),
            alignment: .top
        )
    }
}

struct FavoriteCardListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCardListView(isScrolling: Binding.constant(false), viewModel: CardViewModel())
    }
}

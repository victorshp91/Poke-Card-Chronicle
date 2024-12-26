//
//  FavoriteCardListView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/14/24.
//


import SwiftUI
import CoreData

struct FavoriteCardListView: View {
    
    @State private var showImageFullScreen = false // Estado para mostrar la imagen a tamaño completo
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
    }

    @State private var selectedSortOption: SortOption = .dateDescending
    @State private var isTopBarPresented: Bool = true
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.date, ascending: false)])
    private var favorites: FetchedResults<Favorites>
    
    @StateObject var viewModel: CardViewModel
    @StateObject var subscriptionViewModel: SubscriptionViewModel
    
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
        ZStack{
            ScrollView(showsIndicators: false) {
                
                
                VStack{
                    
                    if favorites.isEmpty {
                        
                        NoDataView(message: "No favorite cards yet")
                        
                    } else {
                        
                        LazyVGrid(columns: getGridColumns()) {
                            
                            ForEach(sortFavorites(Array(favorites), cards: viewModel.cards), id: \.self) { favorite in
                                
                                if let card = viewModel.cards.first(where: { $0.id == favorite.cardId }) {
                                    NavigationLink(destination: CardDiaryView(card: card, setName: setName(from: viewModel.sets, for: card.set_name), setId: card.set_name, viewModel: viewModel, subscriptionViewModel: subscriptionViewModel)) {
                                        VStack{
                                            CardView(card: card, showImageFullScreen: $showImageFullScreen, cardViewModel: viewModel)
                                              //  .padding(.vertical, 5)
                                            if let dateAdded = favorite.date {
                                                Text("\(dateAdded, style: .date)").foregroundStyle(.secondary).font(.caption).tint(.primary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        
                    }
                    
                    
                    
                }.padding(.vertical, 100)
                
                .navigationBarItems(
                    leading:
                        Text("\(favorites.count)")
                        .font(.headline)
                        .foregroundColor(.gray),
                    trailing:
                        HStack {
                            Image(systemName: "heart.fill").foregroundStyle(.red)
                            
                            
                           
                            if !viewModel.favorites.isEmpty {
                                let cardIds = viewModel.favorites.map { $0.cardId! }
                                ShareCollectionButton(cardIds: cardIds, title: "My Favorite Cards", description: "Here are all my favorite cards")
                            }
                        }
                )
                .navigationTitle("FAVORITE CARDS")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
                
                
                
            }.overlay(
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isTopBarPresented.toggle()
                        }
                    }) {
                        Image(systemName: isTopBarPresented ? "chevron.right" : "chevron.left")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    if isTopBarPresented {
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
                                .padding(8)
                                .foregroundStyle(.white)
                                .background(.red)
                                .cornerRadius(15)
                        }
                        Spacer()
                    }
                    Text("\(selectedSortOption.rawValue)").foregroundStyle(.secondary)
                }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .frame(height: 75)
                    .frame(maxWidth: isTopBarPresented ? .infinity : 220)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(10)
                    .animation(.easeInOut, value: isTopBarPresented),
                alignment: .top
            )
            
            
            if showImageFullScreen {
                ImageFullScreenView(showFullImage: $showImageFullScreen, cardViewModel: viewModel)
            }
        }
    }
}

struct FavoriteCardListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCardListView(viewModel: CardViewModel(), subscriptionViewModel: SubscriptionViewModel())
    }
}

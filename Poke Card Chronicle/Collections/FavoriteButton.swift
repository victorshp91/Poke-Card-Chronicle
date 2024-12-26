//
//  FavoriteButton.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/20/24.
//


import SwiftUI

struct FavoriteButton: View {
    let cardId: String
    @ObservedObject var viewModel: CardViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                viewModel.saveFavorite(cardId: cardId)
            }
        }) {
            
            Image(systemName: viewModel.isFavorite(cardId: cardId) ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
             
                .foregroundStyle(viewModel.isFavorite(cardId: cardId) ? .red:.secondary)
                .symbolEffect(.bounce, options: .speed(3).repeat(3), value: viewModel.isFavorite(cardId: cardId))
            
        }
    }
}

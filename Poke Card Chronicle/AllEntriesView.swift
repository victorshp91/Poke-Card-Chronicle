//
//  AllEntriesView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/13/24.
//


import SwiftUI
import SDWebImageSwiftUI



struct AllEntriesView: View {

    @FetchRequest(entity: DiaryEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.entryDate, ascending: false)]) var allEntries: FetchedResults<DiaryEntry>
    @StateObject var viewModel: CardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(allEntries, id: \.id) { entry in
                    if let matchingCard = viewModel.cards.first(where: { $0.id == entry.cardId }) {
                        EntryCard(
                            entry: entry,
                            card: matchingCard
                        )
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 75)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("All Entries")
        .navigationBarTitleDisplayMode(.inline)
    }
}





//#Preview {
//    AllEntriesView(allEntries: FetchedResults<DiaryEntry>(), viewModel: CardViewModel())
//}

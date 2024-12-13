//
//  CardDiaryView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/12/24.
//

import SwiftUI
import SDWebImageSwiftUI
struct CardDiaryView: View {
    
    let card: Card
    let setId: String
    let setName: String
    @State private var isShowingAddEntrySheet = false // Controla la presentación del sheet
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20){
                ForEach(0...10, id: \.self) { _ in
                    EntryCard(
                        entryTitle: "Pikachu's Journey",
                        entryDate: Date(),
                        entryText: "Caught Pikachu in Viridian Forest. It was an exciting day with a lot of adventure.",
                        card: card
                    )
                }
            }.padding(.top, 225)
                .padding(.bottom, 75)
            .frame(maxWidth: .infinity)
        }            .overlay(
            HeaderView(card: card, setId: setId, setName: setName),
            alignment: .top

        )

        
        .navigationTitle("Card Diary") // Título del NavigationBar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingAddEntrySheet = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $isShowingAddEntrySheet) {
            CardEntryView(card: card, setName: setName)
        }
    }
}

#Preview {
    CardDiaryView(card: Card(id: "1", name: "PIKACHU", small_image_url: "", large_image_url: "https://images.pokemontcg.io/sm1/5_hires.png", set_name: "Base Set"), setId: "pop3", setName: "150 mabajeo")
}



struct EntryCard: View {
    let entryTitle: String
    let entryDate: Date
    let entryText: String
    let card: Card
    @State private var showFullEntry: Bool = false // State to toggle full entry view
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Encabezado
            HStack {
                // Imagen de la carta
                WebImage(url: URL(string: card.small_image_url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entryTitle)
                        .font(.headline)
                        .bold()
                    
                    Text(entryDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                // Icono de configuración o acción
                Button(action: {
                    print("More options tapped")
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            // Contenido de la entrada
            Text(entryText)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(4)
                .padding(.leading, 10)
            
            // Pie de la entrada con el botón "Read More"
            HStack(spacing: 10) {
           
                Button(action: {
                    print("Favorite tapped")
                }) {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                        .font(.title2)
                }
                Button(action: {
                    print("Share tapped")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                Spacer()
                Button(action: {
                    showFullEntry.toggle() // Toggle to show full entry
                }) {
                    Text("Read More")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.trailing, 10)
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
        .sheet(isPresented: $showFullEntry) {
            //FullEntryView(entryTitle: entryTitle, entryDate: entryDate, entryText: entryText, card: card)
        }
    }
}


struct HeaderView: View {
    
    
    let card: Card
    let setId: String
    let setName: String
    @State private var animateCardImage: Bool = false // Animation state for card image
    var body: some View {
        HStack(alignment:. top, spacing: 10){
            WebImage(url: URL(string: card.large_image_url))
            { image in
                image
            }placeholder: {
                WebImage(url: URL(string: card.small_image_url))
                    .resizable()
                    .scaledToFit()
            }
            .resizable()
            .scaledToFit()
            .frame(height: 150) // Larger image
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
            
            .opacity(animateCardImage ? 1 : 0)
            .scaleEffect(animateCardImage ? 1 : 0.7)
            .animation(Animation.easeInOut(duration: 0.3), value: animateCardImage)
            .onAppear {
                animateCardImage = true
            }
            VStack(alignment: .leading){
                Text("\(card.name)'s Journey")
                    .font(.title2).bold()
                    .multilineTextAlignment(.leading)
                Text(setName)
                Spacer()
                HStack(alignment: .bottom, spacing: 10){
                    WebImage(url: getSetLogoURL(for: setId)) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 125)
                            
                            
                                .transition(.scale)
                        } else {
                            ProgressView()
                                .frame(width: 150, height: 200)
                        }
                    }
                    Spacer()
                    Image(systemName: "book")
                    Text("5")
                }.bold()
                
            }
            
            Spacer()
        }.padding()
            .frame(height: 175)
            .background(.ultraThinMaterial)
            .cornerRadius(35)
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 10,
                x: 0,
                y: 5
            )
            .padding()
    }
}

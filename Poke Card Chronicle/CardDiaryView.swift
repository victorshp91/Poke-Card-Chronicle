import SwiftUI
import SDWebImageSwiftUI

struct CardDiaryView: View {
    
    let card: Card
    let setId: String
    let setName: String
    @State private var isShowingAddEntrySheet = false // Controla la presentación del sheet
    
    @FetchRequest var entries: FetchedResults<DiaryEntry>

        init(card: Card, setName: String, setId: String) {
            self.card = card
            self.setName = setName
            self.setId = setId

            // Configuramos el @FetchRequest aquí
            _entries = FetchRequest(
                entity: DiaryEntry.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.entryDate, ascending: true)],
                predicate: NSPredicate(format: "cardId == %@", card.id)
            )
        }
  
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(entries, id: \.id) { entry in
                    EntryCard(
                        entry: entry,
                        card: card
                    )
                }
            }
            .padding(.top, 225)
            .padding(.bottom, 75)
            .frame(maxWidth: .infinity)
        }
        .overlay(
            HeaderView(card: card, setId: setId, setName: setName, totalEntry: entries.count),
            alignment: .top
        )
        .navigationTitle("Card Diary")
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
            NavigationStack {
                CardEntryView(card: card, setName: setName)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct EntryCard: View {
    let entry: DiaryEntry
    let card: Card
    
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
                    Text(entry.entryTitle ?? "No Title")
                        .font(.headline)
                        .bold()
                    
                    Text(entry.entryDate ?? Date(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    print("More options tapped")
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            // Contenido de la entrada
            Text(entry.entryText ?? "No Text")
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(4)
                .padding(.leading, 10)
            
            // Pie de la entrada con el botón "Read More"
            HStack(spacing: 10) {
                Button(action: {
                    print("Share tapped")
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                Spacer()
                Button(action: {
                    // Implement read more
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
    }
}

struct HeaderView: View {
    let card: Card
    let setId: String
    let setName: String
    let totalEntry: Int
    @State private var animateCardImage: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            WebImage(url: URL(string: card.small_image_url))
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
            VStack(alignment: .leading) {
                Text(card.name)
                    .font(.title2).bold()
                    .multilineTextAlignment(.leading)
                Text(setName)
                Spacer()
                HStack(alignment: .bottom, spacing: 10) {
                    WebImage(url: getSetLogoURL(for: setId))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125)
                        .transition(.scale)
                    Spacer()
                    Image(systemName: "book")
                    Text("\(totalEntry)")
                }.bold()
            }
            Spacer()
        }
        .padding()
        .frame(height: 175)
        .background(.ultraThinMaterial)
        .cornerRadius(35)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
    }
}


#Preview {
    CardDiaryView(card: Card(id: "1", name: "PIKACHU", small_image_url: "", large_image_url: "https://images.pokemontcg.io/sm1/5_hires.png", set_name: "Base Set"), setName: "150 mabajeo", setId: "pop3")
}

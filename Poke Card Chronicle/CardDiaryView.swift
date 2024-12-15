import SwiftUI
import SDWebImageSwiftUI

struct CardDiaryView: View {
   
    let card: Card
        let setId: String
        let setName: String
        @State private var isShowingAddEntrySheet = false // Controla la presentación del sheet
        @ObservedObject var CardViewModel: CardViewModel
        @FetchRequest var entries: FetchedResults<DiaryEntry>

        init(card: Card, setName: String, setId: String, viewModel: CardViewModel) {
            self.card = card
            self.setName = setName
            self.setId = setId
            self.CardViewModel = viewModel

            // Configuramos el @FetchRequest aquí
            _entries = FetchRequest(
                entity: DiaryEntry.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.entryDate, ascending: false)],
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
                HStack{
                    Button(action: {
                        withAnimation(.easeInOut) {
                            CardViewModel.saveFavorite(cardId: card.id)
                        }
                    }) {
                        Image(systemName: CardViewModel.isFavorite(cardId: card.id) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(.red)
                            .symbolEffect(.bounce, options: .speed(3).repeat(3), value: CardViewModel.isFavorite(cardId: card.id))
                    }
                    Button(action: {
                        isShowingAddEntrySheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    
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
    
    @State private var animateImages: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showImageViewer: Bool = false
    @State var selectedImage: Image?// Imagen seleccionada
    @StateObject var renderImageVm: RenderImage = RenderImage()
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                WebImage(url: URL(string: card.small_image_url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .offset(x: -12)
                    .onTapGesture {
                        if let uiImage = renderImageVm.downloadedImage {
                            selectedImage = uiImage
                            showImageViewer = true
                            
                        }
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.entryTitle ?? "No Title")
                        .font(.headline)
                        .bold()
                    Text("\(card.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.entryDate ?? Date(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .offset(x: -12)
                Spacer()
                Menu {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    ShareLink("Share", item: renderImageVm.renderedImage, preview: SharePreview(Text("\(card.name)"), image: renderImageVm.renderedImage))
                        .font(.headline)
                        .bold()
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            Text(entry.entryText ?? "No Text")
                .font(.body)
                .foregroundColor(.primary)
            
            let imagesArray = Array(entry.entryToImages as? Swift.Set<ImageEntry> ?? [])
            // Imágenes relacionadas con la entrada
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imagesArray, id: \.self) { (imageEntry: ImageEntry) in
                        if let uiImage = UIImage(data: imageEntry.image!) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 85, height: 85)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .opacity(animateImages ? 1 : 0)
                                .scaleEffect(animateImages ? 1 : 0.7)
                                .animation(Animation.easeInOut(duration: 0.3), value: animateImages)
                                .onTapGesture {
                                    selectedImage = Image(uiImage: uiImage)
                                    showImageViewer = true
                                }
                                .onAppear(perform: {
                                    animateImages = true
                                })
                        } else {
                            Color.gray
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
        
        // Alert de confirmación
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("This action cannot be undone."),
                primaryButton: .destructive(Text("Delete").foregroundStyle(.red)) {
                    withAnimation {
                        deleteEntry(entry)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear(perform: {
            renderImageVm.downloadImage(cardImageUrl: card.large_image_url, card: card, diaryEntry: entry, setImageUrl: getSetLogoURL(for: card.set_name)?.absoluteString ?? "")
            
        })
        
        // Mostrar imagen ampliada
        .sheet(isPresented: $showImageViewer) {
            if let image = selectedImage {
                ImageViewer(image: image)
            }
        }
    }
    
    
}



struct ImageViewer: View {
    var image: Image
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            // Cerrar la vista cuando se toca fuera de la imagen
            presentationMode.wrappedValue.dismiss()
        }
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
    CardDiaryView(card: Card(id: "1", name: "PIKACHU", small_image_url: "", large_image_url: "https://images.pokemontcg.io/sm1/5_hires.png", set_name: "Base Set"), setName: "150 mabajeo", setId: "pop3", viewModel: CardViewModel())
}

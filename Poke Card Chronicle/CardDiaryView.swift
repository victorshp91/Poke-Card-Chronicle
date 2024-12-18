import SwiftUI
import CoreData
import SDWebImageSwiftUI


// Vista principal para el diario de cartas
struct CardDiaryView: View {
   
    let card: Card
    let setId: String
    let setName: String
    @State private var isShowingAddEntrySheet = false // Controla la presentación del sheet para agregar una nueva entrada
    @State private var showPayWall = false // Controla la presentación del Paywall
    @ObservedObject var CardViewModel: CardViewModel // Modelo de la carta
    @ObservedObject var subscriptionViewModel: SubscriptionViewModel
    @FetchRequest var entries: FetchedResults<DiaryEntry> // Entrada de diario
    @State private var totalEntries = 0 // Nuevo estado para contar todas las entradas de todas las cartas

    // Inicialización de la vista con parámetros necesarios
    init(card: Card, setName: String, setId: String, viewModel: CardViewModel, subscriptionViewModel: SubscriptionViewModel) {
        self.card = card
        self.setName = setName
        self.setId = setId
        self.CardViewModel = viewModel
        self.subscriptionViewModel = subscriptionViewModel

        // Configuración del @FetchRequest para obtener entradas relacionadas con esta carta
        _entries = FetchRequest(
            entity: DiaryEntry.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \DiaryEntry.entryDate, ascending: false)],
            predicate: NSPredicate(format: "cardId == %@", card.id)
        )
        
        // Cálculo del total de entradas
        _totalEntries = State(initialValue: DiaryEntry.fetchTotalEntries())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Iterar sobre cada entrada y mostrarla en una vista personalizada
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
            HeaderView(card: card, setId: setId, setName: setName, totalEntry: totalEntries),
            alignment: .top
        )
        .navigationTitle("Card Diary")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // Botón para guardar como favorito
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
                    // Botón para agregar una nueva entrada
                    Button(action: {
                        if totalEntries <= 5 || subscriptionViewModel.hasLifetimePurchase{
                            isShowingAddEntrySheet = true
                        } else {
                            showPayWall = true
                        }
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
                    .presentationDetents([.large])
            }
        }
        .fullScreenCover(isPresented: $showPayWall) {
            PaywallView(subscriptionViewModel: subscriptionViewModel)
        }
        .presentationDetents([.large])
    }
}

struct EntryCard: View {
    let entry: DiaryEntry
    let card: Card

    @State private var animateImages: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showImagesSheet: Bool = false
    @State var selectedImage: Image? // Imagen seleccionada
    @StateObject var renderImageVm: RenderImage = RenderImage()

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                // Imagen de la carta
                WebImage(url: URL(string: card.small_image_url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .offset(x: -12)

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

                    // Muestra la cantidad de imágenes relacionadas con la entrada
                    if let imageCount = entry.entryToImages?.count, imageCount > 0 {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 30, height: 30)
                                Text("\(imageCount)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.red)
                            }
                            Text("Images")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .onTapGesture {
                            showImagesSheet = true
                        }
                    }
                }
                .offset(x: -12)
                Spacer()
                Menu {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    // Función para compartir la imagen renderizada
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
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)

        // Alerta para confirmar eliminación
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
            // Descarga de la imagen asociada a la carta y la entrada
            renderImageVm.downloadImage(cardImageUrl: card.large_image_url, card: card, diaryEntry: entry, setImageUrl: getSetLogoURL(for: card.set_name)?.absoluteString ?? "")
        })

        // Mostrar imágenes en un sheet
        .sheet(isPresented: $showImagesSheet) {
            ImageGridView(images: entry.imagesArray)
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
            // Imagen principal de la carta
            WebImage(url: URL(string: card.small_image_url))
                .resizable()
                .scaledToFit()
                .frame(height: 150) // Imagen más grande
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
                    // Logo del set de cartas
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

struct ImageGridView: View {
    @State var images: [ImageEntry]
    @State private var selectedImage: UIImage? // Para almacenar la imagen seleccionada
    @State private var showImageViewer: Bool = false // Controla si se muestra el viewer

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Imagen principal grande
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 450)
                    .cornerRadius(10)
                    .shadow(radius: 6)
            }
            
            // Lista de miniaturas abajo
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach($images, id: \.id) { $entryImage in
                        if let data = entryImage.image, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped() // Evita que las imágenes se salgan del marco
                                .cornerRadius(10)
                                .shadow(radius: 4)
                                .onTapGesture {
                                    selectedImage = uiImage // Establece la imagen seleccionada
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding()
            }
            Spacer()
        }
        .onAppear(perform: {
            if let data = images.first?.image, let uiImage = UIImage(data: data) {
                selectedImage = uiImage
            }
        })
    }
}




#Preview {
    CardDiaryView(card: Card(id: "1", name: "PIKACHU", small_image_url: "", large_image_url: "https://images.pokemontcg.io/sm1/5_hires.png", set_name: "Base Set"), setName: "150 mabajeo", setId: "pop3", viewModel: CardViewModel(), subscriptionViewModel: SubscriptionViewModel())
}



extension DiaryEntry {
    // Computa un array de ImageEntry a partir de los datos almacenados en entryToImages.
    var imagesArray: [ImageEntry] {
        // Convertimos entryToImages a un conjunto (Set) de ImageEntry,
        // asegurando que sea un conjunto válido si existe.
        let set = entryToImages as? Swift.Set<ImageEntry> ?? []
        
        // Convertimos el conjunto en un array.
        return Array(set) // Sin ordenar.
    }
}

extension DiaryEntry {
    // Función para obtener la cantidad total de entradas en la base de datos.
    static func fetchTotalEntries() -> Int {
        // Creamos una solicitud de fetch para la entidad DiaryEntry.
        let fetchRequest: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        
        // Intentamos contar las entradas utilizando el contexto de viewContext.
        let totalEntries = try? PersistenceController.shared.container.viewContext.count(for: fetchRequest)
        
        // Si la consulta falla, retornamos 0, de lo contrario, el número total de entradas.
        return totalEntries ?? 0
    }
}

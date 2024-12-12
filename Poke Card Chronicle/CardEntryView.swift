import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct CardEntryView: View {
    let card: Card // The selected card
    let setName: String
    @State private var entryText: String = "" // Entry text
    @State private var selectedDate: Date = Date() // Selected date
    @State private var selectedImage: UIImage? = nil // Selected image
    @State private var showSuccessAlert: Bool = false // Alert for success
    @State private var animateCardImage: Bool = false // Animation state for card image
    

    var body: some View {
        
        ScrollView {
            VStack {
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
                    .frame(height: 400) // Larger image
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                  
                    .opacity(animateCardImage ? 1 : 0)
                    .scaleEffect(animateCardImage ? 1 : 0.7)
                        .animation(Animation.easeInOut(duration: 0.3), value: animateCardImage)
                    .onAppear {
                        animateCardImage = true
                    }.padding(.top)
                
                Text(card.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                Text(setName)
                
                TextField("Add your thoughts here...", text: $entryText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(height: 60) // Larger text field
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .padding(.horizontal)
                    .padding(.bottom)
                
                Spacer()
            }.padding(.top)
        }
        .navigationBarItems(trailing: Button(action: saveEntry) {
            Text("Save")
                .font(.headline)
                .foregroundColor(.blue)
        })
        .navigationTitle("Card Entry")
        
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("Success"), message: Text("Your entry has been saved"), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: {
            print(card.large_image_url)
        })
    }

    private func saveEntry() {
        print("Saved entry for \(card.name): \(entryText) on \(selectedDate)")
        showSuccessAlert = true
    }
}

struct CardEntryView_Previews: PreviewProvider {
    static var previews: some View {
        CardEntryView(card: Card(id: "1", name: "Pikachu", small_image_url: "", large_image_url: "https://images.pokemontcg.io/sm1/5_hires.png", set_name: "Base Set"), setName: "150")
    }
}

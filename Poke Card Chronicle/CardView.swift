//
//  CardView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/14/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    let card: Card
    let sets: [Set]
    @State private var entryCount: Int = 0
    @Binding  var showImageFullScreen: Bool // Estado para mostrar la imagen a tamaño completo
    @Binding var imageUrl: String
    @State var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack{
            VStack{
                ZStack(alignment: .bottom) {
                    
                    WebImage(url: URL(string: card.large_image_url))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                    } placeholder: {
                        WebImage(url: URL(string: card.small_image_url))
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                    }.onLongPressGesture(perform: {
                        imageUrl = card.large_image_url
                        showImageFullScreen = true
                    })
                    
                    if entryCount > 0 {
                        HStack{
                            Image(systemName: "book")
                            Text("\(entryCount)")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .frame(minWidth: 75)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding()
                    }
                }
                
                Text(card.name)
                    .font(.caption).bold()
                    .tint(.primary)
                    .padding(.top, 4)
                    .frame(maxWidth: 150)
                    .multilineTextAlignment(.center)
                
                Text("\(setName(from: sets, for: card.set_name))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
                    .frame(maxWidth: 150)
                    .multilineTextAlignment(.center)
            }
            
           
        }
        .onAppear {
            animate = true
            entryCount = fetchEntryCount(for: card.id, in: PersistenceController.shared.container.viewContext)
        }
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.7)
        .animation(Animation.easeInOut(duration: 0.2), value: animate)
        
        
    }
}


    
   


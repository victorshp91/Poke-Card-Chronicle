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
    @State private var entryCount: Int = 0
    @Binding var showImageFullScreen: Bool // Estado para mostrar la imagen a tamaño completo
    @State var animate = false
    @StateObject var cardViewModel: CardViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
       
            VStack{
                
                ZStack(alignment: .bottom) {
                    ZStack(alignment: .topTrailing) {
                        WebImage(url: URL(string: card.small_image_url))
                        { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                        } placeholder: {
                            Image("cardBack")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                        }
                        Button(action: {
                            withAnimation {
                                cardViewModel.cardFullScreen = card
                                
                                showImageFullScreen = true
                            }
                        }) {
                            
                            HStack{
                                Image(systemName: "arrow.down.left.and.arrow.up.right.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .tint(.secondary)
                                
                            }
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                            .frame(maxWidth: 30)
                            
                        }
                        
                       
                        
                        
                    }
                   
                        HStack{
                            
                            Image(systemName: "book.fill")
                            
                           
                                Text("\(entryCount)")
                            
                        }.tint(.secondary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(minWidth: 75)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding()
                    
                    
                    
                }
                VStack(spacing: 2) {
                    Text(card.name)
                        .font(.caption).bold()
                        .tint(.primary)
                        .padding(.top, 4)
                        .frame(maxWidth: 150)
                        .multilineTextAlignment(.center)
                    
                    Text("\(setName(from: cardViewModel.sets, for: card.set_name))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                        .frame(maxWidth: 150)
                        .multilineTextAlignment(.center)
                    
                }
            }
            
           
        
        .onAppear {
            withAnimation {
                animate = true
            }
            entryCount = fetchEntryCount(for: card.id, in: PersistenceController.shared.container.viewContext)
                
        }
        .opacity(animate ? 1 : 0)
        .scaleEffect(animate ? 1 : 0.7)
        .animation(Animation.easeInOut(duration: 0.2), value: animate)
        
        
    }
}


    
   


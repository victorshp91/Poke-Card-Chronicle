//
//  ImageFullScreenView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/18/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct ImageFullScreenView: View {
   
    @Binding var showFullImage: Bool
    @State var animateImage = false
    @StateObject var cardViewModel: CardViewModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                
                WebImage(url: URL(string: cardViewModel.cardFullScreen.large_image_url)) { image in
                    image
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.35), radius: 15, x: 0, y: 10)
                    .padding()
                    .scaleEffect(animateImage ? 1 : 0.9, anchor: .center) // Escala desde el centro
                    .animation(
                        Animation.easeInOut(duration: 0.3),
                        value: animateImage
                    )
                }placeholder: {
                    WebImage(url: URL(string: cardViewModel.cardFullScreen.small_image_url))
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.35), radius: 15, x: 0, y: 10)
                        .padding()
                        .scaleEffect(animateImage ? 1 : 0.9, anchor: .center) // Escala desde el centro
                        .animation(
                            Animation.easeInOut(duration: 0.3),
                            value: animateImage
                        )
                }
                
                VStack{
                    
                  
                    
                    
                    
                    Button(action: {
                        
                        
                        showFullImage = false
                        
                        
                    }) {
                        
                        HStack{
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .tint(.secondary)
                            
                        }
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(maxWidth: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                       
                        
                    }
                    
                    FavoriteButton(cardId: cardViewModel.cardFullScreen.id, viewModel: cardViewModel)
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(maxWidth: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    
                    AddCardToCollectionButton( viewModel: cardViewModel, cardId: cardViewModel.cardFullScreen.id)
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(maxWidth: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    
                }.padding(.trailing, 5)
                
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .onAppear {
            withAnimation {
                animateImage = true
            }
        }
        .navigationBarHidden(true) // Ocultar la barra de navegación
    }
}

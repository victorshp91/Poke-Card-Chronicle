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
    
    @State private var timer: Timer?
    
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
                        Animation.easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true),
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
                            Animation.easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true),
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
                    HStack{
                        FavoriteButton(cardId: cardViewModel.cardFullScreen.id, viewModel: cardViewModel)
                    }
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(maxWidth: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    HStack{
                        
                        AddCardToCollectionButton(viewModel: cardViewModel, cardId: cardViewModel.cardFullScreen.id)
                    }
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(maxWidth: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    
                    Button(action: {
                        // Start a timer to reset the animation every second
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            withAnimation {
                                animateImage = !animateImage
                            }
                        }
                        
                        
                       
                    }) {
                        HStack{
                            Image(systemName: "wave.3.right")
                                .resizable()
                                .scaledToFit()
                                .tint(.secondary)
                        }
                        .padding(5)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .frame(minWidth: 45, maxHeight: 45)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    }
                    
                }.padding(.trailing, 10)
                
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
        .onDisappear {
            timer?.invalidate()
        }
        .navigationBarHidden(true) // Ocultar la barra de navegación
    }
}

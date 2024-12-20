//
//  ImageFullScreenView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/18/24.
//
import SwiftUI
import SDWebImageSwiftUI

struct ImageFullScreenView: View {
    @Binding var url: String
    @Binding var showFullImage: Bool
    @State var animateImage = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                
                WebImage(url: URL(string: url))
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
                
                Button(action: {
                    withAnimation {
                        animateImage = false
                        showFullImage = false
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
                    .frame(maxWidth: 45)
                    .padding(.trailing)
                    
                }
                
                
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

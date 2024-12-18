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
        @State private var entryCount: Int = 0 // Para almacenar la cantidad de entradas
        
        @State var animate = false
        @Environment(\.colorScheme) var colorScheme
        var body: some View {
            VStack{
                ZStack(alignment: .bottom) {
                    
                    WebImage(url: URL(string: card.large_image_url))
                    { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
                            .transition(.scale)
                    } placeholder: {
                        WebImage(url: URL(string: card.large_image_url))
                            .resizable()
                            .scaledToFit()
                    }
                    
                    // Mostrar el entryCount en la esquina superior derecha
                    if entryCount > 0 {
                        HStack{
                            Image(systemName: "book")
                                
                               
                            Text("\(entryCount)")
                        }.padding()
                            .bold()
                            .background(.ultraThinMaterial)
                            .foregroundStyle(colorScheme == .dark ? .white:.red)
                            
                            .frame(minWidth: 75)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .padding()
                            .animation(.easeInOut, value: entryCount)
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
                .onAppear(perform: {
                    animate = true
                    entryCount = fetchEntryCount(for: card.id, in: PersistenceController.shared.container.viewContext)
                })
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.7)
                .animation(Animation.easeInOut(duration: 0.2), value: animate)
                
               
            
        }}

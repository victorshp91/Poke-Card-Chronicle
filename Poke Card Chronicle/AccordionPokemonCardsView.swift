import SwiftUI
import SDWebImageSwiftUI

struct AccordionPokemonCardsView: View {
    var cardsId: [String]
    
    var body: some View {
        ZStack(alignment: .center) {
            if cardsId.isEmpty {
                Image("cardBack")
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            ForEach(cardsId.indices, id: \.self) { index in
                let cardId = cardsId[index]
                
                // Ajusta el desplazamiento solo para cartas después de la primera
                let offset = index == 0 ? 0 : CGFloat(index) * 20
                let rotation = index == 0 ? 0 : Double(index) * 5
                
                WebImage(url: getSmallImageURL(for: cardId)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .offset(x: offset) // Desplazamiento horizontal según el índice
                        .rotationEffect(.degrees(rotation)) // Rotación según el índice
                        .simultaneousGesture(TapGesture().onEnded {
                            // Acción de navegación aquí
                        })
                } placeholder: {
                    Image("cardBack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.15)
                        .offset(x: offset)
                        .rotationEffect(.degrees(rotation))
                }
            }
        }
        .frame(maxHeight: 100)
    }
}

struct AccordionPokemonCardsView_Previews: PreviewProvider {
    static var previews: some View {
        AccordionPokemonCardsView(cardsId: ["card1", "card2", "card3"])
            .frame(width: 300, height: 200)
            .background(Color.gray.opacity(0.2))
    }
}

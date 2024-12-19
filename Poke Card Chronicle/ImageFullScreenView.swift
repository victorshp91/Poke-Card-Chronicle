import SwiftUI
import SDWebImageSwiftUI

struct ImageFullScreenView: View {
    @Binding var url: String
    @Binding var showFullImage: Bool
    @State var animateImage = false

    var body: some View {
        VStack {
            WebImage(url: URL(string: url))
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
                .padding()
                .scaleEffect(animateImage ? 1 : 0.3)
                .animation(Animation.easeInOut(duration: 0.3), value: animateImage)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5)) // Fondo negro semi-transparente
        .onTapGesture {
            showFullImage = false
        }
        .onAppear(perform: {
            animateImage = true
        })
        .navigationBarHidden(true) // Ocultar la barra de navegación
    }
}

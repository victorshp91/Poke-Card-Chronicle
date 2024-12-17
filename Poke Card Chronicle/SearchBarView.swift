import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @Binding var actualSearch: String
    let textPlaceHolder: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField(textPlaceHolder, text: $text)
                .focused($isTextFieldFocused)
                .autocorrectionDisabled(true)
                .keyboardType(.alphabet)
               
               
                .onChange(of: isPresented) {
                                    isTextFieldFocused = isPresented
                                }
            Button(action: { withAnimation { isPresented = false; text = ""; isTextFieldFocused = false; actualSearch = "" } }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        .padding(10)
        .frame(height: 75)
        .background(.ultraThinMaterial) // Mejor calidad visual
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(10)
    }
}

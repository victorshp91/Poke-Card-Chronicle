//
//  ShareView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/25/24.
//


import SwiftUI

struct ShareCollectionButton: View {
    let cardIds: [String]
    let title: String
    let description: String
    var body: some View {
        Button(action: {
            sharePage()
        }){
           
            Label("Share", systemImage: "square.and.arrow.up")

          
        }
    }
    
    func sharePage() {
        let baseUrl = "https://pokediaryapp.com.rayjewelry.us/api/collection.php"
        let idsString = cardIds.joined(separator: ",")
        
        if let url = URL(string: "\(baseUrl)?ids=\(idsString)&title=\(title)&description=\(description)") {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            // Modern way to access window in iOS 15+
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
            
            // Alternative approach using SceneDelegate if you're using that pattern
            // if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            //    let window = scene.window {
            //    window.rootViewController?.present(activityVC, animated: true)
            // }
        }
    }
}

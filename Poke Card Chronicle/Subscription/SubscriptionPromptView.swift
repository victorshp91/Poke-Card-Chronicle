//
//  SubscriptionPromptView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/25/24.
//


import SwiftUI

struct SubscriptionPromptView: View {
 
    let description: String
   
    @StateObject var subscriptionViewModel: SubscriptionViewModel
    @State private var showSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Almost there!")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image("subscription")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.yellow)
            }
            
            Button(action: {
                showSheet = true
            }) {
                Text("Unlock Unlimited Access")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
        .sheet(isPresented: $showSheet) {
            PaywallView(subscriptionViewModel: subscriptionViewModel)
        }
    }
}


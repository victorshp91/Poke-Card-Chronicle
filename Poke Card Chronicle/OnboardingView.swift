//
//  OnboardingView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/18/24.
//


import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showPaywall = false
    @State private var animateIcon = false
    @State private var animateIcon2 = false
    @State private var animateIcon3 = false
    @StateObject  var subscriptionViewModel: SubscriptionViewModel
    @Binding var showOnBoardingScreen: Bool
    var body: some View {
        if showPaywall {
            PaywallView(subscriptionViewModel: subscriptionViewModel) // Mostrar la vista de Paywall al final
                
        } else {
            VStack {
                TabView(selection: $currentPage) {
                    // Página 1
                    VStack {
                        Image("1")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.yellow)
                            .scaleEffect(animateIcon ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
                        Text("Welcome to Pokémon Diary!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("Organize and track all your Pokémon card adventures effortlessly.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }.onAppear {
                        animateIcon = true
                    }
                    .tag(0)

                    // Página 2
                    VStack {
                        Image("2")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                            .scaleEffect(animateIcon2 ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon2)
                        Text("Save Your Memories")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("Write unlimited notes and attach them to your favorite Pokémon cards.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }.onAppear {
                        animateIcon2 = true
                    }
                    .tag(1)

                    // Página 3
                    VStack {
                        Image("3")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.green)
                            .scaleEffect(animateIcon3 ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon3)
                        Text("Powerful Features")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("Unlock premium features to enhance your experience.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }.onAppear {
                        animateIcon3 = true
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                // Botón "Siguiente"
                Button(action: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        showPaywall = true
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
    }
}





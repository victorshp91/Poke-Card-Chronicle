//
//  NoDataView.swift
//  Poke Card Chronicle
//
//  Created by Victor Saint Hilaire on 12/20/24.
//


import SwiftUI

struct NoDataView: View {
   
    let message: String
    
    var body: some View {
        VStack {
            Image("noData")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
       
    }
}

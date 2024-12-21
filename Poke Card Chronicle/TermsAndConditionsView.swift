//
//  TermsAndConditionsView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/13/24.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @State private var termsData: TermsData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
   
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(termsData?.title ?? "Terms & Conditions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let sections = termsData?.sections {
                    ForEach(sections, id: \.content) { section in
                        termsSection(title: section.title, content: section.content)
                    }
                }
            }
            .padding()
        }
        
        .navigationBarTitle("TERMS & CONDITIONS", displayMode: .inline)
        .onAppear {
            loadTermsData()
        }
    }
    
    private func termsSection(title: String? = nil, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    
            }
            
            Text(content)
                
        }
        .padding()
        
        .cornerRadius(10)
    }
    
    private func loadTermsData() {
        guard let url = URL(string: "https://rayjewelry.us/pokeDiary/terms.json") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                } else if let data = data {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(TermsData.self, from: data) {
                        self.termsData = decodedData
                    } else {
                        self.errorMessage = "Error decoding data"
                    }
                } else {
                    self.errorMessage = "Unknown error"
                }
            }
        }.resume()
    }
}

struct TermsData: Codable {
    let title: String
    let sections: [TermsSection]
}

struct TermsSection: Codable {
    let title: String?
    let content: String
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}

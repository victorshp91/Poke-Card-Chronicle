//
//  PrivacyPolicyView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/13/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State private var policyData: PolicyData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(policyData?.title ?? "Privacy Policy")
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
                } else if let sections = policyData?.sections {
                    ForEach(sections, id: \.title) { section in
                        policySection(title: section.title, content: section.content)
                    }
                }
            }
            .padding()
        }
       
        .navigationBarTitle("PRIVACY POLICY", displayMode: .inline)
        .onAppear {
            loadPolicyData()
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
             
            
            Text(content)
               
        }
        .padding()
       
        .cornerRadius(10)
    }
    
    private func loadPolicyData() {
        guard let url = URL(string: "https://pokediaryapp.com/api/privacy.json") else {
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
                    if let decodedData = try? decoder.decode(PolicyData.self, from: data) {
                        self.policyData = decodedData
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

struct PolicyData: Codable {
    let title: String
    let sections: [PolicySection]
}

struct PolicySection: Codable {
    let title: String
    let content: String
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}

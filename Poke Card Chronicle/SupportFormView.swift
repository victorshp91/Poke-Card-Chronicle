import SwiftUI

struct SupportFormView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isFormSubmitted: Bool = false // Track form submission

    var body: some View {
        NavigationView {
            VStack {
                if isFormSubmitted {
                    VStack(spacing: 20) {
                        Text("Thank you for contacting us!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Image("support")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("We have received your request and will get back to you within 24 hours.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    Form {
                        Section(header: Text("Contact Information")) {
                            VStack {
                                TextField("Name", text: $name)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .frame(height: 35)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)

                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .frame(height: 35)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .listRowBackground(Color.clear)
                        }

                        Section(header: Text("Message")) {
                            TextEditor(text: $message)
                                .frame(height: 200)
                                .padding(5)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .listRowBackground(Color.clear)
                        }

                        Button(action: submitSupportRequest) {
                            Text("Submit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("SUPPORT")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Support Request"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Function to submit the support request
    private func submitSupportRequest() {
        guard !name.isEmpty, !email.isEmpty, !message.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        guard let url = URL(string: "https://rayjewelry.us/pokeDiary/guardar_support.php") else { return }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "nombre", value: name),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "mensaje", value: message)
        ]

        guard let requestURL = urlComponents?.url else { return }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "No response from server."
                    showAlert = true
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = jsonResponse["success"] as? Bool,
                   let message = jsonResponse["message"] as? String {
                    DispatchQueue.main.async {
                        if success {
                            // Show the confirmation message
                            isFormSubmitted = true
                        } else {
                            alertMessage = message
                            showAlert = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Error parsing server response."
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct SupportFormView_Previews: PreviewProvider {
    static var previews: some View {
        SupportFormView()
    }
}

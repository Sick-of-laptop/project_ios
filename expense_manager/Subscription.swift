import SwiftUI

struct SubscriptionsView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading subscriptions...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(subscriptions) { subscription in
                            Section(header: Text(subscription.category).font(.headline)) {
                                ForEach(subscription.services) { service in
                                    ServiceRow(service: service)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Subscriptions")
            .onAppear {
                fetchSubscriptions()
            }
        }
    }

    private func fetchSubscriptions() {
        guard let url = URL(string: "https://mocki.io/v1/a28b477f-9878-4015-968c-7e8cc2ff0ed3") else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received."
                    isLoading = false
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SubscriptionResponse.self, from: data)
                DispatchQueue.main.async {
                    subscriptions = decodedResponse.subscriptions
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Decoding failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }.resume()
    }
}

struct ServiceRow: View {
    let service: Service

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: service.logo)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            }
            VStack(alignment: .leading) {
                Text(service.name).font(.headline)
                Text(service.cost).font(.subheadline).foregroundColor(.secondary)
                Link("Website", destination: URL(string: service.website)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
    }
}

#Preview {
    SubscriptionsView()
}


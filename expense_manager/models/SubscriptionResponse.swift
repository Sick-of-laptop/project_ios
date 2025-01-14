import Foundation

struct SubscriptionResponse: Codable {
    let subscriptions: [Subscription]
}

struct Subscription: Codable, Identifiable {
    var id: UUID = UUID() // Auto-generated unique ID
    let category: String
    let services: [Service]

    private enum CodingKeys: String, CodingKey {
        case category
        case services
    }
}

struct Service: Codable, Identifiable {
    var id: UUID = UUID() // Auto-generated unique ID
    let name: String
    let cost: String
    let features: [String]
    let website: String
    let logo: String

    private enum CodingKeys: String, CodingKey {
        case name, cost, features, website, logo
    }
}




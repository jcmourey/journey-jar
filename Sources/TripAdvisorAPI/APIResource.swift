import Foundation
import APIClient

protocol TripAdvisorAPIResource: APIResource {
    var apiKey: String { get }
    var methodQueryItems: [URLQueryItem] { get }
}

extension TripAdvisorAPIResource {
    var basePath: String { "https://api.content.tripadvisor.com/api/v1" }
    var apiKey: String { "A16B016EAA154300A1EEB25427340906" }
    var methodQueryItems: [URLQueryItem] { [] }
    var queryItems: [URLQueryItem] {
        methodQueryItems + [URLQueryItem(name: "apiKey", value: apiKey)]
    }
}

struct TripAdvisorLocationSearchResource: TripAdvisorAPIResource {
    typealias ModelType = TripAdvisorLocationSearchResult
    var method: String = "location/search"
    let searchQuery: String
    
    var methodQueryItems: [URLQueryItem] {
        [URLQueryItem(name: "searchQuery", value: searchQuery)]
    }
}

struct TripAdvisorLocationDetailResource: TripAdvisorAPIResource {
    typealias ModelType = TripAdvisorLocationDetailResult
    let locationId: Int
    var method: String { "location/\(locationId)/details" }
}

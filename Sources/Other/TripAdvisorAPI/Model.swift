import Foundation

/// TripAdvisor Location Search
/// https://api.content.tripadvisor.com/api/v1/location/search?searchQuery=Pigeot&key=<XXX>
struct TripAdvisorLocationSearchResult: Codable {
    let data: [TripAdvisorLocation]
}

struct TripAdvisorLocation: Codable {
    let locationId: String
    let name: String
    let addressObj: TripAdvisorAddress
}

struct TripAdvisorAddress: Codable {
    let street1: String
    let street2: String
    let city: String
    let country: String
    let postalcode: String
    let addressString: String
}

/// TripAdvisor Location details
/// https://api.content.tripadvisor.com/api/v1/location/1335238/details?key=[XXX]
struct TripAdvisorLocationDetailResult: Codable {
    let locationId: String
    let name: String
    let webUrl: URL
    let addressObj: TripAdvisorAddress
    let latitude: String
    let longitude: String
    let phone: String
    let website: URL
    let rankingData: TripAdvisorRankingData
    let rating: String
    let ratingImageUrl: URL
    let numReviews: String
    let reviewRatingCount: TripAdvisorReviewRatingCount
    let priceLevel: String
    let weekdayText: [String]
    let cuisine: [TripAdvisorCuisine]
    let awards: [TripAdvisorAward]
}

struct TripAdvisorRankingData: Codable {
    let geoLocationId: String
    let rankingString: String
    let geoLocationName: String
    let rankingOutOf: String
    let ranking: String
}

struct TripAdvisorReviewRatingCount: Codable {
    let one: String
    let two: String
    let three: String
    let four: String
    let five: String
    
    enum CodingKeys: String, CodingKey {
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
    }
}

struct TripAdvisorCuisine: Codable {
    let localizedName: String
}

struct TripAdvisorAwardImages: Codable {
    let tiny: URL
    let small: URL
    let large: URL
}

struct TripAdvisorAward: Codable {
    let awardType: String
    let year: String
    let images: TripAdvisorAwardImages
    let categories: [String]
    let displayName: String
}

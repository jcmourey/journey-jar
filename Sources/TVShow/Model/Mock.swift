import Foundation

// pointfree
import Tagged
import IdentifiedCollections

// types
import ModelElements

@MainActor
extension Recommendation {
    public struct Mock {
        public let mock0 = Recommendation(id: Recommendation.ID(), name: "Lucky & Vesna")
        public let mock1 = Recommendation(id: Recommendation.ID(), name: "French Radio")
        public let mock2 = Recommendation(id: Recommendation.ID(), name: "Jean-Charles")
        public let mock3 = Recommendation(id: Recommendation.ID(), name: "Netflix")
    }
    public static var mock: Mock { Mock() }
}

@MainActor
extension TVShow {
    @MainActor
    public struct Mock {
        public let noRecommendation = TVShow(id: ID(), title: "Dexter", dateAdded: .now, dateModified: .now, teamId: nil, recommendations: [], interest: .high, progress: .finished, tvdbInfo: .mock.dexter)
        public let mock1 = TVShow(id: ID(), title: "The Split", dateAdded: .now, dateModified: .now, teamId: nil, recommendations: [.mock.mock0], interest: .absoluteMust, progress: .notStarted, tvdbInfo: .mock.theSplit)
        public let mock2 = TVShow(id: ID(), title: "HPI", dateAdded: .now, dateModified: .now, teamId: nil, recommendations: [.mock.mock1], interest: .high, progress: .notStarted, tvdbInfo: .mock.hpi)
        public let multipleRecommendations = TVShow(id: ID(), title: "Star Trek: Picard", dateAdded: .now, dateModified: .now, teamId: nil, recommendations: [.mock.mock2, .mock.mock3], interest: .high, progress: .finished, tvdbInfo: .mock.starTrekPicard)
    }
    public static var mock: Mock { Mock() }
}

@MainActor
extension IdentifiedArrayOf<TVShow> {
    public static var mock: Self = [.mock.noRecommendation, .mock.mock1, .mock.mock2, .mock.multipleRecommendations]
}

@MainActor
extension TVDBInfo {
    @MainActor
    public struct Mock {
        public let dexter = TVDBInfo(tvdbID: 79349, imageURL: URL(string: "https://artworks.thetvdb.com/banners/posters/79349-27.jpg"))
        public let theSplit = TVDBInfo(tvdbID: 344145, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/344145/posters/641e4bedc7748.jpg"))
        public let hpi = TVDBInfo(tvdbID: 387368, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/387368/posters/643fb0f8dd77f_t.jpg"))
        public let starTrekPicard = TVDBInfo(tvdbID: 364093, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/364093/posters/61e846a7440f8.jpg"))
    }
    public static var mock: Mock { Mock() }
}

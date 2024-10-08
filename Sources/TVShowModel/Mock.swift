import Foundation
import IdentifiedCollections
import ModelElements
import Tagged
import TVShowModel

@MainActor
extension Recommendation {
    public struct Mock {
        let mock0 = Recommendation(id: Recommendation.ID(), name: "Lucky & Vesna")
        let mock1 = Recommendation(id: Recommendation.ID(), name: "French Radio")
        let mock2 = Recommendation(id: Recommendation.ID(), name: "Jean-Charles")
        let mock3 = Recommendation(id: Recommendation.ID(), name: "Netflix")
    }
    public static var mock: Mock { Mock() }
}


@MainActor
extension TVShow {
    @MainActor
    public struct Mock {
        let noRecommendation = TVShow(id: TVShow.ID(), title: "Dexter", dateAdded: .now, dateModified: .now, recommendations: [], interest: .high, progress: .finished, tvdbInfo: .mock.dexter)
        let mock1 = TVShow(id: TVShow.ID(), title: "The Split", dateAdded: .now, dateModified: .now, recommendations: [.mock.mock0], interest: .absoluteMust, progress: .notStarted, tvdbInfo: .mock.theSplit)
        let mock2 = TVShow(id: TVShow.ID(), title: "HPI", dateAdded: .now, dateModified: .now, recommendations: [.mock.mock1], interest: .high, progress: .notStarted, tvdbInfo: .mock.hpi)
        let multipleRecommendations = TVShow(id: TVShow.ID(), title: "Star Trek: Picard", dateAdded: .now, dateModified: .now, recommendations: [.mock.mock2, .mock.mock3], interest: .high, progress: .finished, tvdbInfo: .mock.starTrekPicard)
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
        let dexter = TVDBInfo(tvdbID: 79349, imageURL: URL(string: "https://artworks.thetvdb.com/banners/posters/79349-27.jpg"))
        let theSplit = TVDBInfo(tvdbID: 344145, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/344145/posters/641e4bedc7748.jpg"))
        let hpi = TVDBInfo(tvdbID: 387368, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/387368/posters/643fb0f8dd77f_t.jpg"))
        let starTrekPicard = TVDBInfo(tvdbID: 364093, imageURL: URL(string: "https://artworks.thetvdb.com/banners/v4/series/364093/posters/61e846a7440f8.jpg"))
    }
    public static var mock: Mock { Mock() }
}

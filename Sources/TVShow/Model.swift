import UIKit
import Tagged
import IdentifiedCollections
import ModelElements
import TheTVDBAPI
import DatabaseRepresentable

public struct TVShow: DatabaseRepresentable, Sendable {
    public let id: Tagged<Self, UUID>
    public var title: String = ""
    public let dateAdded: Date
    public var dateModified: Date
    
    // info
    public var recommendations: IdentifiedArrayOf<Recommendation> = []
    public var interest: Interest?
    public var progress: Progress?
    public var tvdbInfo: TVDBInfo?
    
    public enum Progress: String, CaseIterable, Codable, Sendable {
        case notStarted = "not started"
        case watching
        case finished
    }
}

public struct Recommendation: Equatable, Hashable, Identifiable, Codable, Sendable {
    public let id: Tagged<Recommendation, UUID>
    var name = ""
}

public struct TVDBInfo: Equatable, Hashable, Identifiable, Codable, Sendable  {
    let tvdbID: Tagged<TVDBInfo, Int>
    var name: String?
    public var country: String?
    public var year: Int?
    public var slug: String?
    public var network: String?
    public var overview: String?
    public var imageURL: URL?
    public var thumbnailURL: URL?
    public var language: String?

    // detailed info
    var score: Int?
    var averageRuntime: Int?
    public var lastAired: Date?
    public var nextAired: Date?
    public var status: String?
    
    public var id: Tagged<TVDBInfo, Int> { tvdbID }
    
    init(tvdbID: Tagged<TVDBInfo, Int>, name: String? = nil, country: String? = nil, year: Int? = nil, slug: String? = nil, network: String? = nil, overview: String? = nil, imageURL: URL? = nil, thumbnailURL: URL? = nil, language: String? = nil, score: Int? = nil, averageRuntime: Int? = nil, lastAired: Date? = nil, nextAired: Date? = nil, status: String? = nil) {
        self.tvdbID = tvdbID
        self.name = name
        self.country = country
        self.year = year
        self.slug = slug
        self.network = network
        self.overview = overview
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.language = language
        self.score = score
        self.averageRuntime = averageRuntime
        self.lastAired = lastAired
        self.nextAired = nextAired
        self.status = status
    }
    
    init?(from series: TheTVDBSeries) {
        guard let tvdbID = Int(series.tvdbId) else { return nil }
        let year = if let year = series.year { Int(year) } else { nil as Int? }
        self.init(
            tvdbID: TVDBInfo.ID(tvdbID),
            name: series.name,
            country: series.country,
            year: year,
            slug: series.slug,
            network: series.network,
            overview: series.overview,
            imageURL: series.imageUrl,
            thumbnailURL: series.thumbnail,
            language: series.primaryLanguage
       )
    }
    
    mutating func populate(detail: TheTVDBSeriesDetail) {
        score = detail.score
        averageRuntime = detail.averageRuntime
        lastAired = detail.lastAired
        nextAired = detail.nextAired
        status = detail.status?.name
    }
}

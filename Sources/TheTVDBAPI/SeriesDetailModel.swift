import Foundation

/// TheTVDB Series details
/// https://api4.thetvdb.com/v4/series/292174

public struct TheTVDBSeriesDetailResult: Codable {
    public let data: TheTVDBSeriesDetail
}

public struct TheTVDBSeriesDetail: Codable, Identifiable, Equatable {
    public let id: Int
    public let name: String?
    public let image: URL?
    public let firstAired: Date?
    public let lastAired: Date?
    public let nextAired: Date?
    public let score: Int?
    public let status: Status?
    public let originalCountry: String?
    public let originalLanguage: String?
    public let overview: String?
    public let year: String?
    public let averageRuntime: Int?
    
    // defensive try? so it gets as many of the properties as possible
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.image = try? container.decodeIfPresent(URL.self, forKey: .image)
        self.firstAired = try? container.decodeIfPresent(Date.self, forKey: .firstAired)
        self.lastAired = try? container.decodeIfPresent(Date.self, forKey: .lastAired)
        self.nextAired = try? container.decodeIfPresent(Date.self, forKey: .nextAired)
        self.score = try? container.decodeIfPresent(Int.self, forKey: .score)
        self.status = try? container.decodeIfPresent(TheTVDBSeriesDetail.Status.self, forKey: .status)
        self.originalCountry = try? container.decodeIfPresent(String.self, forKey: .originalCountry)
        self.originalLanguage = try? container.decodeIfPresent(String.self, forKey: .originalLanguage)
        self.overview = try? container.decodeIfPresent(String.self, forKey: .overview)
        self.year = try? container.decodeIfPresent(String.self, forKey: .year)
        self.averageRuntime = try? container.decodeIfPresent(Int.self, forKey: .averageRuntime)
    }
}

extension TheTVDBSeriesDetail {
    public struct Status: Codable, Equatable {
        public let id: Int
        public let name: String
        public let recordType: String
    }
}

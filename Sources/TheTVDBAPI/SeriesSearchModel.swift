import Foundation
import IdentifiedCollections

/// TheTVDB search
/// https://api4.thetvdb.com/v4/search?query=Dark Matter

public struct TheTVDBSeriesSearchResult: Codable {
    public let data: IdentifiedArrayOf<TheTVDBSeries>
}

public struct TheTVDBSeries: Codable {
    public let tvdbId: String
    public let country: String?
    public let name: String
    public let type: String?
    public let year: String?
    public let slug: String?
    public let network: String?
    public let overview: String?
    public let imageUrl: URL?
    public let thumbnail: URL?
    public let primaryLanguage: String?
    public let status: String?
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tvdbId = try container.decode(String.self, forKey: .tvdbId)
        self.country = try? container.decodeIfPresent(String.self, forKey: .country)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try? container.decode(String.self, forKey: .type)
        self.year = try? container.decodeIfPresent(String.self, forKey: .year)
        self.slug = try? container.decodeIfPresent(String.self, forKey: .slug)
        self.network = try? container.decodeIfPresent(String.self, forKey: .network)
        self.overview = try? container.decodeIfPresent(String.self, forKey: .overview)
        self.imageUrl = try? container.decodeIfPresent(URL.self, forKey: .imageUrl)
        self.thumbnail = try? container.decodeIfPresent(URL.self, forKey: .thumbnail)
        self.primaryLanguage = try? container.decodeIfPresent(String.self, forKey: .primaryLanguage)
        self.status = try? container.decodeIfPresent(String.self, forKey: .status)
    }
}

extension TheTVDBSeries: Identifiable {
    public var id: String { tvdbId }
}

extension TheTVDBSeries: Hashable {}

import Foundation

/// TheTVDB Series details
/// https://api4.thetvdb.com/v4/series/292174

public struct TheTVDBSeriesExtendedResult: Codable {
    public let data: TheTVDBSeriesExtended
}

public struct TheTVDBSeriesExtended: Identifiable, Equatable, Codable {
    public let id: Int
    public let name: String?
    public let image: URL?
    public let firstAired: Date?
    public let lastAired: Date?
    public let nextAired: Date
    public let score: Int?
    public let status: TheTVDBSeriesDetail.Status?
    public let originalCountry: String?
    public let originalLanguage: String?
    public let overview: String?
    public let year: String?
    public let averageRuntime: Int?
    public let artworks: [TheTVDBSeriesExtended.Artwork]?
    public let originalNework: TheTVDBSeriesExtended.Network?
    public let latestNetwork: Network?
    public let genres: [Genre]?
    public let lists: [List]?
    public let remoteIds: [RemoteID]?
    public let characters: [Character]?
    public let airsDays: AirDays?
    public let seasons: [Season]?
    public let tags: [Tag]?
}

extension TheTVDBSeriesExtended {
    public struct Artwork: Codable, Equatable, Hashable {
        public let image: URL?
        public let thumbnail: URL?
        public let score: Int?
        public let width: Int?
        public let height: Int?
    }
    
    public struct Network: Codable, Equatable {
        public let name: String?
        public let country: String?
    }
    
    public struct Genre: Codable, Equatable {
        public let name: String?
    }
    
    public struct List: Codable, Equatable, Hashable {
        public let name: String?
        public let overview: String?
    }
    
    public struct RemoteID: Codable, Equatable {
        public let id: String?
        public let sourceName: String?
    }
    
    public struct Character: Codable, Equatable, Hashable {
        public let name: String?
        public let image: URL?
        public let url: URL?
        public let personName: String?
        public let personImgURL: URL?
    }
    
    public struct AirDays: Codable, Equatable {
        public let sunday: Bool?
        public let monday: Bool?
        public let tuesday: Bool?
        public let wednesday: Bool?
        public let thursday: Bool?
        public let friday: Bool?
        public let saturday: Bool?
    }
    
    public struct Season: Codable, Equatable, Hashable {
        public let number: Int?
        public let image: URL?
    }
    
    public struct Tag: Codable, Equatable, Hashable {
        public let tagName: String?
        public let name: String?
    }

}

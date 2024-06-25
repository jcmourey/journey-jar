//
//  TheTVDBSeriesSearchModel.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 04/05/2024.
//

import Foundation
import IdentifiedCollections

/// TheTVDB search
/// https://api4.thetvdb.com/v4/search?query=Dark Matter

struct TheTVDBSeriesSearchResult: Codable {
    let data: IdentifiedArrayOf<TheTVDBSeries>
}

struct TheTVDBSeries: Codable {
    let tvdbId: String
    let country: String?
    let name: String
    let type: String?
    let year: String?
    let slug: String?
    let network: String?
    let overview: String?
    let imageUrl: URL?
    let thumbnail: URL?
    let primaryLanguage: String?
    let status: String?
    
    init(from decoder: any Decoder) throws {
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
    var id: String { tvdbId }
}

extension TheTVDBSeries: Hashable {}

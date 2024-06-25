//
//  TheTVDBSeriesDetailModel.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 04/05/2024.
//

import Foundation

/// TheTVDB Series details
/// https://api4.thetvdb.com/v4/series/292174

struct TheTVDBSeriesDetailResult: Codable {
    let data: TheTVDBSeriesDetail
}

struct TheTVDBSeriesDetail: Codable {
    let id: Int
    let name: String?
    let image: URL?
    let firstAired: Date?
    let lastAired: Date?
    let nextAired: Date?
    let score: Int?
    let status: Status?
    let originalCountry: String?
    let originalLanguage: String?
    let overview: String?
    let year: String?
    let averageRuntime: Int?
    
    // defensive try? so it gets as many of the properties as possible
    init(from decoder: any Decoder) throws {
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
    struct Status: Codable, Equatable {
        let id: Int
        let name: String
        let recordType: String
    }
}

extension TheTVDBSeriesDetail: Identifiable, Equatable {}

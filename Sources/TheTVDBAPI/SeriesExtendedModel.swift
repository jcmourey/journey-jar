//
//  TheTVDBSeriesExtendedModel.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 04/05/2024.
//

import Foundation

/// TheTVDB Series details
/// https://api4.thetvdb.com/v4/series/292174

struct TheTVDBSeriesExtendedResult: Codable {
    let data: TheTVDBSeriesExtended
}

struct TheTVDBSeriesExtended: Identifiable, Equatable, Codable {
    let id: Int
    let name: String?
    let image: URL?
    let firstAired: Date?
    let lastAired: Date?
    let nextAired: Date
    let score: Int?
    let status: TheTVDBSeriesDetail.Status?
    let originalCountry: String?
    let originalLanguage: String?
    let overview: String?
    let year: String?
    let averageRuntime: Int?
    let artworks: [TheTVDBSeriesExtended.Artwork]?
    let originalNework: TheTVDBSeriesExtended.Network?
    let latestNetwork: Network?
    let genres: [Genre]?
    let lists: [List]?
    let remoteIds: [RemoteID]?
    let characters: [Character]?
    let airsDays: AirDays?
    let seasons: [Season]?
    let tags: [Tag]?
}

extension TheTVDBSeriesExtended {
    struct Artwork: Codable, Equatable, Hashable {
        let image: URL?
        let thumbnail: URL?
        let score: Int?
        let width: Int?
        let height: Int?
    }
    
    struct Network: Codable, Equatable {
        let name: String?
        let country: String?
    }
    
    struct Genre: Codable, Equatable {
        let name: String?
    }
    
    struct List: Codable, Equatable, Hashable {
        let name: String?
        let overview: String?
    }
    
    struct RemoteID: Codable, Equatable {
        let id: String?
        let sourceName: String?
    }
    
    struct Character: Codable, Equatable, Hashable {
        let name: String?
        let image: URL?
        let url: URL?
        let personName: String?
        let personImgURL: URL?
    }
    
    struct AirDays: Codable, Equatable {
        let sunday: Bool?
        let monday: Bool?
        let tuesday: Bool?
        let wednesday: Bool?
        let thursday: Bool?
        let friday: Bool?
        let saturday: Bool?
    }
    
    struct Season: Codable, Equatable, Hashable {
        let number: Int?
        let image: URL?
    }
    
    struct Tag: Codable, Equatable, Hashable {
        let tagName: String?
        let name: String?
    }

}

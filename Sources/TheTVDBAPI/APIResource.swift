//
//  TheTVDBAPIResource.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 04/05/2024.
//

import Foundation
import ComposableArchitecture

protocol TheTVDBAPIResource: APIResource {
    var token: String { get }
}

extension TheTVDBAPIResource {
    //    var basePath: String { "https://api.thetvdb.com/" }
    var basePath: String { "https://api4.thetvdb.com/v4/" }
    
    var apiKey: String { "7d28eed8-32c0-42ea-8295-31395ddc41a5" }
    
    // token must be renewed every month
    var token: String {
"""
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZ2UiOiIiLCJhcGlrZXkiOiI1ODBjOTIzOS1kMmY4LTQ0NjAtYTIyZS02ODMxOTAwYTk3YTMiLCJjb21tdW5pdHlfc3VwcG9ydGVkIjp0cnVlLCJleHAiOjE3MjEyODA5MDUsImdlbmRlciI6IiIsImhpdHNfcGVyX2RheSI6MTAwMDAwMDAwLCJoaXRzX3Blcl9tb250aCI6MTAwMDAwMDAwLCJpZCI6IjEiLCJpc19tb2QiOnRydWUsImlzX3N5c3RlbV9rZXkiOmZhbHNlLCJpc190cnVzdGVkIjpmYWxzZSwicGluIjoiSVBRWk9DTU4iLCJyb2xlcyI6WyJNb2QiXSwidGVuYW50IjoidHZkYiIsInV1aWQiOiIifQ.dC8BkGGiG9QCjCIaPd31CiIMne_tWLwN-Yt9vb5U8LTX2N3SYZMML-GqNvLsNhP54mLK74xX0UP4W8tHKmsv0Dat6HnpI3_gfQ3v0yerxqf5qLk33XGj7d2dtSUiGhueBfWxU2KxmNNufxawaPUyGglfa6rAs24RFxN5LwBILlb5ijGsMkfrJ5cA2Mc3blEM0ZAXmfFKCKX6FaRZ4bZi0-3DXnOeOZz-5HStT7aETjE1sn12fLr4Ivtbosiyy8UjGE9h07KVoVKZtIqlG7NiTnAaQBz45dTzp2MpzLphhtN-HqJOyKMvOUkc0GpMZhZa0npmw1504zhtqLTZumefZSZtNHEfhQKs5LMkLjQR5cRHZrfBwHdcLxruE3f5w9gfn-LQPlnn2w7AG32c3hVLqVIRB5ZxtGHb0vPuV90QcCRijXojsw8slze8Ee9Dwk4_bTQrm0I1y_p0OwWRH-FP5gvWOAxeZ7caTXvgCTtwCyAsJcEg2LxE5Kf0th7m_y3XhHW0plq3fjZ3Q5NZ5YJnRIwCv0v3lbJTs4zhJoOxw_iXgeGI4218jv4QGSkGIxInGGpyxKwkB8q3Du4-peAzVAV6cRzEeVqZ95OTegj8qPtYWsKPihWo_66dsZiuBpbqNmj9aelpmLRYfxI3F8i3s4oEIw3fn8Scf4fbIGHq5M8
"""
    }
    
    var headers: [String: String] {
        ["Authorization": "Bearer \(token)"]
    }
    
    var apiDecoder: JSONDecoder {
        .apiDecoder <~ {
            $0.dateDecodingStrategy = .usDate
        }
    }
}

// decode date format used by TheTVDB
extension JSONDecoder.DateDecodingStrategy {
    static var usDate: Self {
        .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
                        
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}

struct TheTVDBSeriesSearchResource: TheTVDBAPIResource {
    typealias ModelType = TheTVDBSeriesSearchResult
    
    static let baseUserURL = URL(string: "https://www.thetvdb.com/series")!

    let searchQuery: String
    
    var method: String { "search" }
    
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "query", value: searchQuery),
            URLQueryItem(name: "type", value: "series")
        ]
    }
}

struct TheTVDBSeriesDetailResource: TheTVDBAPIResource {
    typealias ModelType = TheTVDBSeriesDetailResult
    let tvdbID: Int
    var method: String { "series/\(tvdbID)" }
}

struct TheTVDBSeriesExtendedResource: TheTVDBAPIResource {
    typealias ModelType = TheTVDBSeriesExtendedResult
    let tvdbID: Int
    var method: String { "series/\(tvdbID)/extended" }
}


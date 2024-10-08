import Foundation

// api
import APIClient

public protocol TheTVDBAPIResource: APIResource {
    var token: String { get }
}

extension TheTVDBAPIResource {
    //    var basePath: String { "https://api.thetvdb.com/" }
    public var basePath: String { "https://api4.thetvdb.com/v4/" }
    
    var apiKey: String { "7d28eed8-32c0-42ea-8295-31395ddc41a5" }
    
    // token must be renewed every month
    public var token: String {
"""
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZ2UiOiIiLCJhcGlrZXkiOiI3ZDI4ZWVkOC0zMmMwLTQyZWEtODI5NS0zMTM5NWRkYzQxYTUiLCJjb21tdW5pdHlfc3VwcG9ydGVkIjpmYWxzZSwiZXhwIjoxNzMwMDUyMDc0LCJnZW5kZXIiOiIiLCJoaXRzX3Blcl9kYXkiOjEwMDAwMDAwMCwiaGl0c19wZXJfbW9udGgiOjEwMDAwMDAwMCwiaWQiOiIyNDExODM3IiwiaXNfbW9kIjpmYWxzZSwiaXNfc3lzdGVtX2tleSI6ZmFsc2UsImlzX3RydXN0ZWQiOmZhbHNlLCJwaW4iOiJJUFFaT0NNTiIsInJvbGVzIjpbXSwidGVuYW50IjoidHZkYiIsInV1aWQiOiIifQ.gIIORIHXBZWvTBHpDYm6wcekwlKG4DC-ViRZd6KWo1J_XgKubEVCJzAxOxQe0UF3y5NKNnviz1UhBeCzs4oa1DzqcFz9bSwkQrfqmzHPQ9eaUDqKAZOIxCdrvHE02FbYPbjLtuVkR5qiJ0sugRfMyUXPikRBPzfuRStGe1_yLkHxlb--LZRiBSjmb3mMBoUEFaG5LB0b-q69RFiXw2cvX4EnCQKsMxUG0lL6g6hQwUIP0drSUyKWHnVEEqXnYaj2klMPifsJufvrYluRs6x1pn1hwMjd1vAM8Pv_u7eHz9hh6qSXLTRzmlaHWxaCa4Ar7tTlTTc2jjRDCaRkvFDgQXcXfofK7eT1XgZ1ZevNjYljUYxSv9BEcKkwr4ezINB8xXj8W858hcljIZA9tzyOgbm38PV297qVsvD8dtoIpDUt07Hoj3fiVIs98zAyFyaXhTDMlm_X2SwvqyL7dEtbgxBUCQBl5KewFefLTQKsTKtFQdjMhgQjjdUKCy4HwGc3arxXEawvgIlG83-r3b3yaUGJJgZ_oqIwH9eg9rXughgV1SP_cPpWy0oOUyLTbaDqPUnO4LMqZXpPqtdD4FaRoVHJy61YIr9fvTcGtDh9jO2sKkIN_NmNwkJ0uJCCTYpYGbtN_F1Z9ujJmc0-9p7j9fKJ69b1sddhidRW3s69gCs
"""
    }
    
    public var headers: [String: String] {
        ["Authorization": "Bearer \(token)"]
    }
    
    public var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder.apiDecoder
        decoder.dateDecodingStrategy = .usDate
        return decoder
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

public struct TheTVDBSeriesSearchResource: TheTVDBAPIResource {
    public typealias ModelType = TheTVDBSeriesSearchResult
    
    static let baseUserURL = URL(string: "https://www.thetvdb.com/series")!

    let searchQuery: String
    
    public var method: String { "search" }
    
    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "query", value: searchQuery),
            URLQueryItem(name: "type", value: "series")
        ]
    }
    
    public init(searchQuery: String) {
        self.searchQuery = searchQuery
    }
}

public struct TheTVDBSeriesDetailResource: TheTVDBAPIResource {
    public typealias ModelType = TheTVDBSeriesDetailResult
    let tvdbID: Int
    public var method: String { "series/\(tvdbID)" }
    
    public init(tvdbID: Int) {
        self.tvdbID = tvdbID
    }
}

public struct TheTVDBSeriesExtendedResource: TheTVDBAPIResource {
    public typealias ModelType = TheTVDBSeriesExtendedResult
    let tvdbID: Int
    public var method: String { "series/\(tvdbID)/extended" }
    
    public init(tvdbID: Int) {
        self.tvdbID = tvdbID
    }
}


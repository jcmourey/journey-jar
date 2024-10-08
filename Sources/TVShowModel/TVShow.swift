import UIKit
import Tagged
import IdentifiedCollections
import ModelElements
import TheTVDBAPI
import DatabaseRepresentable

public struct TVShow: DatabaseRepresentable, Sendable {
    public let id: Tagged<Self, UUID>
    public var title: String
    public let dateAdded: Date
    public var dateModified: Date
    public var team: [String]
    
    // info
    public var recommendations: IdentifiedArrayOf<Recommendation>
    public var interest: Interest?
    public var progress: Progress?
    public var tvdbInfo: TVDBInfo?
    
    public enum Progress: String, CaseIterable, Codable, Sendable {
        case notStarted = "not started"
        case watching
        case finished
    }
    
    public init(id: Tagged<Self, UUID>, title: String = "", dateAdded: Date, dateModified: Date, team: [String], recommendations: IdentifiedArrayOf<Recommendation> = [], interest: Interest? = nil, progress: Progress? = nil, tvdbInfo: TVDBInfo? = nil) {
        self.id = id
        self.title = title
        self.dateAdded = dateAdded
        self.dateModified = dateModified
        self.team = team
        self.recommendations = recommendations
        self.interest = interest
        self.progress = progress
        self.tvdbInfo = tvdbInfo
    }
}

public struct Recommendation: Equatable, Hashable, Identifiable, Codable, Sendable {
    public let id: Tagged<Recommendation, UUID>
    public var name: String
    
    public init(id: Tagged<Recommendation, UUID>, name: String = "") {
        self.id = id
        self.name = name
    }
}


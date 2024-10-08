import Foundation

// pointfree
import Tagged
import IdentifiedCollections

// models
import TeamModel
import UserModel

// types
import DatabaseRepresentable
import ModelElements

public struct TVShow: DatabaseRepresentable, ModifiedDateMeasurable {
    public let id: Tagged<Self, UUID>
    public var title: String
    public let dateAdded: Date?
    public var dateModified: Date?
    public var teamId: Team.ID?
    public var memberIds: [UserModel.ID]
    public var version: Int
    
    public static var version: Int { 2 }
    
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
    
    public init(id: ID, title: String, dateAdded: Date?, dateModified: Date? = nil, teamId: Team.ID? = nil, memberIds: [UserModel.ID] =  [], version: Int = Self.version, recommendations: IdentifiedArrayOf<Recommendation> = [], interest: Interest? = nil, progress: Progress? = nil, tvdbInfo: TVDBInfo? = nil) {
        self.id = id
        self.title = title
        self.dateAdded = dateAdded
        self.dateModified = dateModified
        self.teamId = teamId
        self.memberIds = memberIds
        self.version = version
        self.recommendations = recommendations
        self.interest = interest
        self.progress = progress
        self.tvdbInfo = tvdbInfo
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Tagged<TVShow, UUID>.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded)
        self.dateModified = try container.decodeIfPresent(Date.self, forKey: .dateModified)
        self.teamId = try container.decodeIfPresent(Team.ID.self, forKey: .teamId)
        self.memberIds = try container.decodeIfPresent([UserModel.ID].self, forKey: .memberIds) ?? []
        self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        self.recommendations = try container.decodeIfPresent(IdentifiedArrayOf<Recommendation>.self, forKey: .recommendations) ?? []
        self.interest = try container.decodeIfPresent(Interest.self, forKey: .interest)
        self.progress = try container.decodeIfPresent(TVShow.Progress.self, forKey: .progress)
        self.tvdbInfo = try container.decodeIfPresent(TVDBInfo.self, forKey: .tvdbInfo)
    }
}

public struct Recommendation: DatabaseRepresentable {
    public let id: Tagged<Self, UUID>
    public var name: String
    
    public init(id: ID, name: String = "") {
        self.id = id
        self.name = name
    }
}

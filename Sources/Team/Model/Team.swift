import Foundation

// pointfree
import Tagged
import IdentifiedCollections

// models
import UserModel

// types
import DatabaseRepresentable

public struct Team: DatabaseRepresentable, ModifiedDateMeasurable {
    public let id: Tagged<Self, UUID>
    public var name: String
    public let dateAdded: Date?
    public var dateModified: Date?
    public var ownerId: UserModel.ID?
    public var memberIds: [UserModel.ID]
    public var memberDetails: [TeamMember]
    public var version: Int
        
    public static var version: Int { 2 }
    
    public init(id: ID, name: String, dateAdded: Date?, dateModified: Date?, ownerId: UserModel.ID, memberIds: [UserModel.ID], memberDetails: [TeamMember], version: Int = Self.version) {
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.dateModified = dateModified
        self.ownerId = ownerId
        self.memberIds = memberIds
        self.memberDetails = memberDetails
        self.version = version
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(ID.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded)
        self.dateModified = try container.decodeIfPresent(Date.self, forKey: .dateModified)
        self.memberIds = try container.decodeIfPresent([UserModel.ID].self, forKey: .memberIds) ?? []
        self.ownerId = try container.decodeIfPresent(UserModel.ID.self, forKey: .ownerId) ?? self.memberIds.first
        self.memberDetails = try container.decodeIfPresent([TeamMember].self, forKey: .memberDetails) ?? []
        self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
    }
}

public struct TeamMember: DatabaseRepresentable {
    public var id: Tagged<Self, String> { uid }
    public let uid: ID
    public var name: String?
    public var photoURL: URL?
    public var joinDate: Date?
    public var email: String?
    
    public init(uid: ID, name: String, photoURL: URL? = nil, joinDate: Date? = nil, email: String? = nil) {
        self.uid = uid
        self.name = name
        self.photoURL = photoURL
        self.joinDate = joinDate
        self.email = email
    }
    
    public init(from user: UserModel, joinDate: Date) {
        uid = ID(user.uid.rawValue)
        name = user.name
        photoURL = user.photoURL
        self.joinDate = joinDate
        email = user.email
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(ID.self, forKey: .uid)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.photoURL = try container.decodeIfPresent(URL.self, forKey: .photoURL)
        self.joinDate = try container.decodeIfPresent(Date.self, forKey: .joinDate)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}

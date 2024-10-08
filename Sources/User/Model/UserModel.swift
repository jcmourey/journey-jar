import Foundation

// pointfree
import Tagged

// types
import DatabaseRepresentable

public struct UserModel: DatabaseRepresentable {
    public var id: Tagged<Self, String> { uid }
    public let uid: ID
    public var name: String?
    public var photoURL: URL?
    public var provider: String?
    public var providerUserId: String?
    public var creationDate: Date?
    public var lastSignInDate: Date?
    public var dateModified: Date?
    public var email: String?
    public var version: Int
    
    public static var version: Int { 2 }
    
    public var isAnonymous: Bool { provider == nil }
    
    public init(uid: ID, name: String?, photoURL: URL?, provider: String?, providerUserId: String?, creationDate: Date?, lastSignInDate: Date?, dateModified: Date?, email: String?, version: Int = Self.version) {
        self.uid = uid
        self.name = name
        self.photoURL = photoURL
        self.provider = provider
        self.providerUserId = providerUserId
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.dateModified = dateModified
        self.email = email
        self.version = version
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(ID.self, forKey: .uid)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.photoURL = try container.decodeIfPresent(URL.self, forKey: .photoURL)
        self.provider = try container.decodeIfPresent(String.self, forKey: .provider)
        self.providerUserId = try container.decodeIfPresent(String.self, forKey: .providerUserId)
        self.creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate)
        self.lastSignInDate = try container.decodeIfPresent(Date.self, forKey: .lastSignInDate)
        self.dateModified = try container.decodeIfPresent(Date.self, forKey: .dateModified)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
    }
}

public enum AuthState {
    case guest      // Anonymously authenticated in Firebase
    case signedIn   // Authenticated in Firebase using one of the service providers (not anonymous)
    case signedOut  // Not authenticated in Firebase
}

extension UserModel {
    public var authState: AuthState {
        isAnonymous ? .guest: .signedIn
    }
}

extension UserModel? {
    public var authState: AuthState {
        self?.authState ?? .signedOut
    }
}

extension UserModel: CustomStringConvertible {
    public var description: String {
        (
            [
                uid.rawValue,
                name,
                provider,
                providerUserId != uid.rawValue ? providerUserId: nil
            ] as [String?]
        )
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}

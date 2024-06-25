import Foundation
import Tagged
import DatabaseRepresentable

public struct UserLogin: DatabaseRepresentable {
    public let id: Tagged<Self, UUID>
    public let uid: String
    public var name: String?
    public let photoURL: URL?
    public let isAnonymous: Bool
    public let isEmailVerified: Bool
    public let creationDate: Date?
    public let lastSignInDate: Date?
    public let tenantID: String?
    public let email: String?
    public let phoneNumber: String?
    public let signInProvider: String?
    public let signInName: String?
    
    public init(id: ID, uid: String, name: String?, photoURL: URL?, isAnonymous: Bool, isEmailVerified: Bool, creationDate: Date?, lastSignInDate: Date?, tenantID: String?, email: String?, phoneNumber: String?, signInProvider: String?, signInName: String?) {
        self.id = id
        self.uid = uid
        self.name = name
        self.photoURL = photoURL
        self.isAnonymous = isAnonymous
        self.isEmailVerified = isEmailVerified
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.tenantID = tenantID
        self.email = email
        self.phoneNumber = phoneNumber
        self.signInProvider = signInProvider
        self.signInName = signInName
    }
}


extension UserLogin {
    public var displayName: String {
        name ?? signInName ?? ""
    }
}

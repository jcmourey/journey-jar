import Foundation
import Tagged
import DatabaseRepresentable
import FirebaseAuth
import ComposableArchitecture

public struct UserModel: DatabaseRepresentable {
    public let uid: String
    public var name: String
    public var photoURL: URL?
    public var creationDate: Date?
    public var lastSignInDate: Date?
    public var email: String?
        
    public var id: String { uid }

}

extension UserModel {
    init?(userName: String?, from authUser: User) {
        @Shared(.userName) var userName
        
        self.init(
            uid: authUser.uid,
            name: userName ?? authUser.displayName ?? "",
            photoURL: authUser.photoURL,
            creationDate: authUser.metadata.creationDate,
            lastSignInDate: authUser.metadata.lastSignInDate,
            email: authUser.email
        )
    }
}

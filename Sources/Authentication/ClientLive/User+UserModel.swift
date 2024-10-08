// pointfree
import Dependencies

// firebase
import FirebaseAuth

// models
import UserModel

extension UserModel {
    public init?(for user: User?) {
        guard let user else { return nil }
        
        @Dependency(\.date.now) var now
        let providerInfo = user.providerData.first
        
        self.init(
            uid: ID(user.uid),
            name: user.displayName,
            photoURL: user.photoURL,
            provider: providerInfo?.providerID,
            providerUserId: providerInfo?.uid,
            creationDate: user.metadata.creationDate,
            lastSignInDate: user.metadata.lastSignInDate,
            dateModified: now,
            email: user.email,
            version: Self.version
        )
    }
}

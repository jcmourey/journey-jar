// pointfree
import Dependencies

// dependencies
import UserDatabaseClient

// models
import UserModel

// modules
import FirebaseQuery

extension UserDatabaseClient: DependencyKey {
    public static let liveValue: UserDatabaseClient = {
        let firebase: FirebaseQuery<UserModel> = .init()
        
        return Self(
            save: { try firebase.save($0) },
            delete: { try await firebase.delete($0) }
        )
    }()
}

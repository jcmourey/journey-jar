import Dependencies
import UserDatabaseClient
import FirebaseService
import UserModel
import FirebaseDependencyKeyLive

extension UserDatabaseClient: FirebaseDependencyKey, DependencyKey {
    public typealias Object = UserModel
    public static var liveValue: UserDatabaseClient = Self.liveValue
}

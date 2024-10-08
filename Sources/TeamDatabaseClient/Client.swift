import DependenciesMacros
import IdentifiedCollections
import UserModel
import FirebaseService

@DependencyClient
public struct UserDatabaseClient: Sendable, FirebaseDependencyKey {
    public var read: @Sendable (
        _ uid: String,
        _ orderBy: String,
        _ descending: Bool,
        _ limit: Int,
        _ success: @escaping (IdentifiedArrayOf<UserModel>) async -> Void,
        _ failure: @escaping (any Error) async -> Void
        ) async -> Void
    public var stopListening: @Sendable () async -> Void
    public var save: @Sendable (UserModel) async throws -> Void
    public var delete: @Sendable (UserModel) async throws -> Void
    public var update: @Sendable (_ old: UserModel, _ new: UserModel) async throws -> Void
}

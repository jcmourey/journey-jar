// pointfree
import DependenciesMacros
import Dependencies

// dependencies
import TeamDatabaseClient

// models
import UserModel

@DependencyClient
public struct UserDatabaseClient: Sendable {
    public var save: @Sendable (UserModel) async throws -> Void
    public var delete: @Sendable (UserModel) async throws -> Void
}

enum UserDatabaseClientError: Error {
    case noUserToSave
}

extension UserDatabaseClient {
    public func save(user: UserModel?) async throws {
        guard let user else {
            throw UserDatabaseClientError.noUserToSave
        }
        print("saving: \(user)")
        try await save(user)
        
        @Dependency(\.teamDatabaseClient) var teamDb
        try await teamDb.createTeamIfNotExists(user)
    }
}

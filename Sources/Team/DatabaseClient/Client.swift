// pointfree
import IdentifiedCollections
import DependenciesMacros

// models
import TeamModel
import UserModel

@DependencyClient
public struct TeamDatabaseClient: Sendable {
    public var createTeamIfNotExists: @Sendable (_ user: UserModel) async throws -> Void
    public var fetch: @Sendable () async throws -> IdentifiedArrayOf<Team>
    public var listen: @Sendable () async throws -> AsyncThrowingStream<IdentifiedArrayOf<Team>, Error>
    public var save: @Sendable (Team) async throws -> Void
    public var delete: @Sendable (Team) async throws -> Void
}

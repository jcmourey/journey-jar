import DependenciesMacros
import IdentifiedCollections
import TVShowModel

@DependencyClient
public struct TVShowDatabaseClient: Sendable {
    public var read: @Sendable (
        _ uid: String,
        _ orderBy: String,
        _ descending: Bool,
        _ limit: Int,
        _ success: @escaping (IdentifiedArrayOf<TVShow>) async -> Void,
        _ failure: @escaping (any Error) async -> Void
        ) async -> Void
    public var stopListening: @Sendable () async -> Void
    public var create: @Sendable (TVShow) async throws -> Void
    public var delete: @Sendable (TVShow) async throws -> Void
    public var update: @Sendable (_ old: TVShow, _ new: TVShow) async throws -> Void
}

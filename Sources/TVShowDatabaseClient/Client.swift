import DependenciesMacros
import IdentifiedCollections

@DependencyClient
public struct TVShowDatabaseClient: Sendable {
    public var read: @Sendable (
        _ orderBy: String,
        _ descending: Bool,
        _ limit: Int,
        _ success: (IdentifiedArrayOf<TVShow>) async throws -> Void,
        _ failure: (any Error) -> Void
        ) async throws -> Void
    public var stopListening: @Sendable () -> Void
    public var create: @Sendable (TVShow) async throws -> Void
    public var delete: @Sendable (TVShow) async throws -> Void
    public var update: @Sendable (_ old: TVShow, _ new: TVShow) async throws -> Void
}

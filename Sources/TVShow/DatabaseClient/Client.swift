// pointfree
import DependenciesMacros
import IdentifiedCollections

// models
import TVShowModel

@DependencyClient
public struct TVShowDatabaseClient : Sendable {
    public var listen: @Sendable (
        _ orderBy: String,
        _ descending: Bool,
        _ limit: Int
    ) async throws -> AsyncThrowingStream<IdentifiedArrayOf<TVShow>, Error>
    public var save: @Sendable (TVShow) async throws -> Void
    public var delete: @Sendable (TVShow) async throws -> Void
}

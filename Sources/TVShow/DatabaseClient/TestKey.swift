// pointfree
import Dependencies
import IdentifiedCollections

// models
import TVShowModel

extension DependencyValues {
    public var tvShowDatabaseClient: TVShowDatabaseClient {
        get { self[TVShowDatabaseClient.self] }
        set { self[TVShowDatabaseClient.self] = newValue }
    }
}

extension TVShowDatabaseClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension TVShowDatabaseClient {
    public static var noop: Self {
        Self(
            listen: { _,_,_ in .finished() },
            save: { _ in },
            delete: { _ in }
        )
    }
}



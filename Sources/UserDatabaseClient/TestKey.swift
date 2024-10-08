import Dependencies

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
    public static let noop = Self(
        read: { _,_,_,_,_,_ in },
        stopListening: { },
        create: { _ in },
        delete: { _ in },
        update: { _,_ in }
    )
}


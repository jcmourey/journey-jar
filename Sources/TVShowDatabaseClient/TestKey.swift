import Dependencies

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

extension DatabaseClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension DatabaseClient {
    public static let noop = DatabaseClient(
        addQueryListener: { _,_,_,_,_ in },
        removeQueryListener: { },
        create: { _ in },
        delete: { _ in },
        update: { _,_ in }
    )
}


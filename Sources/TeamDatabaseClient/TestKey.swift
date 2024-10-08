import Dependencies

extension DependencyValues {
    public var userDatabaseClient: UserDatabaseClient {
        get { self[UserDatabaseClient.self] }
        set { self[UserDatabaseClient.self] = newValue }
    }
}

extension UserDatabaseClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

import Dependencies

extension DependencyValues {
    public var authenticationClient: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}

extension AuthenticationClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension AuthenticationClient {
    public static let noop = Self(
        user: { nil },
        state: { .guest },
        signInAsGuest: { },
        signInWithGoogle: { },
        signInWithApple: { _ in },
        prepareAppleRequest: { _ in },
        handleGoogleURL: { _ in },
        signOut: { },
        deleteUserAccount: { }
    )
}


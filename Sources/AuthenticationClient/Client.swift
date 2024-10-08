import ComposableArchitecture
import GoogleSignIn
import AuthenticationServices

@DependencyClient
public struct AuthenticationClient: Sendable {
    public var signInAsGuest: @Sendable () async throws -> Void
    public var signInWithGoogle: @Sendable () async throws -> Void
    public var prepareAppleRequest: @Sendable (ASAuthorizationAppleIDRequest) -> Void
    public var signInWithApple: @Sendable (Result<ASAuthorization, any Error>) async throws -> Void
    public var signOut: @Sendable () async throws-> Void
}


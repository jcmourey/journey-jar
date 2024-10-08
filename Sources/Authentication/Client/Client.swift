import Foundation
import AuthenticationServices

// pointfree
import DependenciesMacros

// models
import UserModel

@DependencyClient
public struct AuthenticationClient: Sendable {
    public var listen: @Sendable () async -> AsyncStream<UserModel?> = { .finished }
    public var user: @Sendable () async -> UserModel?
    public var signInAsGuest: @Sendable () async throws -> Void
    public var signInWithGoogle: @Sendable () async throws -> Void
    public var signInWithApple: @Sendable (Result<ASAuthorization, any Error>) async throws -> Void
    public var prepareAppleRequest: @Sendable (ASAuthorizationAppleIDRequest) async -> Void
    public var handleGoogleURL: @Sendable (URL) async -> Void
    public var signOut: @Sendable () async throws -> Void
    public var deleteUserAccount: @Sendable () async throws -> Void
    public var changeUserName: @Sendable (_ newName: String) async throws -> Void
}

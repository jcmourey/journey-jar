// pointfree
import Dependencies

// dependencies
import AuthenticationClient

extension AuthenticationClient: DependencyKey {
    public static let liveValue = {
        let authManager = AuthManager(apple: AppleAuthenticator(), google: GoogleAuthenticator())
        
        return Self(
            listen: { authManager.listen() },
            user: { authManager.user },
            signInAsGuest: { try await authManager.signInAsGuest() },
            signInWithGoogle: { try await authManager.signInWithGoogle() },
            signInWithApple: { try await authManager.signInWithApple(result: $0) },
            prepareAppleRequest: { await authManager.prepareAppleRequestAuthorization(request: $0) },
            handleGoogleURL: { await authManager.handleGoogleURL(url: $0) },
            signOut: { try await authManager.signOut() },
            deleteUserAccount: { try await authManager.deleteUserAccount() },
            changeUserName: { try await authManager.changeUserName(to: $0) }
        )
    }()
}

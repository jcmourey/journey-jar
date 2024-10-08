import AuthenticationClient
import Dependencies

extension AuthenticationClient: DependencyKey {
    public static let liveValue: Self {
        let authManager = AuthManager(apple: AppleAuthenticator(), google: GoogleAuthenticator())
        
        return AuthenticationClient(
            user: {
                authManager.user
            },
            state: {
                authManager.authState
            }
            signInAsGuest: {
                try await authManager.signInAsGuest()
            },
            signInWithGoogle: {
                try await authManager.signInWithGoogle()
            },
            signInWithApple: { result in
                try await authManager.signInWithApple(result)
            },
            prepareAppleRequest: { request in
                try await authManager.apple.signInManager.prepareRequestAuthorization(request)
            },
            handleGoogleURL: { url in
                try await authManager.google.signInManager.handle(url: url)
            },
            signOut: {
                authManager.signOut()
            },
            deleteUserAccount: {
                authManager.deleteUserAccount()
            }
        )
    }()
}

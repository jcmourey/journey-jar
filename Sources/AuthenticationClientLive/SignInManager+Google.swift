@preconcurrency import GoogleSignIn
import Firebase
import FirebaseAuth

fileprivate enum GoogleAuthError: Error {
    case noWindowScene
    case noRootViewController
    case noFirebaseClientID
    case noCurrentUser
    case noIDToken
}

actor GoogleSignInManager: SignInManager {
    // Handle Google OAuth URL
    func handle(url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
        
    func signIn() async throws -> GIDGoogleUser {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleAuthError.noFirebaseClientID
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Check previous sign-in.
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
                    throw GoogleAuthError.noCurrentUser
                }
                return try await currentUser.refreshTokensIfNeeded()
            }
            catch {
                // Previous sign in available, but was previously revoked, so initiate sign in flow.
                return try await signInFlow()
            }
        } else {
            return try await signInFlow()
        }
    }

    private func signInFlow() async throws -> GIDGoogleUser {
        // Accessing rootViewController through shared instance of UIApplication.
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            throw GoogleAuthError.noWindowScene
        }
        guard let rootViewController = await windowScene.windows.first?.rootViewController else {
            throw GoogleAuthError.noRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        return result.user
    }
    
    /// Verify Google provider.
    /// - Returns: Boolean indicates whether user is authorized, or authorization has been revoked
    func verify(providerUserId: String?) async -> Bool {
        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            return true
        }
        catch {
            return false // The Google sign in credential is either revoked or was not found.
        }
    }
    
    /// Sign out from `Google`.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

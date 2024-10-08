@preconcurrency import AuthenticationServices

// pointfree
import ComposableArchitecture

// firebase
@preconcurrency import FirebaseAuth
import Firebase
import FirebaseFirestore

// google
@preconcurrency import GoogleSignIn

// dependencies
import AuthenticationClient

// models
import UserModel

// utilities
import Log

//  Modified from AuthManager by Marwa Abou Niaaj on 29/11/2023.
//  ⌘↖: https://github.com/marwaniaaj/AuthLoginSwiftUI.git

enum AuthError: Error {
    case signOutFailed
    case noUser
    case noProvider
    case userNeverSignedIn
    case unknownProvider(String)
    case providerVerificationFailed(String)
}

/// An environment singleton responsible for handling
/// Firebase authentication in app.
actor AuthManager {
    let apple: AppleAuthenticator
    let google: GoogleAuthenticator
        
    /// Common auth link errors.
    private let authLinkErrors: [AuthErrorCode] = [
        .emailAlreadyInUse,
        .credentialAlreadyInUse,
        .providerAlreadyLinked,
    ]
        
    var user: UserModel? { UserModel(for: Auth.auth().currentUser) }
   
    func authenticator(for provider: String?) throws -> any Authenticator {
        switch try SupportedProviderId(rawValue: provider) {
        case .apple: return apple
        case .google: return google
        }
    }
    
    init(apple: AppleAuthenticator, google: GoogleAuthenticator) {
        self.apple = apple
        self.google = google
        
        Task {
            // Verify user if signed in with a provider
            guard let user = await user, let provider = user.provider, let providerUserId = user.providerUserId else {
                return
            }
            do {
                // Verify provider credentials
                try await self.verifySignInProvider(provider: provider, providerUserId: providerUserId)
            } catch {
                logError("signing out because: \(error.localizedDescription)")
                try await signOut()
            }
        }
    }

    // MARK: - Auth State
    /// Add a listener for changes in the authorization state.
    func listen() -> AsyncStream<UserModel?> {
        .init { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, user in
                let userModel = UserModel(for: user)
                continuation.yield(userModel)
            }
            
            continuation.onTermination = { @Sendable _ in
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }

    // MARK: - Verify authentication
    private func verifySignInProvider(provider: String, providerUserId: String) async throws {
        let authenticator = try authenticator(for: provider)
        try await authenticator.signInManager.verify(providerUserId: providerUserId)
    }
    
    // MARK: - Sign-in With Provider
    func signInWithGoogle() async throws  {
        let user = try await google.signInManager.signIn()
        let credentials = try await google.credentials(user)
        let authenticate = authenticateUser
        try await authenticate(credentials) // TODO Swift bug: https://stackoverflow.com/questions/78745506/why-does-calling-an-async-actor-function-in-a-mainactor-result-in-a-compiler-err
    }
    
    func handleGoogleURL(url: URL) async {
        await google.signInManager.handle(url: url)
    }
    
    func prepareAppleRequestAuthorization(request: ASAuthorizationAppleIDRequest) async {
        await apple.signInManager.prepareRequestAuthorization(request: request)
    }
    
    func signInWithApple(result: Result<ASAuthorization, any Error>) async throws {
        let credentials = try await apple.credentials(result)
        let authenticate = authenticateUser
        try await authenticate(credentials) // TODO Swift bug: https://stackoverflow.com/questions/78745506/why-does-calling-an-async-actor-function-in-a-mainactor-result-in-a-compiler-err
    }
    
    func signInAsGuest() async throws {
        try await Auth.auth().signInAnonymously()
    }
    
    //MARK: - Authenticate with Firebase
    private func authenticateUser(credentials: AuthCredential) async throws {
        // If we have authenticated user, then link with given credentials.
        // Otherwise, sign in using given credentials.
        if let user = Auth.auth().currentUser {
            _ = try await authLink(credentials: credentials, with: user)
        } else {
            _ = try await authSignIn(credentials: credentials)
        }
    }
    
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult {
        try await Auth.auth().signIn(with: credentials)
    }
    
    // attempt to link credentialed user with current user
    // revert to normal sign-in if not possible
    private func authLink(credentials: AuthCredential, with user: User) async throws -> AuthDataResult {
        // test whether error is one of the common recoverable errors
        func testRecoverable(_ error: Error) throws -> NSError {
             guard let error = error as NSError?,
                let code = AuthErrorCode(rawValue: error.code),
                authLinkErrors.contains(code) else {
                     throw error
             }
            return error
        }
        
        do {
            let result = try await user.link(with: credentials)

            try await updateDisplayName(for: result.user)

            return result
        } catch {
            logger.debug("FirebaseAuthError: link(with:) failed, \(error)")
            let nsError = try testRecoverable(error)

            // If provider is "apple.com", get updated AppleID credentials from the error object.
            if credentials.provider == AuthProviderID.apple.rawValue,
               let appleCredentials = nsError.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
                return try await authSignIn(credentials: appleCredentials)
            } else {
                return try await authSignIn(credentials: credentials)
            }
        }
    }

    /// Check if user's displayName is null or empty
    /// If so, update using displayName from dataProvider.
    /// - Parameter user: Firebase auth user.
    private func updateDisplayName(for user: User) async throws {
        if let displayName = user.displayName, !displayName.isEmpty {
            return
        }
        guard let displayName = user.providerData.first?.displayName else {
            return
        }
        try await requestNameChange(for: user, to: displayName)
    }
    
    func changeUserName(to newName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        try await requestNameChange(for: user, to: newName)
    }
    
    func requestNameChange(for user: User, to newName: String) async throws {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        try await changeRequest.commitChanges()
    }

    // MARK: - Sign Out
    /// Sign out current `Firebase` auth user
    func signOut() async throws {
        let authenticator = try authenticator(for: user?.provider)
        await authenticator.signInManager.signOut()
        try Auth.auth().signOut()
    }
}

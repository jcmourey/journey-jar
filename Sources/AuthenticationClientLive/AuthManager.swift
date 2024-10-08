//  Modified from AuthManager by Marwa Abou Niaaj on 29/11/2023.
//  ⌘↖: https://github.com/marwaniaaj/AuthLoginSwiftUI.git

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import ComposableArchitecture
import FirebaseAppCheck

fileprivate enum AuthError: Error {
    case signOutFailed
}

/// An environment singleton responsible for handling
/// Firebase authentication in app.
public actor AuthManager {

    /// Current Firebase auth user.
    @Shared(.user) var user: User?

    /// Auth state for current user.
    @Shared(.authState) var authState

    public let apple: AppleAuthenticator
    public let google: GoogleAuthenticator
    var authenticators: [any Authenticator] { [apple, google] }
    
    /// Auth state listener handler
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    /// Common auth link errors.
    private let authLinkErrors: [AuthErrorCode.Code] = [
            .emailAlreadyInUse,
            .credentialAlreadyInUse,
            .providerAlreadyLinked
    ]
    
    public init(apple: AppleAuthenticator, google: GoogleAuthenticator) {
        self.apple = apple
        self.google = google
        
        class MyAppCheckProvider: NSObject, AppCheckProviderFactory {
            func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
                AppAttestProvider(app: app)
            }
        }
        
        AppCheck.setAppCheckProviderFactory(MyAppCheckProvider())
        FirebaseApp.configure()
        
        Task {
            do {
                try await configure()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func configure() async throws {
        // Start listening to auth changes.
        configureAuthStateChanges()
        // Verify AppleID and Google credentials
        try await verifySignInProvider()
    }

    // MARK: - Auth State
    /// Add listener for changes in the authorization state.
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            print("Auth changed: \(user != nil)")
            self.updateState(user: user)

            if let user {
                /*
                do {
                    try await firestore.getUserDocument(user)
                }
                catch FirestoreErrors.DocumentDoesNotExist {
                    print("User Document Does Not Exist!")
                    await verifyAuthTokenResult()
                    return
                }
                catch {
                    // Other errors
                }
                 */

                /// Validate and force refresh Auth token
                /// - Returns: Boolean indicates if token is valid or not.
//                private func verifyAuthTokenResult() async throws {
//                    let result = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
//                }
            }
        }
    }

    /// Remove listener for changes in the authorization state.
    func removeAuthStateListener() {
        guard let authStateHandle else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandle)
        self.authStateHandle = nil
    }

    /// Update auth state for given user.
    /// - Parameter user: `Optional` firebase user.
    internal func updateState(user: User?) {
        self.user = user
        authState = AuthState(from: user)
    }

    // MARK: - Verify authentication
    private func verifySignInProvider() async throws {
        var verifiedCount = authenticators.count
        
        // sign out of all non verified providers
        for authenticator in authenticators {
            if await !authenticator.signInManager.verify() {
                authenticator.signInManager.signOut()
                verifiedCount -= 1
            }
        }
        
        // If there are no verified providers, sign out of Firebase
        if verifiedCount == 0 {
            try signOut()
        }
    }
    
    // MARK: - Sign-in With Provider
    @discardableResult
    func signInWithGoogle() async throws -> AuthDataResult {
        let user = try await google.signInManager.signIn()
        let credentials = try google.credentials(user)
        return try await authenticateUser(credentials: credentials)
    }
    
    @discardableResult
    func signInWithApple(_ result: Result<ASAuthorization, any Error>) async throws -> AuthDataResult{
        let credentials = try apple.credentials(result)
        return try await authenticateUser(credentials: credentials)
    }
    
    @discardableResult
    func signInAsGuest() async throws -> AuthDataResult {
        let result = try await Auth.auth().signInAnonymously()
        await $authState.withLock { $0 = .guest }
        return result
    }
    
    //MARK: - Authenticate with Firebase
    @discardableResult
    private func authenticateUser(credentials: AuthCredential) async throws -> AuthDataResult {
        // If we have authenticated user, then link with given credentials.
        // Otherwise, sign in using given credentials.
        if let user = Auth.auth().currentUser {
            try await authLink(credentials: credentials, with: user)
        } else {
            try await authSignIn(credentials: credentials)
        }
    }
    
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult {
        let result = try await Auth.auth().signIn(with: credentials)
        updateState(user: result.user)
        return result
    }
    
    // attempt to link credentialed user with current user
    // revert to normal sign-in if not possible
    private func authLink(credentials: AuthCredential, with user: User) async throws -> AuthDataResult {
        // test whether error is one of the common recoverable errors
        func testRecoverable(_ error: Error) throws -> NSError {
             guard let error = error as NSError?,
                let code = AuthErrorCode.Code(rawValue: error.code),
                authLinkErrors.contains(code) else {
                     throw error
             }
            return error
        }
        
        do {
            let result = try await user.link(with: credentials)

            try await updateDisplayName(for: result.user)
            updateState(user: result.user)

            return result
        } catch {
            print("FirebaseAuthError: link(with:) failed, \(error)")
            let nsError = try testRecoverable(error)

            // If provider is "apple.com", get updated AppleID credentials from the error object.
            if credentials.provider == AppleSignInManager.name,
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
        let displayName = user.providerData.first?.displayName
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }

    // MARK: - Sign Out
    /// Sign out current `Firebase` auth user
    func signOut() throws {
        for authenticator in authenticators {
            authenticator.signInManager.signOut()
        }
        try Auth.auth().signOut()
        guard Auth.auth().currentUser == nil else {
            throw AuthError.signOutFailed
        }
        updateState(user: nil)
    }
}

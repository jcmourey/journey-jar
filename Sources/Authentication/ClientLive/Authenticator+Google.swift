// firebase
@preconcurrency import FirebaseAuth

// google
@preconcurrency import GoogleSignIn

enum GoogleAuthError: Error {
    case noWindowScene
    case noRootViewController
    case noFirebaseClientID
    case noCurrentUser
    case noIDToken
}

actor GoogleAuthenticator: Authenticator {
    let signInManager = GoogleSignInManager()
    
    func credentials(_ user: GIDGoogleUser) throws -> AuthCredential {
        guard let idToken = user.idToken?.tokenString else {
            throw GoogleAuthError.noIDToken
        }

        return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
    }
    
    func deleteAccount(needsReAuth: Bool) async throws {
        if needsReAuth {
            try await reauthenticate()
        }
        try await revoke()
    }
    
    /// Re-authenticate Google Account for given Firebase `User`.
    /// - Parameter user: Firebase `User`.
    private func reauthenticate() async throws {
        let googleUser = try await signInManager.signIn()
        guard let idToken = googleUser.idToken?.tokenString else {
            throw GoogleAuthError.noIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleUser.accessToken.tokenString
        )

        // Use this rather than:
        //      try await user.reauthenticate(with:)
        // because the async version returns a non-sendable AuthResult
        // which even though discarded result must still be Sendable
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
            if result != nil {
              continuation.resume()
            } else if let error {
              continuation.resume(throwing: error)
            }
          }
        }
    }

    /// Revoke Google Account (disconnect the connection between app and Google)
    private func revoke() async throws {
        try await GIDSignIn.sharedInstance.disconnect()
      
    }
}
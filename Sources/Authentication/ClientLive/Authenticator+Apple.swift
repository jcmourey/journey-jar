import AuthenticationServices

// firebase
@preconcurrency import FirebaseAuth

enum AppleAuthError: Error {
    case appleIDCredentialNotAvailable
    case noNonce
    case noAppleIDToken
    case unserializableAppleIDToken(String)
    case noAppleProviderId
    case credentialRevoked
    case credentialNotFound
}

actor AppleAuthenticator: Authenticator {
    let signInManager = AppleSignInManager()
    
    func credentials(_ result: Result<ASAuthorization, Error>) async throws -> AuthCredential {
        switch result {
        case let .success(auth):
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                throw AppleAuthError.appleIDCredentialNotAvailable
            }
            guard let nonce = await signInManager.nonce else {
                throw AppleAuthError.noNonce
            }
            guard let appleIDToken = appleIDCredentials.identityToken else {
                throw AppleAuthError.noAppleIDToken
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw AppleAuthError.unserializableAppleIDToken(appleIDToken.debugDescription)
            }
            // Initialize a Firebase credential, including the user's full name.
            let credentials: OAuthCredential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredentials.fullName
            )
            return credentials
            
        case let .failure(error):
            throw error
        }
    }
    
    func deleteAccount(needsReAuth: Bool) async throws {
        let appleIDCredential = try await signInManager.requestAppleAuthorization()

        if needsReAuth {
            try await reauthenticate(appleIDCredential)
        }
        try await revoke(appleIDCredential)
    }
    
    /// Re-authenticate AppleID for given Firebase `User`, with given `AppleIDCredential`.
    /// - Parameters:
    ///   - appleIDCredential: `ASAuthorizationAppleIDCredential`.
    ///   - user: Firebase `User`.
    private func reauthenticate(
        _ appleIDCredential: ASAuthorizationAppleIDCredential
    ) async throws {
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AppleAuthError.noAppleIDToken
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AppleAuthError.unserializableAppleIDToken(appleIDToken.debugDescription)
        }

        guard let nonce = await signInManager.nonce else {
            throw AppleAuthError.noNonce
        }
        
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        try await Auth.auth().currentUser?.reauthenticate(with: credential)
        
    }
    
    /// Revoke AppleID token using given `ASAuthorizationAppleIDCredential`'s authorization code.
    /// - Parameter appleIDCredential: `ASAuthorizationAppleIDCredential`.
    private func revoke(_ appleIDCredential: ASAuthorizationAppleIDCredential) async throws {
        guard let authorizationCode = appleIDCredential.authorizationCode else { return }
        guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return }

        try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)

    }
}

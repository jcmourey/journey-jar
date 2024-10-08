import AuthenticationServices
import CryptoKit
import Log

fileprivate enum AppleAuthError: Error {
    case appleIDCredentialNotAvailable
    case noNonce
    case noAppleIDToken
    case unserializableAppleIDToken(String)
}

actor AppleSignInManager: SignInManager {
    /// Un-hashed nonce.
    fileprivate var currentNonce: String?

    /// Current un-hashed nonce
    var nonce: String? {
        currentNonce ?? nil
    }
    
    var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>? = nil

    /// Verify AppleID provider.
    /// - Returns: Boolean indicates whether user is authorized, or authorization has been revoked
    func verify(providerUserId: String?) async -> Bool {
        guard let providerUserId else {
            logger.warning("No Apple provider UserID")
            return false
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()

        do {
            let credentialState = try await appleIDProvider.credentialState(forUserID: providerUserId)
            return credentialState != .revoked && credentialState != .notFound
        }
        catch {
            return false
        }
    }
    
    // No sign out with Apple, only revoke permissiosn
    func signOut() {}
    
    // Helper methods
    func requestAppleAuthorization() async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            let appleIdProvider = ASAuthorizationAppleIDProvider()
            let request = appleIdProvider.createRequest()
            prepareRequestAuthorization(request: request)
            self.continuation = continuation

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self as? ASAuthorizationControllerDelegate
            authorizationController.performRequests()
        }
    }

    func prepareRequestAuthorization(request: ASAuthorizationAppleIDRequest) {
        let newNonce = randomNonceString()
        currentNonce = newNonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(newNonce)
    }
 }

extension AppleSignInManager/*: ASAuthorizationControllerDelegate*/ {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

// MARK: - Nonce
extension AppleSignInManager {

    /// Generate a random string -a cryptographically secure "nonce"- which will be used to make sure the ID token was granted specifically in response to the app's authentication request.
    /// - parameter length: integer
    /// - returns: string containing a cryptographically secure "nonce"
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    /// Secure Hashing Algorithm 2 (SHA-2) hashing with a 256-bit digest
    /// - parameter input: String containing nonce.
    /// - returns: String containing hash value of nonce.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

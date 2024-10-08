// firebase
import FirebaseAuth

extension AuthManager {
    /// Delete user account form Firebase Auth
    func deleteUserAccount() async throws {
        guard let user else {
            throw AuthError.noUser
        }
        guard let lastSignInDate = user.lastSignInDate else {
            throw AuthError.userNeverSignedIn
        }
        let needsReAuth = !lastSignInDate.isWithinPast(minutes: 1)

        let authenticator = try authenticator(for: user.provider)
        try await authenticator.deleteAccount(needsReAuth: needsReAuth)
    }
}

extension Date {
    func isWithinPast(minutes: Int) -> Bool {
        let now = Date.now
        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
        let range = timeAgo...now
        return range.contains(self)
    }
}

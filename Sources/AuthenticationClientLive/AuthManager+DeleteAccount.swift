import AuthenticationServices
import FirebaseAuth
import GoogleSignIn

fileprivate enum AccountDeleteError: Error {
    case noCurrentUser
    case userNeverSignedIn
}
extension AuthManager {

    /// Delete user account form Firebase Auth
    func deleteUserAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountDeleteError.noCurrentUser
        }
        guard let lastSignInDate = user.metadata.lastSignInDate else {
            throw AccountDeleteError.userNeverSignedIn
        }

        let needsReAuth = !lastSignInDate.isWithinPast(minutes: 1)
        let providers = user.providerData.map(\.providerID)

       for authenticator in authenticators {
           try await authenticator.deleteAccount(user: user, needsReAuth: needsReAuth)
           try await user.delete()
           updateState(user: user)
        }
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

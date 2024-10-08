// firebase
import FirebaseAuth

public protocol Authenticator: Sendable {
    associatedtype SignInManagerType: SignInManager
    associatedtype AuthorizationType: Sendable
    var signInManager: SignInManagerType { get }
    func credentials(_: AuthorizationType) async throws -> AuthCredential
    func deleteAccount(needsReAuth: Bool) async throws -> Void
}

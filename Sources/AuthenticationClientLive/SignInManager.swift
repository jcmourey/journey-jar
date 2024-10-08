public protocol SignInManager {
    func verify(providerUserId: String?) async -> Bool
    func signOut() async -> Void
}
//
//public protocol Authenticator: Sendable {
//    associatedtype SignInManagerType: SignInManager
//    associatedtype AuthorizationType
//    var signInManager: SignInManagerType { get set }
//    func credentials(_: AuthorizationType) async throws -> AuthCredential
//    func deleteAccount(needsReAuth: Bool) async throws -> Void
//}

public protocol SignInManager {
    func verify(providerUserId: String?) async throws
    func signOut() async -> Void
}

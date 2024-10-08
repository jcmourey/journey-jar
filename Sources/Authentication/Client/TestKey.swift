// pointfree
import Dependencies

// models
import UserModel

extension DependencyValues {
    public var authenticationClient: AuthenticationClient {
        get { self[AuthenticationClient.self] }
        set { self[AuthenticationClient.self] = newValue }
    }
}

extension AuthenticationClient: TestDependencyKey {
    public static let previewValue = Self.mock
    public static let testValue = Self()
}

extension AuthenticationClient {
    public static let noop = Self(
        listen: { .finished },
        user: { nil },
        signInAsGuest: { },
        signInWithGoogle: { },
        signInWithApple: { _ in },
        prepareAppleRequest: { _ in },
        handleGoogleURL: { _ in },
        signOut: { },
        deleteUserAccount: { },
        changeUserName: { _ in }
    )
    public static let mock: Self = {
        let userMock = UserMock()
        
        return Self(
            listen: { .init { userMock.user } },
            user: { userMock.user },
            signInAsGuest: { userMock.setGuest() },
            signInWithGoogle: { userMock.setGoogle() },
            signInWithApple: { _ in userMock.setApple() },
            prepareAppleRequest: { _ in print("prepareAppleRequest") },
            handleGoogleURL: { _ in print("handleGoogleURL") },
            signOut: { userMock.clearUser() },
            deleteUserAccount: { userMock.deleteUser() },
            changeUserName: { name in userMock.setName(name) }
        )
    }()
}

actor UserMock {
    var user: UserModel? = nil
    
    let guestUser = UserModel(uid: UserModel.ID("guest-user"), name: nil, photoURL: nil, provider: nil, providerUserId: nil, creationDate: nil, lastSignInDate: nil, dateModified: nil, email: nil)

    let googleUser = UserModel(uid: UserModel.ID("google-user"), name: nil, photoURL: nil, provider: "google.com", providerUserId: "google-user", creationDate: nil, lastSignInDate: nil, dateModified: nil, email: nil)

    let appleUser = UserModel(uid: UserModel.ID("apple-user"), name: nil, photoURL: nil, provider: "apple.com", providerUserId: "apple-user", creationDate: nil, lastSignInDate: nil, dateModified: nil, email: nil)
    
    func setGuest() {
        user = guestUser
    }
    
    func setGoogle() {
        user = googleUser
    }
    
    func setApple() {
        user = appleUser
    }
    
    func clearUser() {
        user = nil
    }
    
    func deleteUser() {
        print("deleted user \(user?.uid.rawValue ?? "nil")")
        user = nil
    }
    
    func setName(_ name: String) {
        user?.name = name
    }
}

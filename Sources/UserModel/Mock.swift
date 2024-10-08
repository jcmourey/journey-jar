extension UserLogin {
    static var mock: Self {
        UserLogin(
            uid: "someID",
            userName: "custom user Name for app",
            photoURL: nil,
            isAnonymous: false,
            isEmailVerified: true,
            creationDate: .now,
            lastSignInDate: .now,
            tenantID: nil,
            email: "some@email.com",
            phoneNumber: nil,
            providerID: "apple.com",
            displayName: "AppleID user name"
        )
    }
}


extension UserInfo {
    static var mock: Self {
        UserInfo(
            id: UserInfo.ID(),
            uid: "someID",
            name: "some Name",
            photoURL: nil,
            isAnonymous: false,
            isEmailVerified: true,
            creationDate: .now,
            lastSignInDate: .now,
            tenantID: nil,
            email: "some@email.com",
            phoneNumber: nil,
            signInProvider: "google.com",
            signInName: "Gmail user name"
        )
    }
}


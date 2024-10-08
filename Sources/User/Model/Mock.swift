public extension UserModel {
    static let mockUsers: [Self] = [
        UserModel(
            uid: ID("some-id"),
            name: "Paul",
            photoURL: nil,
            provider: nil,
            providerUserId: nil,
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "paul@email.com"
        ),
        UserModel(
            uid: ID("some-other-id"),
            name: "Mary",
            photoURL: nil,
            provider: nil,
            providerUserId: nil,
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "mary@gmail.com",
            version: 2
        ),
        UserModel(
            uid: ID("yet-another-id"),
            name: "Ivy",
            photoURL: nil,
            provider: nil,
            providerUserId: nil,
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "ivy@gmail.com",
            version: 2
        ),
        UserModel(
            uid: ID("jack-id"),
            name: "Jack",
            photoURL: nil,
            provider: nil,
            providerUserId: nil,
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "jack@gmail.com",
            version: 2
        ),
        UserModel(
            uid: ID("steve-id"),
            name: "Steve",
            photoURL: nil,
            provider: nil,
            providerUserId: nil,
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "steve@gmail.com",
            version: 2
        ),
    ]
}

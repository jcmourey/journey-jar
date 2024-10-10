import Foundation

import IdentifiedCollections

public extension UserModel {
    static let mockUsers: IdentifiedArrayOf<UserModel> = [
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
            uid: "colin-farrell",
            name: "Colin Farrell",
            photoURL: URL(string: "https://image.enjoymovie.net/Y0kCKSfeuRs2obmYBO-yWdyxQ0A=/256x256/smart/core/p/Q0pR-O8YNl.jpg"),
            provider: "apple.com",
            providerUserId: "colin-farrell-appleid",
            creationDate: .now,
            lastSignInDate: .now,
            dateModified: .now,
            email: "colin@farrell.com"
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

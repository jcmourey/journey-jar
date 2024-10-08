// pointfree
import Dependencies

// dependencies
import TVShowDatabaseClient
import AuthenticationClient

// models
import TVShowModel
import TeamModel

// modules
import FirebaseQuery

extension TVShowDatabaseClient: DependencyKey {
    public static let liveValue: Self = {
        let firebase: FirebaseQuery<TVShow> = .init()
        @Dependency(\.authenticationClient) var auth

        return Self(
            listen: { orderBy, descending, limit in
                guard let user = await auth.user() else {
                    throw FirebaseError.noUser
                }
                return firebase.listen(
                    query: { query in
                        query
                            .whereField("memberIds", arrayContains: user.uid.rawValue)
                            .order(by: orderBy, descending: descending)
                            .limit(to: limit)
                    }
                )
            },
            save: { try firebase.save($0) },
            delete: { try await firebase.delete($0) }
        )
    }()
}

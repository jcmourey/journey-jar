// pointfree
import Dependencies

// firebase
import FirebaseFirestore

// dependencies
import AuthenticationClient
import TeamDatabaseClient

// modules
import FirebaseQuery

// models
import TeamModel
import UserModel

// utilities
import Log

extension TeamDatabaseClient: DependencyKey {
    public static let liveValue: Self = {
        let firebase: FirebaseQuery<Team> = .init()
        @Dependency(\.authenticationClient) var auth

        @Sendable
        func authQuery(for uid: UserModel.ID) -> @Sendable (Query) -> Query {
            { $0.whereField("memberIds", arrayContains: uid.rawValue) }
        }
        
        return Self(
            createTeamIfNotExists: { user in
                logger.debug("createTeamIfNotExists for: \(user.uid)")
                let teams = try await firebase.fetch(query: authQuery(for: user.uid))
                if teams.isEmpty {
                    let individualTeam: Team = .individual(for: user)
                    try firebase.save(individualTeam)
                }
            },
            fetch: {
                guard let uid = await auth.user()?.uid else {
                    throw FirebaseError.noUser
                }
                return try await firebase.fetch(query: authQuery(for: uid))
            },
            listen: {
                guard let uid = await auth.user()?.uid else {
                    throw FirebaseError.noUser
                }
                return firebase.listen(query: authQuery(for: uid))
            },
            save: { try firebase.save($0) },
            delete: { try await firebase.delete($0) }
        )
    }()
}

extension Team {
    public static func individual(for user: UserModel) -> Team {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date.now) var now
        return Team(
            id: ID(uuid()),
            name: "Just me",
            dateAdded: now,
            dateModified: now,
            ownerId: user.uid,
            memberIds: [user.uid],
            memberDetails: [TeamMember(from: user, joinDate: now)]
        )
    }
}

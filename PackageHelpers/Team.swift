import PackageDescription

let teamLibrary: Product = .library(
    name: "Team",
    targets: ["TeamFeature", "TeamDatabaseClient", "TeamDatabaseClientLive", "TeamModel"]
)

let teamTargets: [Target] = [
    .target(
        name: "TeamFeature",
        dependencies: [
            // pointfree
            .composableArchitecture,
            .identifiedCollections,
            // dependencies
            "TeamDatabaseClient",
            "AuthenticationClient",
            "ErrorClient",
            // models
            "UserModel",
            "TeamModel",
        ],
        path: "Sources/Team/Feature"
    ),
    .target(
        name: "TeamDatabaseClient",
        dependencies: [
            // pointfree
            .identifiedCollections,
            .dependencies,
            .dependenciesMacros,
            // models
            "UserModel",
            "TeamModel",
        ],
        path: "Sources/Team/DatabaseClient"
    ),
    .target(
        name: "TeamDatabaseClientLive",
        dependencies: [
            // pointfree
            .dependencies,
            // firebase
            .firebaseFirestore,
            // dependencies
            "AuthenticationClient",
           "TeamDatabaseClient",
            // models
            "TeamModel",
            "UserModel",
            // modules,
            "FirebaseQuery",
            // utilities
            "Log",
        ],
        path: "Sources/Team/DatabaseClientLive"
    ),
    .target(
        name: "TeamModel",
        dependencies: [
            // pointfree
            .tagged,
            .identifiedCollections,
            // models
            "UserModel",
            // types
            "DatabaseRepresentable",
        ],
        path: "Sources/Team/Model"
    ),
]

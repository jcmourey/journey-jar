import PackageDescription

public struct TVShow: LibraryDescription {
    static var product: Product = .library(
        name: "TVShow",
        targets: [
            "TheTVDBAPI",
            "TVShowFeature",
            "TVShowDatabaseClient",
            "TVShowDatabaseClientLive",
            "TVShowModel",
        ]
    )
    
    static var targets: [Target] = [
        .target(
            name: "TheTVDBAPI",
            dependencies: [
                // pointfree
                .identifiedCollections,
                // api
                "APIClient",
            ],
            path: "Sources/TVShow/TheTVDBAPI"
        ),
        .target(
            name: "TVShowFeature",
            dependencies: [
                // pointfree
                .composableArchitecture,
                .tagged,
                .identifiedCollections,
                // dependencies
                "AuthenticationClient",
                "TeamDatabaseClient",
                "TVShowDatabaseClient",
                "ErrorClient",
                // models
                "TVShowModel",
                "TeamModel",
                // reducers
                "TeamFeature",
                // api
                "TheTVDBAPI",
                // UI elements
                "Rating",
                "Styleguide",
                // types
                "ModelElements",
                "CollectionConvenience",
                // utilities
                "Date",
                "Log",
            ],
            path: "Sources/TVShow/Feature"
        ),
        .target(
            name: "TVShowDatabaseClient",
            dependencies: [
                // pointfree
                .dependenciesMacros,
                .dependencies,
                .identifiedCollections,
                // models
                "TVShowModel",
            ],
            path: "Sources/TVShow/DatabaseClient"
        ),
        .target(
            name: "TVShowDatabaseClientLive",
            dependencies: [
                // pointfree
                .dependencies,
                // dependencies
                "TVShowDatabaseClient",
                "AuthenticationClient",
                // models
                "TVShowModel",
                "TeamModel",
                // modules
                "FirebaseQuery",
            ],
            path: "Sources/TVShow/DatabaseClientLive"
        ),
        .target(
            name: "TVShowModel",
            dependencies: [
                // pointfree
                .tagged,
                .identifiedCollections,
                // models
                "UserModel",
                "TeamModel",
                // types
                "DatabaseRepresentable",
                "ModelElements",
                // api
                "TheTVDBAPI",
            ],
            path: "Sources/TVShow/Model"
        ),
    ]
    
    static var testTargets: [Target] = [
        .testTarget(
            name: "TVShowTests",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // reducer
                "TVShow",
            ]
        ),
    ]
}

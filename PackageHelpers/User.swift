// swift-tools-version: 6.0
import PackageDescription

public struct User: LibraryDescription {
    static var product: Product = .library(
        name: "User",
        targets: [
            "UserFeature",
            "UserDatabaseClient",
            "UserDatabaseClientLive",
            "UserModel",
        ]
    )
    
    static var targets: [Target] = [
        .target(
            name: "UserFeature",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // google
                .googleSignInSwift,
                // dependencies
                "TVShowDatabaseClient",
                "AuthenticationClient",
                "ErrorClient",
                // models
                "UserModel",
                // UI elements
                "Styleguide",
            ],
            path: "Sources/User/Feature"
        ),
        .target(
            name: "UserDatabaseClient",
            dependencies: [
                // pointfree
               .dependencies,
               .dependenciesMacros,
               // dependencies
               "TeamDatabaseClient",
               // models
               "UserModel",
            ],
            path: "Sources/User/DatabaseClient"
        ),
        .target(
            name: "UserDatabaseClientLive",
            dependencies: [
                // pointfree
                .dependencies,
                // dependencies
                "UserDatabaseClient",
                // models
                "UserModel",
                // modules
                "FirebaseQuery",
            ],
            path: "Sources/User/DatabaseClientLive"
        ),
        .target(
            name: "UserModel",
            dependencies: [
                // pointfree
               .tagged,
               // types
               "DatabaseRepresentable",
            ],
            path: "Sources/User/Model"
        ),
    ]
    
    static var testTargets: [Target] = [
        .testTarget(name: "UserTests",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // reducer
                "UserFeature",
            ]
        ),
    ]
}

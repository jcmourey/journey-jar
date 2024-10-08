import PackageDescription

public struct Authentication: LibraryDescription {
    static var product: Product = .library(
        name: "Authentication",
        targets: [
            "AuthenticationClient",
            "AuthenticationClientLive"
        ]
    )
    
    static var targets: [Target] = [
        .target(
            name: "AuthenticationClient",
            dependencies: [
                // pointfree
                .composableArchitecture,
                .dependencies,
                .dependenciesMacros,
                // models
                "UserModel",
            ],
            path: "Sources/Authentication/Client"
        ),
        .target(
            name: "AuthenticationClientLive",
            dependencies: [
                // pointfree
                .composableArchitecture,
                .dependencies,
                // firebase
                .firebaseAuth,
                .firebaseFirestore,
                // google
                .googleSignIn,
                // dependencies
                "AuthenticationClient",
                // models
                "UserModel",
                // utilities
                "Log",
            ],
            path: "Sources/Authentication/ClientLive"
        ),
    ]
}

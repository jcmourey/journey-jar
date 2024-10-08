import PackageDescription

public struct AppRoot: LibraryDescription {
    static var product: Product = .library(
        name: "AppRoot",
        targets: [
            "AppRoot",
        ]
    )
    
    static var targets: [Target] = [
        .target(
            name: "AppRoot",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // dependencies
                "AuthenticationClient",
                "ErrorClient",
                // models
                "TVShowModel",
                "UserModel",
                // reducers
                "TVShow",
                "User",
                "TeamFeature",
                // modules
                "FirebaseStart",
                // utilities
                "Log",
            ]
        ),

    ]
    
    static var testTargets: [Target] = []
}

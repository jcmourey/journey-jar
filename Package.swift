// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let platforms: [SupportedPlatform] = [.iOS(.v18), .macOS(.v15)]

// MARK: External dependencies
let dependencies: [Package.Dependency] = [
    // apple
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.1"),

    // pointfree
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.15.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    
    // firebase
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.3.0"),
    
    // google
    .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0"),
    
    // utilities
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.3"),
]

extension Target.Dependency {
    // apple
    static var logging: Self { .product(name: "Logging", package: "swift-log") }
    
    // pointfree
    static var composableArchitecture: Self { .product(name: "ComposableArchitecture", package: "swift-composable-architecture") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var tagged: Self { .product(name: "Tagged", package: "swift-tagged") }
    static var identifiedCollections: Self { .product(name: "IdentifiedCollections", package: "swift-identified-collections") }

    // firebase
    static var firebaseAppCheck: Self { .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk") }
    static var firebaseAuth: Self { .product(name: "FirebaseAuth", package: "firebase-ios-sdk") }
    static var firebaseCore: Self { .product(name: "FirebaseCore", package: "firebase-ios-sdk") }
    static var firebaseFirestore: Self { .product(name: "FirebaseFirestore", package: "firebase-ios-sdk") }
    
    // google
    static var googleSignIn: Self { .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS") }
    static var googleSignInSwift: Self { .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS") }

    // kingfisher
    static var kingfisher: Self { .product(name: "Kingfisher", package: "Kingfisher") }
}

protocol LibraryDescription {
    var product: Product { get }
    var targets: [Target] { get }
    var testTargets: [Target] { get }
}

// MARK: AppRoot
struct AppRoot: LibraryDescription {
    let product: Product = .library(
        name: "AppRoot",
        targets: [
            "AppRoot",
        ]
    )
    
    let targets: [Target] = [
        .target(
            name: "AppRoot",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // dependencies
                "AuthenticationClient",
                // models
                "TVShowModel",
                "UserModel",
                // features
                "TVShowFeature",
                "UserFeature",
                "TeamFeature",
                "ErrorFeature",
                // modules
                "FirebaseStart",
                // utilities
                "Log",
            ]
        ),

    ]
    
    let testTargets: [Target] = []
}

// MARK: Authentication
struct Authentication: LibraryDescription {
    let product: Product = .library(
        name: "Authentication",
        targets: [
            "AuthenticationClient",
            "AuthenticationClientLive",
        ]
    )
    
    let targets: [Target] = [
        .target(
            name: "AuthenticationClient",
            dependencies: [
                // pointfree
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
    
    let testTargets: [Target] = []
}

// MARK: Team
struct Team: LibraryDescription {
    let product: Product = .library(
        name: "Team",
        targets: [
            "TeamFeature",
            "TeamDatabaseClient",
            "TeamDatabaseClientLive",
            "TeamModel",
        ]
    )
    
    let targets: [Target] = [
        .target(
            name: "TeamFeature",
            dependencies: [
                // pointfree
                .composableArchitecture,
                .identifiedCollections,
                // dependencies
                "TeamDatabaseClient",
                "AuthenticationClient",
                // models
                "UserModel",
                "TeamModel",
                // features
                "ErrorFeature",
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
    
    let testTargets: [Target] = []
}

// MARK: Error
struct Error: LibraryDescription {
    let product: Product = .library(
        name: "Error",
        targets: [
            "ErrorClient",
            "ErrorClientLive",
            "ErrorFeature",
        ]
    )
    
    let targets: [Target] = [
        .target(
            name: "ErrorClient",
            dependencies: [
                // pointfree
                .dependencies,
                .dependenciesMacros,
            ],
            path: "Sources/Error/Client"
        ),
        .target(
            name: "ErrorClientLive",
            dependencies: [
                // pointfree
                .dependencies,
                // dependencies
                "ErrorClient",
            ],
            path: "Sources/Error/ClientLive"
        ),
        .target(
            name: "ErrorFeature",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // utilities
                "Log",
            ],
            path: "Sources/Error/Feature"
        ),
    ]
    
    let testTargets: [Target] = []
}

// MARK: User
struct User: LibraryDescription {
    let product: Product = .library(
        name: "User",
        targets: [
            "UserFeature",
            "UserDatabaseClient",
            "UserDatabaseClientLive",
            "UserModel",
        ]
    )
    
    let targets: [Target] = [
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
                // models
                "UserModel",
                // features
                "ErrorFeature",
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
    
    let testTargets: [Target] = [
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

// MARK: TVShow
struct TVShow: LibraryDescription {
    let product: Product = .library(
        name: "TVShow",
        targets: [
            "TheTVDBAPI",
            "TVShowFeature",
            "TVShowDatabaseClient",
            "TVShowDatabaseClientLive",
            "TVShowModel",
        ]
    )
    
    let targets: [Target] = [
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
                // models
                "TVShowModel",
                "TeamModel",
                // features
                "TeamFeature",
                "ErrorFeature",
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
    
    let testTargets: [Target] = [
        .testTarget(
            name: "TVShowTests",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // reducer
                "TVShowFeature",
            ]
        ),
    ]
}

// MARK: Other
struct Other: LibraryDescription {
    let product: Product = .library(
        name: "Other",
        targets: [
            "APIClient",
            "CollectionConvenience",
            "DatabaseRepresentable",
            "Date",
            "FirebaseQuery",
            "FirebaseStart",
            "InvitationModel",
            "ModelElements",
            "Log",
            "Rating",
            "Styleguide",
            "TripAdvisorAPI",
        ]
    )
    
    let targets: [Target] = [
        .target(
            name: "APIClient",
            dependencies: [
                // utilities
                "Log",
            ],
            path: "Sources/Other/APIClient"
        ),
        .target(
            name: "CollectionConvenience",
            dependencies: [
                // pointfree
                .identifiedCollections
            ],
            path: "Sources/Other/CollectionConvenience"
        ),
        .target(
            name: "DatabaseRepresentable",
            dependencies: [
                // pointfree
                .identifiedCollections,
            ],
            path: "Sources/Other/DatabaseRepresentable"
        ),
        .target(
            name: "Date",
            path: "Sources/Other/Date"
        ),

        .target(
            name: "FirebaseQuery",
            dependencies: [
                // pointfree
                .identifiedCollections,
                // firebase
                .firebaseFirestore,
                // types
                "DatabaseRepresentable",
                // utilities
                "Log",
            ],
            path: "Sources/Other/FirebaseQuery"
        ),
        .target(
            name: "FirebaseStart",
            dependencies: [
                // firebase
                .firebaseAppCheck,
                .firebaseCore,
                .firebaseFirestore,
            ],
            path: "Sources/Other/FirebaseStart"
        ),

        .target(
            name: "InvitationModel",
            path: "Sources/Other/InvitationModel"
        ),
        .target(
            name: "Log",
            dependencies: [
                // apple
                .logging,
            ],
            path: "Sources/Other/Log"
        ),
        .target(
            name: "ModelElements",
            path: "Sources/Other/ModelElements"
        ),
        .target(
            name: "Rating",
            path: "Sources/Other/Rating"
        ),
        .target(
            name: "Styleguide",
            dependencies: [
                // pointfree
                .composableArchitecture,
                // kingfisher
                .kingfisher,
            ],
            path: "Sources/Other/Styleguide"
        ),

        .target(
            name: "TripAdvisorAPI",
            dependencies: [
                // api
                "APIClient",
            ],
            path: "Sources/Other/TripAdvisorAPI"
        ),
    ]
    
    let testTargets: [Target] = []
}

let libraries: [any LibraryDescription] = [
    AppRoot(),
    Authentication(),
    Team(),
    Error(),
    User(),
    TVShow(),
    Other(),
]

let products = libraries.map(\.product)

let targets = libraries.flatMap(\.targets) + libraries.flatMap(\.testTargets)

let package = Package(
    name: "JourneyJar",
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets,
    swiftLanguageModes: [.v6]
)

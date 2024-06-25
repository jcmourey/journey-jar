// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JourneyJar",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "AppRoot", targets: ["AppRoot"]),
        .library(name: "Authentication", targets: ["Authentication"]),
        .library(name: "CollectionConvenience", targets: ["CollectionConvenience"]),
        .library(name: "DatabaseRepresentable", targets: ["DatabaseRepresentable"]),
        .library(name: "Date", targets: ["Date"]),
        .library(name: "Future", targets: ["Future"]),
        .library(name: "ModelElements", targets: ["ModelElements"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "Rating", targets: ["Rating"]),
        .library(name: "Styleguide", targets: ["Styleguide"]),
        .library(name: "TheTVDBAPI", targets: ["TheTVDBAPI"]),
        .library(name: "TripAdvisorAPI", targets: ["TripAdvisorAPI"]),
        .library(name: "TVShow", targets: ["TVShow"]),
        .library(name: "UserLogin", targets: ["UserLogin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.27.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/firebase/FirebaseUI-iOS.git", from: "13.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "APIClient"),
        .target(
            name: "AppRoot",
            dependencies: [
                .firebaseAppCheck,
                .firebaseAuthUI,
                .composableArchitecture,
                "TVShow",
                "Authentication",
                "Styleguide",
            ]
        ),
        .target(
            name: "Authentication",
            dependencies: [
                .composableArchitecture,
                .firebaseAuth,
                .firebaseAuthUI,
                .firebaseGoogleAuthUI,
                .firebaseOAuthUI,
                "UserLogin",
            ]
        ),
        .target(
            name: "CollectionConvenience",
            dependencies: [.collections]
        ),
        .target(
            name: "DatabaseRepresentable",
            dependencies: [.tagged]
        ),
        .target(name: "Date"),
        .target(name: "Future"),
        .target(name: "Rating"),
        .target(name: "ModelElements"),
        .target(
            name: "Persistence",
            dependencies: [
                .firebaseFirestore,
                .firebaseDatabase,
                .collections,
                .composableArchitecture,
                "DatabaseRepresentable",
            ]
        ),
        .target(
            name: "Styleguide",
            dependencies: [
                "Kingfisher",
                .composableArchitecture,
                "Future",
                "ModelElements",
            ]
        ),
        .target(
            name: "TheTVDBAPI",
            dependencies: [
                .collections,
                "APIClient",
            ]
        ),
        .target(
            name: "TripAdvisorAPI",
            dependencies: ["APIClient"]
        ),
        .target(
            name: "TVShow",
            dependencies: [
                .composableArchitecture,
                .tagged,
                .collections,
                "Date",
                "Styleguide",
                "ModelElements",
                "TheTVDBAPI",
                "CollectionConvenience",
                "Rating",
                "Persistence",
                "DatabaseRepresentable",
            ]
        ),
        .target(
            name: "UserLogin",
            dependencies: [
                .tagged,
                "DatabaseRepresentable",
                "Styleguide",
            ]
        ),

        .testTarget(name: "TVShowTests", dependencies: ["TVShow"]),
    ]
)

extension Target.Dependency {
    static var firebaseAuthUI: Self { .product(name: "FirebaseAuthUI", package: "FirebaseUI-iOS") }
    static var firebaseGoogleAuthUI: Self { .product(name: "FirebaseGoogleAuthUI", package: "FirebaseUI-iOS") }
    static var firebaseOAuthUI: Self { .product(name: "FirebaseOAuthUI", package: "FirebaseUI-iOS") }
    
    static var firebaseAppCheck: Self { .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk") }
    static var firebaseAuth: Self { .product(name: "FirebaseAuth", package: "firebase-ios-sdk") }
    static var firebaseCore: Self { .product(name: "FirebaseCore", package: "firebase-ios-sdk") }
    static var firebaseDatabase: Self { .product(name: "FirebaseDatabase", package: "firebase-ios-sdk") }
    static var firebaseFirestore: Self { .product(name: "FirebaseFirestore", package: "firebase-ios-sdk") }

    static var composableArchitecture: Self { .product(name: "ComposableArchitecture", package: "swift-composable-architecture") }
    static var tagged: Self { .product(name: "Tagged", package: "swift-tagged") }
    static var collections: Self { .product(name: "Collections", package: "swift-collections") }
}

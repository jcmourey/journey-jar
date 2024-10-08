// swift-tools-version: 6.0
import PackageDescription

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

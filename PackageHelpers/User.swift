import PackageDescription

public struct Error: LibraryDescription {
    static var product: Product = .library(
        name: "Error",
        targets: [
            "ErrorClient",
            "ErrorClientLive",
            "ErrorFeature",
        ]
    )
    
    static var targets: [Target] = [
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
}

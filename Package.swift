// swift-tools-version: 6.0
import PackageDescription

// Root path (relative to Package.swift) containing all the source files
let sourceRootPath = "Sources"

let platforms: [SupportedPlatform] = [.iOS(.v18)/*, .macOS(.v15)*/]

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

enum ModuleType {
    case flat           // module sources are directly in group directory
    case prefixed       // module sources are in a subdirectory, target to be prefixed with group name
    case nonPrefixed    // module sources are in a subdirectory, target *not* prefixed with group name
}

/// A Module corresponds to a single Product (library) containing a single target of the same name,
/// with dependencies and a single optional test target
struct Module {
    let name: String
    let type: ModuleType
    let dependencies: [Target.Dependency]
    let testTarget: Target?
    
    init(name: String, type: ModuleType = .prefixed, dependencies: [Target.Dependency] = [], testTarget: Target? = nil) {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.testTarget = testTarget
    }
    
    // target name depends whether it's a flat module, prefixed, or nonPrefixed
    func targetName(groupName: String) -> String {
        switch type {
        case .flat: groupName
        case .nonPrefixed: name
        case .prefixed: "\(groupName)\(name)"
        }
    }
    
    // source path depends whether it's a flat module or not
    func sourcePath(groupName: String) -> String {
        let relativePath = switch type {
        case .flat: groupName
        default: "\(groupName)/\(name)"
        }
        return "\(sourceRootPath)/\(relativePath)"
    }
}

/// A GroupDescription allows multiple modules to be stored as subdirectories of a group directory
/// The group directory serves only to organize, it doesn't become a library itself
/// Naming conventions are typically that the group name becomes a prefix to the subdirectory name -> module name
///     e.g. User/DatabaseClient -> library name: UserDatabaseClient
/// This behavior can be avoided by setting type to nonPrefixed:
///     e.g. UIElements/Rating -> library name: Rating
/// Single module groups are simplified, have a flat type:
///     e.g. APIClient (no subdirectory) -> library name: APIClient
/// Paths are computed automatically
struct GroupDescription {
    let name: String
    var modules: [Module]
    
    init(name: String, modules: [Module] = []) {
        self.name = name
        self.modules = modules
    }
    
    var modelDependency: Target.Dependency {
        .init(stringLiteral: "\(name)Model")
    }
    
    var featureDependency: Target.Dependency {
        .init(stringLiteral: "\(name)Feature")
    }
    
    func dependencyClient(for clientName: String) -> Target.Dependency {
        .init(stringLiteral: "\(name)\(clientName)")
    }
   
    func testTarget(dependencies: [Target.Dependency]) -> Target {
        .testTarget(
            name: "\(name)Tests",
            dependencies: [.composableArchitecture, featureDependency] + dependencies
        )
    }
    
    static func flatModule(name: String, dependencies: [Target.Dependency] = [], testTarget: Target? = nil) -> Self {
        .init(name: name)
        .addingModule(
            name: name,
            type: .flat,
            dependencies: dependencies,
            testTarget: testTarget
        )
    }
    
    func addingDependencyClient(
        clientName: String = "Client",
        dependencies: [Target.Dependency] = [],
        liveDependencies: [Target.Dependency] = []
    ) -> Self {
        addingModule(
            name: clientName,
            type: .prefixed,
            dependencies: [.dependencies, .dependenciesMacros] + dependencies
        )
        .addingModule(
            name: "\(clientName)Live",
            type: .prefixed,
            dependencies: [.dependencies, dependencyClient(for: clientName)] + liveDependencies
        )
    }
    
    func addingDatabaseDependencyClient(
        clientName: String = "DatabaseClient",
        dependencies: [Target.Dependency] = [],
        liveDependencies: [Target.Dependency] = [],
        modelDependencies: [Target.Dependency] = [],
        featureDependencies: [Target.Dependency] = [],
        hasTests: Bool = false
    ) -> Self  {
        addingDependencyClient(
            clientName: clientName,
            dependencies: [.identifiedCollections, modelDependency] + dependencies,
            liveDependencies: [modelDependency] + liveDependencies
        )
        .addingModel(dependencies: modelDependencies)
        .addingFeature(dependencies: [modelDependency, dependencyClient(for: clientName)] + featureDependencies, hasTests: hasTests, testDependencies: [modelDependency])
    }

    func addingFeature(dependencies: [Target.Dependency] = [], hasTests: Bool = false, testDependencies: [Target.Dependency] = []) -> Self {
        addingModule(
            name: "Feature",
            type: .prefixed,
            dependencies: [.composableArchitecture] + dependencies,
            testTarget: hasTests ? testTarget(dependencies: testDependencies): nil
        )
    }
    
    func addingModel(dependencies: [Target.Dependency] = []) -> Self {
        addingModule(
            name: "Model",
            type: .prefixed,
            dependencies: [.tagged, .identifiedCollections, "DatabaseRepresentable"] + dependencies
        )
    }
    
    func addingModule(name: String, type: ModuleType = .nonPrefixed, dependencies: [Target.Dependency] = [], testTarget: Target? = nil) -> Self {
        var copy = self
        copy.modules.append(
            Module(
                name: name,
                type: type,
                dependencies: dependencies,
                testTarget: testTarget
            )
        )
        return copy
    }
    
}

// MARK: APIClient
let apiClient = GroupDescription.flatModule(
    name: "APIClient",
    dependencies: ["Log"]
)

// MARK: AppRoot
let appRoot = GroupDescription.flatModule(
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
)

// MARK: Authentication
let authentication = GroupDescription(name: "Authentication")
    .addingDependencyClient(
        liveDependencies: [
            // firebase
            .firebaseAuth,
            .firebaseFirestore,
            .firebaseCore,
            // google
            .googleSignIn,
            // utilities
            "Log",
        ]
    )

// MARK: Error
let error = GroupDescription(name: "Error")
    .addingFeature(
        dependencies: ["Log"],
        hasTests: true
    )

// MARK: Firebase
let firebase = GroupDescription(name: "Firebase")
    .addingModule(
        name: "Query",
        type: .prefixed,
        dependencies: [
            // pointfree
            .identifiedCollections,
            // firebase
            .firebaseFirestore,
            // types
            "DatabaseRepresentable",
            // utilities
            "Log",
        ]
    )
    .addingModule(
        name: "Start",
        type: .prefixed,
        dependencies: [
            // firebase
            .firebaseAppCheck,
            .firebaseCore,
            .firebaseFirestore,
        ]
    )

// MARK: Other
let other = GroupDescription(name: "Other")
    .addingModule(
        name: "CollectionConvenience",
        dependencies: [.identifiedCollections]
    )
    .addingModule(
        name: "DatabaseRepresentable",
        dependencies: [.identifiedCollections]
    )
    .addingModule(name: "Date")
    .addingModule(name: "InvitationModel")
    .addingModule(
        name: "Log",
        dependencies: [.logging]
    )
    .addingModule(name: "ModelElements")
    .addingModule(
        name: "TripAdvisorAPI",
        dependencies: ["APIClient"]
    )

// MARK: Team
let team = GroupDescription(name: "Team")
    .addingDatabaseDependencyClient(
        dependencies: ["UserModel"],
        liveDependencies: [
            // firebase
            .firebaseFirestore,
            // dependencies
            "AuthenticationClient",
            // models
            "UserModel",
            // modules,
            "FirebaseQuery",
            // utilities
            "Log",
        ],
        modelDependencies:  ["UserModel"],
        featureDependencies: [
            // pointfree
            .identifiedCollections,
            // dependencies
            "AuthenticationClient",
            // models
            "UserModel",
            // features
            "ErrorFeature",
        ]
    )
    
// MARK: TVShow
let tvShow = GroupDescription(name: "TVShow")
    .addingDatabaseDependencyClient(
        liveDependencies: [
            // dependencies
            "AuthenticationClient",
            // models
            "TeamModel",
            // modules
            "FirebaseQuery",
        ],
        modelDependencies: [
            // models
            "TeamModel",
            "UserModel",
            // types
            "ModelElements",
            // api
            "TheTVDBAPI",
        ],
        featureDependencies: [
            // pointfree
            .tagged,
            .identifiedCollections,
            // dependencies
            "AuthenticationClient",
            "TeamDatabaseClient",
            // models
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
        hasTests: true
    )
    .addingModule(
        name: "TheTVDBAPI",
        type: .nonPrefixed,
        dependencies: [
            // pointfree
            .identifiedCollections,
            // api
            "APIClient",
        ]
    )

// MARK: UIElements
let uiElements = GroupDescription(name: "UIElements")
    .addingModule(name: "Rating")
    .addingModule(
        name: "Styleguide",
        dependencies: [
            // pointfree
            .composableArchitecture,
            // kingfisher
            .kingfisher,
        ]
    )

// MARK: User
let user = GroupDescription(name: "User")
    .addingDatabaseDependencyClient(
        dependencies: ["TeamDatabaseClient"],
        liveDependencies: ["FirebaseQuery"],
        featureDependencies: [
            // google
            .googleSignInSwift,
            // dependencies
            "TVShowDatabaseClient",
            "AuthenticationClient",
            // features
            "ErrorFeature",
            // UI elements
            "Styleguide",
        ],
        hasTests: true
    )
    
let groups: [GroupDescription] = [
    apiClient,
    appRoot,
    authentication,
    error,
    firebase,
    other,
    team,
    tvShow,
    uiElements,
    user,
]

let products: [Product] = groups.flatMap { group in
    group.modules.map { module in
        let name = module.targetName(groupName: group.name)
        return .library(
            name: name,
            targets: [name]
        )
    }
}

// Collect module target, and test target if any
func collectTargets(for module: Module, targetName: String, path: String) -> [Target] {
    var targets: [Target] = [
        .target(
            name: targetName,
            dependencies: module.dependencies,
            path: path
       )
    ]
    if let testTarget = module.testTarget {
        targets.append(testTarget)
    }
    return targets
}

let targets: [Target] = groups.flatMap { group in
    group.modules.flatMap { module in
        collectTargets(
            for: module,
            targetName: module.targetName(groupName: group.name),
            path: module.sourcePath(groupName: group.name)
        )
    }
}

let package = Package(
    name: "JourneyJar",
    platforms: platforms,
    products: products,
    dependencies: dependencies,
    targets: targets,
    swiftLanguageModes: [.v6]
)

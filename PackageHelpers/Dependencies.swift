import PackageDescription

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
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var composableArchitecture: Self { .product(name: "ComposableArchitecture", package: "swift-composable-architecture") }
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
// swift-tools-version: 6.0
import PackageDescription



public extension Target.Dependency {
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

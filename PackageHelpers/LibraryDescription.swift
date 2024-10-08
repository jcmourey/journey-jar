import PackageDescription

protocol LibraryDescription {
    static var library: Product { get }
    static var targets: [Target] { get }
}

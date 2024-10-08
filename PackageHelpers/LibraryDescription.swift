// swift-tools-version: 6.0
import PackageDescription

public protocol LibraryDescription {
    static var product: Product { get }
    static var targets: [Target] { get }
    static var testTargets: [Target] { get }
}

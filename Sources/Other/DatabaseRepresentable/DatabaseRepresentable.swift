import Foundation

public protocol DatabaseRepresentable: Codable, Equatable, Identifiable, Sendable, Hashable where ID: Sendable {
    var idString: String { get }
}

extension DatabaseRepresentable {
    public static var collectionName: String { String(describing: self) }
}

extension DatabaseRepresentable where ID: CustomStringConvertible {
    public var idString: String { id.description }
}



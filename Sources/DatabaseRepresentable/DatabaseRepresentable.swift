import Foundation
import Tagged

public protocol DatabaseRepresentable: Codable, Equatable, Identifiable where ID == Tagged<Self, UUID> {}

extension DatabaseRepresentable {
    public static var collectionName: String { String(describing: self) }
    
    public var idString: String { id.uuidString }
}

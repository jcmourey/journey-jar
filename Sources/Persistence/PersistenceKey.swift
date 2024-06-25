import Foundation

extension Codable {
    static var collectionName: String { String(describing: Self.self) }
}

// Associate a local file storage as a local cache for the Firebase backend (better startup performance and in case of no or bad connectivity)
extension PersistenceKey {
    static func firebase<T: Codable>() -> PersistenceKeyDefault<FirebaseStorageKey<T>> {
        PersistenceKeyDefault(.firebase(local: .documentsDirectory.appending(component: "\(T.collectionName).json")), [])
    }
}

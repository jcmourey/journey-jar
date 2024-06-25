import Foundation
import ComposableArchitecture
import DatabaseRepresentable

// Associate a local file storage as a local cache for the Firebase backend (better startup performance and in case of no or bad connectivity)
extension PersistenceKey {
    public static func firebase<T: DatabaseRepresentable>() -> PersistenceKeyDefault<FirebaseStorageKey<T>> {
        PersistenceKeyDefault(.firebase(local: .documentsDirectory.appending(component: "\(T.collectionName).json")), [])
    }
}

// Option to pass a local URL to use fileStorage as a local cache for Firebase (in case of connectivity problems)
extension PersistenceReaderKey {
    public static func firebase<T: DatabaseRepresentable>(local url: URL?) -> FirebaseStorageKey<T> {
        FirebaseStorageKey(local: url)
  }
}

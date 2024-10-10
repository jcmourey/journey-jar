// pointfree
import IdentifiedCollections

// firebase
@preconcurrency import FirebaseFirestore

// types
import DatabaseRepresentable

// utilities
import Log

extension Query {
    func listeningStream<T>(
        includeMetadataChanges: Bool = false,
        decoder: Firestore.Decoder = .decoder
    ) -> AsyncThrowingStream<IdentifiedArrayOf<T>, Error> where T: DatabaseRepresentable, T.ID: Sendable {
        .init { continuation in
            let listener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
                do {
                    if let error {
                        throw error
                    }
                    guard let snapshot else {
                        throw FirebaseError.noSnapshot
                    }
                    let objects = try snapshot.data(as: T.self, decoder: decoder)
                    let array = IdentifiedArray(uniqueElements: objects)
                    continuation.yield(array)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}

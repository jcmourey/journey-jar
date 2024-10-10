// pointfree
import IdentifiedCollections

// firebase
import FirebaseFirestore

// types
import DatabaseRepresentable

// utilities
import Log

public enum FirebaseError: Error {
    case noUser
    case noSnapshot
}

public actor FirebaseQuery<T: DatabaseRepresentable> {
    private var db = Firestore.firestore()
    
    private var listener: ListenerRegistration?
    
    public func collectionRef() -> CollectionReference {
        db.collection(T.collectionName)
    }

    public func documentRef(_ document: T) -> DocumentReference {
        collectionRef().document(document.idString)
    }
    
    public init() {}
  
    public func fetch(
        query: (Query) -> Query
    ) async throws -> IdentifiedArrayOf<T> {
        let query: Query = query(collectionRef())
        logger.debug("\(#function): \(query)")
        return try await query
            .getDocuments()
            .data(as: T.self, decoder: .decoder)
    }
    
    public func listen(
        query: (Query) -> Query
    ) -> AsyncThrowingStream<IdentifiedArrayOf<T>, Error> {
        query(collectionRef()).listeningStream()
    }
    
    public func save(_ document: T) throws {
        logger.debug("saving \(T.self): \(document)")
        try documentRef(document)
            .setData(from: document, merge: true, encoder: .encoder)
    }
    
    public func delete(_ document: T) async throws {
        try await documentRef(document).delete()
    }
}


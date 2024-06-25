//
//  FirebaseService.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 12/06/2024.
//

import Foundation
@preconcurrency import FirebaseFirestore
import IdentifiedCollections
import FirebaseDatabase
import Tagged
import FirebaseCore

enum FirebaseError: Error {
    case emptySnapshotData
    case jsonSerialization(String)
    case listening(Error)
    case noSnapshot(String)
    case invalidJSONObject(String)
    case firebaseNotInitialized
    case noDocumentID
}

extension Firestore {
    @MainActor
    static func configureIfNeeded() throws -> Firestore {
        Firestore
            .firestore()
            .addingCacheSettings()
    }
    
    func addingCacheSettings() -> Self {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        self.settings = settings
        return self
    }
}


actor FirebaseService<T: FirebaseRepresentable> {
    typealias Value = IdentifiedArrayOf<T>
    
    private var _db: Firestore?
    
    private func db() async throws -> Firestore {
        if let _db {
            return _db
        } else {
            let db = try await Firestore.configureIfNeeded()
            _db = db
            return db
        }
    }
    
    private var listener: ListenerRegistration?
    
    private func collectionRef() async throws -> CollectionReference {
        try await db().collection(T.collectionName)
    }

    private func documentRef(_ document: T) async throws -> DocumentReference {
        guard let documentPath = document.id else {
            throw FirebaseError.noDocumentID 
        }
        return try await collectionRef().document(documentPath)
    }
    
    private func listen(update: @Sendable @escaping (_ newValue: Value) async -> Void) async throws {
        listener = try await collectionRef()
            .addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
                do {
                    if let error {
                        throw FirebaseError.listening(error)
                    }
                    
                    guard let snapshot else {
                        throw FirebaseError.noSnapshot(T.collectionName)
                    }
                    
                    let objects = try snapshot.data(as: T.self, decoder: .decoder)
                    let source = snapshot.metadata.isFromCache ? "local cache": "server"
                    print("listener found \(objects.count) objects from \(source)")
                    
                    Task {
                        await update(objects)
                    }
                } catch {
                    print("Error during listening: \(error)")
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // save existing documents to Firebase
    // fetch a fresh copy
    // setup a listener
    func configureListener(with documents: IdentifiedArrayOf<T>, update: @Sendable @escaping (Value) async -> Void) async throws -> Void {
        try await save(documents)
        let fetchedValue = try await fetch()
        await update(fetchedValue)
        try await listen(update: update)
    }
    
    private func fetch() async throws -> IdentifiedArrayOf<T> {
        try await collectionRef()
            .getDocuments()
            .data(as: T.self, decoder: .decoder)
    }
    
    func save(_ documents: IdentifiedArrayOf<T>) async throws {
        for document in documents {
            try await save(document)
        }
    }
    
    func save(_ document: T) async throws {
        try await documentRef(document)
            .setData(from: document, merge: true, encoder: .encoder)
    }
    
    func delete(_ documents: IdentifiedArrayOf<T>) async throws {
        for document in documents {
            try await delete(document)
        }
    }
    
    func delete(_ document: T) async throws {
        try await documentRef(document).delete()
    }
}

extension Firestore.Decoder {
    static var decoder: Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.dateDecodingStrategy = .timestamp
        return decoder
    }
}

extension Firestore.Encoder {
    static var encoder: Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.dateEncodingStrategy = .timestamp
        return encoder
    }
}

extension QuerySnapshot {
    func data<T: Decodable & Identifiable>(as: T.Type, decoder: Firestore.Decoder) throws -> IdentifiedArrayOf<T> {
        let decodedObjects = try documents.map {
            let object = try $0.data(as: T.self, decoder: decoder)
            return object
        }
        return IdentifiedArray(uniqueElements: decodedObjects)
    }
}


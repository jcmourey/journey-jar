// pointfree
import IdentifiedCollections

// firebase
import FirebaseFirestore

extension Firestore.Decoder {
    public static var decoder: Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.dateDecodingStrategy = .timestamp
        return decoder
    }
}

extension Firestore.Encoder {
    public static var encoder: Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.dateEncodingStrategy = .timestamp
        return encoder
    }
}

extension QuerySnapshot {
    public func data<T: Decodable & Identifiable>(as: T.Type, decoder: Firestore.Decoder) throws -> IdentifiedArrayOf<T> {
        let decodedObjects = try documents.map {
            let object = try $0.data(as: T.self, decoder: decoder)
            return object
        }
        return IdentifiedArray(uniqueElements: decodedObjects)
    }
}

//
//  FirebaseStorageKey.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 14/06/2024.
//

import ComposableArchitecture
import Foundation
import IdentifiedCollections

// Option to pass a local URL to use fileStorage as a local cache for Firebase (in case of connectivity problems)
extension PersistenceReaderKey {
    static func firebase<T: FirebaseRepresentable>(local url: URL? = nil) -> Self where Self == FirebaseStorageKey<T> {
        FirebaseStorageKey(local: url)
  }
}

actor FirebaseStorageKey<T: FirebaseRepresentable>: PersistenceKey {
    typealias Value = IdentifiedArrayOf<T>
    
    @Shared private var cache: Value
    private let firebaseService: FirebaseService<T> = FirebaseService()
    
    nonisolated var id: String { T.collectionName }
    
    init(local url: URL?) {
        if let url {
            _cache = Shared(wrappedValue: [], .fileStorage(url))
        } else {
            _cache = Shared(wrappedValue: [], .inMemory(T.collectionName))
        }
    }
    
    nonisolated func load(initialValue: Value?) -> Value? {
        Task {
            if await cache.isEmpty, let initialValue {
                await $cache.withLock { $0 = initialValue }
            }
        }
        return initialValue
    }
    
    nonisolated func save(_ value: Value) {
        Task {
            let cache = await cache
            let addedItems = value.elementsNot(in: cache)
            let deletedItems = cache.elementsNot(in: value)
            let modifiedItems = value.elementsDifferent(from: cache)
            
            do {
                try await firebaseService.delete(deletedItems)
                try await firebaseService.save(modifiedItems + addedItems)
                await $cache.withLock { $0 = value }
            } catch {
                print("An operation failed during firebaseService save of \(id): \(error)")
            }
        }
    }
    
    private func configureFirebaseService(with cache: Value, didSet: @Sendable @escaping (_ newValue: Value?) -> Void) async throws {
        try await firebaseService.configureListener(with: cache, update: { newValue in
            await self.$cache.withLock { $0 = newValue }
            await MainActor.run(resultType: Void.self, body: { didSet(newValue) })
        })
    }
    
    nonisolated func subscribe(initialValue: Value?, didSet: @Sendable @escaping (_ newValue: Value?) -> Void) -> Shared<Value>.Subscription {
        let task = Task {
            let cache = await cache
            didSet(cache)
            do {
                try await configureFirebaseService(with: cache, didSet: didSet)
            } catch {
                print("An operation failed during firebaseService subscribe to \(id): \(error)")
            }
        }
        
        return Shared.Subscription {
            task.cancel()
            Task {
                await self.firebaseService.stopListening()
            }
        }
    }
}

extension IdentifiedArray {
    // elements in self that are not in other
    func elementsNot(in other: Self) -> Self {
        filter {
            !other.contains($0)
        }
    }
}

extension IdentifiedArray where Element: Equatable & Identifiable, ID == Element.ID {
    // elements present in self and other that are different
    func elementsDifferent(from other: Self) -> Self {
        filter { element in
            guard let otherElement = other[id: element.id] else { return false }
            return otherElement != element
        }
    }
}


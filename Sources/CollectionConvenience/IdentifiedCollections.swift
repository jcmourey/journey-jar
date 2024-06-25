import Foundation
import IdentifiedCollections

extension IdentifiedArray {
    func safeIndex(before current: Index) -> Index? {
        guard current > startIndex else { return nil}
        return index(before: current)
    }
    
    func safeIndex(after current: Index) -> Index? {
        guard current < endIndex - 1 else { return nil }
        return index(after: current)
    }
    
    
    func count(before current: Index) -> Int {
        current
    }
    
    func count(after current: Index) -> Int {
        count - current - 1
    }
    
    func index(id: ID?) -> Index? {
        guard let id else { return nil }
        return index(id: id)
    }
    
    func safeIndex(before id: ID?) -> Index? {
        guard let current = index(id: id) else { return nil }
        return safeIndex(before: current)
    }
    
    func safeIndex(after id: ID?) -> Index? {
        guard let current = index(id: id) else { return nil }
        return safeIndex(after: current)
    }
    
    func element(before id: ID?) -> Element? {
        guard let beforeIndex = safeIndex(before: id) else { return nil }
        return self[beforeIndex]
    }
    
    func element(after id: ID?) -> Element? {
        guard let afterIndex = safeIndex(after: id) else { return nil }
        return self[afterIndex]
    }

    
    func count(before id: ID?) -> Int {
        guard let currentIndex = index(id: id) else { return 0 }
        return count(before: currentIndex)
    }
    
    func count(after id: ID?) -> Int {
        guard let currentIndex = index(id: id) else { return 0 }
        return count(after: currentIndex)
    }
}

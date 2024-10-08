import Foundation
import IdentifiedCollections

public protocol ModifiedDateMeasurable {
    var dateModified: Date? { get set }
}

extension IdentifiedArray where Element: ModifiedDateMeasurable {
    public var mostRecentlyModified: Element? {
        elements.sorted(using: KeyPathComparator(\.dateModified, order: .reverse)).first
    }
}

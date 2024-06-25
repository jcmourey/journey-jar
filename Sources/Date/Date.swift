import Foundation

extension Date {
    public var year: Int {
        Calendar.current.component(.year, from: self)
    }
}

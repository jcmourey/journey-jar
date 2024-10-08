import Foundation

// pointfree
import Dependencies

// dependencies
import ErrorClient

public func warning(_ label: String, file: String = #fileID, function: String = #function, line: UInt = #line) -> String  {
    @Dependency(\.errorService) var errorService
    return errorService.warning(label: label, file: file, function: function, line: line)
}

public extension Error {
    func callAsFunction(_ label: String? = nil, file: String = #fileID, function: String = #function, line: UInt = #line) -> String {
        @Dependency(\.errorService) var errorService
        return errorService.detail(error: self, label: label, file: file, function: function, line: line)
    }
}

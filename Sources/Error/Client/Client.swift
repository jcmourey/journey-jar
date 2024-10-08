import Foundation

// pointfree
import DependenciesMacros

@DependencyClient
public struct ErrorClient: Sendable {
    public var detail: @Sendable (
        _ error: any Error,
        _ label: String?,
        _ file: String,
        _ function: String,
        _ line: UInt
    ) -> String = { _,_,_,_,_ in "unimplemented error" }
    
    public var warning: @Sendable (
        _ label: String,
        _ file: String,
        _ function: String,
        _ line: UInt
    ) -> String = { _,_,_,_ in "unimplemented warning" }
}

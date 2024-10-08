// pointfree
import Dependencies

extension DependencyValues {
    public var errorService: ErrorClient {
        get { self[ErrorClient.self] }
        set { self[ErrorClient.self] = newValue }
    }
}

extension ErrorClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self()
}

extension ErrorClient {
    public static let noop = Self(
        detail: { _,_,_,_,_ in "preview error" },
        warning: { _,_,_,_ in "preview warning" }
    )
}


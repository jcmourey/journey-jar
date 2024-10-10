// pointfree
import IdentifiedCollections
import Dependencies

// models
import TeamModel

extension DependencyValues {
    public var teamDatabaseClient: TeamDatabaseClient {
        get { self[TeamDatabaseClient.self] }
        set { self[TeamDatabaseClient.self] = newValue }
    }
}

extension TeamDatabaseClient: TestDependencyKey {
    public static let previewValue: Self = .staticMock
    public static let testValue = Self()
}

extension TeamDatabaseClient {
    public static var noop: Self {
        Self(
            createTeamIfNotExists: { _ in },
            fetch: { [] },
            listen: {  .finished() },
            save: { _ in },
            delete: { _ in }
        )
    }
    public static var staticMock: Self {
        return Self(
            createTeamIfNotExists: { _ in },
            fetch: { [] },
            listen: {
                AsyncThrowingStream { continuation in
                    continuation.yield(Team.mockTeams(numberOfTeams: 1))
                    continuation.finish()
                }
            },
            save: { _ in },
            delete: { _ in }
        )
    }
    public static var streamingMock: Self {
        return Self(
            createTeamIfNotExists: { _ in },
            fetch: { [] },
            listen: { streamElements(from: Team.mockTeamsList) },
            save: { _ in },
            delete: { _ in }
        )
    }
}

// Function to create an AsyncThrowingStream from an array
func streamElements<Element: Sendable>(from array: [Element]) -> AsyncThrowingStream<Element, Error> {
    AsyncThrowingStream { continuation in
        Task {
            for element in array {
                continuation.yield(element) // Yield each element from the array
                try await Task.sleep(nanoseconds: 2_000_000_000) // Sleep for 2 seconds
            }
            continuation.finish() // Finish when done
        }
    }
}

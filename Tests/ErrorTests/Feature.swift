import Testing

// pointfree
import ComposableArchitecture

@testable import ErrorFeature

@MainActor
@Suite("ErrorFeature")
struct ErrorFeatureTests {
    @Test
    func noError() async {
        let store = TestStore(initialState: ErrorFeature.State()) { ErrorFeature() }
        
        #expect(store.state.errorDescription == nil)
    }
}


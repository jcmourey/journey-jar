import Testing

// pointfree
import ComposableArchitecture

@testable import UserFeature

@MainActor
@Suite("SignIn")
struct SignInTests {
    @Test
    func googleSuccess() async {
        let store = TestStore(initialState: SignIn.State()) {
            SignIn()
        } withDependencies: {
            $0.authenticationClient.signInWithGoogle = { }
        }
        await store.send(.signInWithGoogleButtonTapped)
    }
    
    enum TestError: Int, Error {
        case failure = 1
    }
    
    @Test
    func googleFailure() async {
        let error = TestError.failure
        
        let store = TestStore(initialState: SignIn.State()) {
            SignIn()
        } withDependencies: {
            $0.authenticationClient.signInWithGoogle = {
                throw error
            }
        }
        
        store.exhaustivity = .off
        await store.send(.signInWithGoogleButtonTapped)
        await store.receive(\.error.detail) {
            let errorDescription = try #require($0.error.errorDescription)
            #expect(errorDescription.contains("TestError error 1"))
        }
    }
}

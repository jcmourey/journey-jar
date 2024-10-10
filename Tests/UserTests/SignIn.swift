import Testing

// pointfree
import ComposableArchitecture

@testable import UserFeature

@Suite("SignIn")
struct SignInTests {
    @Test
    func googleSuccess() async {
        let store = await TestStore(initialState: SignIn.State()) {
            SignIn()
        } withDependencies: {
            $0.authenticationClient.signInWithGoogle = { }
        }
        await store.send(.signInWithGoogleButtonTapped)
    }
    
    enum TestError: Error {
        case failure
    }
    
    @Test
    func googleFailure() async {
        let error = TestError.failure
        let errorMsg = "got an error"
        
        let store = await TestStore(initialState: SignIn.State()) {
            SignIn()
        } withDependencies: {
            $0.authenticationClient.signInWithGoogle = {
                throw error
            }
            $0.errorClient.detail = { @Sendable _,_,_,_,_ in errorMsg }
        }
        await store.send(.signInWithGoogleButtonTapped)
        await store.receive(\.error.detail) {
            $0.error = .init(errorDescription: errorMsg)
        }
    }
}

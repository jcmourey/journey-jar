import Testing

@Test
func testSignInWithGoogle() async {
    let store = await TestStore(initialState: SignIn.State()) {
        SignIn()
    }
    await store.send(.signInWithGoogleButtonTapped)
}


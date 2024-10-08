import SwiftUI
import AuthenticationServices

// pointfree
import ComposableArchitecture

// google
import GoogleSignInSwift

// dependencies
import AuthenticationClient
import UserDatabaseClient

// features
import ErrorFeature

// models
import UserModel

@Reducer
public struct SignIn: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var error = ErrorFeature.State()
        public init() {}
    }
    
    public enum Action {
        case appleSignInOnCompletion(result: Result<ASAuthorization, any Error>)
        case appleSignInOnRequest(request: ASAuthorizationAppleIDRequest)
        case signInWithGoogleButtonTapped
        case error(ErrorFeature.Action)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.authenticationClient) var auth

    public init() {}
   
    public var body: some ReducerOf<Self> {
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case let .appleSignInOnCompletion(result):
                return .run { _ in
                    try await auth.signInWithApple(result)
                    await dismiss()
                } catch: { error, send in
                    await send(.error(.detail(error("signInWithApple"))))
                }
                
            case let .appleSignInOnRequest(request):
                return .run { _ in
                    await auth.prepareAppleRequest(request)
                }
                
            case .signInWithGoogleButtonTapped:
                return .run { _ in
                    try await auth.signInWithGoogle()
                    await dismiss()
                } catch: { error, send in
                    await send(.error(.detail(error("signInWithGoogle"))))
                }
                
            case .error:
                return .none
            }
        }
    }
}

public struct SignInView: View {
    let store: StoreOf<SignIn>
    @Environment(\.colorScheme) var colorScheme
    
    public init(store: StoreOf<SignIn>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            // MARK: - Apple
            SignInWithAppleButton(.continue) { request in
                store.send(.appleSignInOnRequest(request: request))
            } onCompletion: { result in
                store.send(.appleSignInOnCompletion(result: result))
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(width: 280, height: 45, alignment: .center)
            
            // MARK: - Google
            GoogleSignInButton(
                scheme: colorScheme == .light ? .light: .dark,
                style: .wide
            ) {
                store.send(.signInWithGoogleButtonTapped)
            }
            .frame(width: 280, height: 45, alignment: .center)
            
            // MARK: - Error
            ErrorView(store: store.scope(state: \.error, action: \.error))
        }
        .padding()
    }
}

#Preview {
    SignInView(
        store: Store(
            initialState: .init()
        ) {
            SignIn()
        }
    )
}

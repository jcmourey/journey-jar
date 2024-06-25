import UIKit
import SwiftUI
import ComposableArchitecture
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import UserLogin

@Reducer
public struct FirebaseSignIn {
    @ObservableState
    public struct State: Equatable {
        @Shared(.userLogin) var user
        
        public init() {}
    }
    
    public enum Action {
        case anonymousSignInDone
        case signInDone
        case cancelButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .anonymousSignInDone, .signInDone:
                update(user: &state.user)
                return .run { _ in await dismiss() }
                
            case .cancelButtonTapped:
                // if no provider chosen, sign in anonymously as a guest user so can use Firebase anyway
                if Auth.auth().currentUser == nil {
                    return .run { send in
                        do {
                            try await Auth.auth().signInAnonymously()
                            await send(.anonymousSignInDone)
                        } catch {
                            print("Anonymous sign in failed: \(error)")
                        }
                    }
                } else {
                    return .run { _ in await dismiss() }
                }
            }
        }
    }
}

public struct FirebaseSignInView: View {
    let store: StoreOf<FirebaseSignIn>
    
    public init(store: StoreOf<FirebaseSignIn>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            FirebaseAuthView {
                store.send(.signInDone)
            } cancel: {
                store.send(.cancelButtonTapped)
            }
            .presentationDetents([.fraction(0.33)])
        }
    }
}

struct FirebaseAuthView: UIViewControllerRepresentable {
    let done: () -> Void
    let cancel: () -> Void
        
    class Coordinator: NSObject, FUIAuthDelegate {
        let done: () -> Void
        let cancel: () -> Void
        var presentingViewController: UIViewController?
        
        init(presentingViewController: UIViewController?, done: @escaping () -> Void, cancel: @escaping () -> Void) {
            self.presentingViewController = presentingViewController
            self.done = done
            self.cancel = cancel
        }
        
        private func upgradeAnonymous(mergeConflict error:  NSError) {
            // Merge conflict error, discard the anonymous user and login as the existing
            // non-anonymous user.
            guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
                print("Received merge conflict error without auth credential!")
                return
            }
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error {
                    print("Failed to re-login: \(error)")
                }
                // Handle successful login
                self.done()
            }
        }

        func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: (any Error)?) {
            switch (authDataResult, (error as NSError?)) {
                
            case let (.none, .some(error)) where error.code == FUIAuthErrorCode.userCancelledSignIn.rawValue:
                // user hit cancel button
                cancel()
                
            case let (.none, .some(error)) where error.code == FUIAuthErrorCode.mergeConflict.rawValue:
                // anonymous signed in with credential
                upgradeAnonymous(mergeConflict: error)
                
            case let (_, .some(error)):
                // Some other error happened.
                print("Failed to log in: \(error)")
                // Handle successful login
                done()
                
            case (.none, .none):
                print("No error but no authDataResult either: shouldn't happen")
                done()
                
            case (.some(_), .none):
                // Handle successful login
                print("Successful login")
                done()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentingViewController: FUIAuth.defaultAuthUI()?.authViewController(), done: done, cancel: cancel)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        
        guard let authUI = FUIAuth.defaultAuthUI() else {
            print("unable to get FUIAuth.defaultAuthUI() instance")
            return UINavigationController()
        }
        
        authUI.delegate = context.coordinator
        
        let providers: [FUIAuthProvider] = [
            FUIOAuth.appleAuthProvider(),
            FUIGoogleAuth(authUI: authUI),
//            FUIAnonymousAuth(),
            // FUIFacebookAuth(),
            // FUIPhoneAuth(authUI: authUI!),
//            FUIOAuth.twitterAuthProvider(),
//            FUIOAuth.githubAuthProvider(),
//            FUIOAuth.microsoftAuthProvider(),
//            FUIOAuth.yahooAuthProvider(),
        ]
        
        authUI.providers = providers
        authUI.shouldAutoUpgradeAnonymousUsers = true

        return authUI.authViewController()
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}

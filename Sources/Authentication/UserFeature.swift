import SwiftUI
import ComposableArchitecture
import FirebaseAuthUI
import Styleguide
import UserLogin

@Reducer
public struct UserFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case signIn(FirebaseSignIn)
        case editName(EditName)
    }
    @ObservableState
    public struct State: Equatable {
        @Shared(.userLogin) var user
        @Presents var destination: Destination.State?
        
        public init() {}
    }
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case signInButtonTapped
        case cancelEditNameButtonTapped
        case doneEditingNameButtonTapped
        case editDisplayNameButtonTapped
        case signOutButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
                
            case .signInButtonTapped:
                state.destination = .signIn(FirebaseSignIn.State())
                return .none
                
            case .cancelEditNameButtonTapped:
                state.destination = nil
                return .none
                
            case .doneEditingNameButtonTapped:
                guard let newName = state.destination?.editName?.name else { return .none }
                state.user?.name = newName
                state.destination = nil
                return .none
                
            case .editDisplayNameButtonTapped:
                state.destination = .editName(EditName.State(name: state.user?.displayName ?? ""))
                return .none
                
            case .signOutButtonTapped:
                do {
                    try FUIAuth.defaultAuthUI()?.signOut()
                    Auth.auth().signInAnonymously()
                    update(user: &state.user)
                } catch {
                    print("error signing out: \(error)")
                }
                return .run { _ in await dismiss() }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct UserView: View {
    @Perception.Bindable public var store: StoreOf<UserFeature>
    
    public init(store: StoreOf<UserFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            List {
                if let user = store.user, !user.isAnonymous {
                    signedInUserInfoView(user: user)
                } else {
                    guestUserView(user: store.user)
                }
            }
            .navigationTitle("User profile")
            .sheet(item: $store.scope(state: \.destination?.editName, action: \.destination.editName)) { editNameStore in
                NavigationStack {
                    EditNameView(store: editNameStore)
                        .navigationTitle("Edit user name")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    store.send(.cancelEditNameButtonTapped)
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    store.send(.doneEditingNameButtonTapped)
                                }
                            }
                        }
                }
            }
            .sheet(item: $store.scope(state: \.destination?.signIn, action: \.destination.signIn)) { signInStore in
                FirebaseSignInView(store: signInStore)
            }
        }
    }
    
    @ViewBuilder
    func guestUserView(user: UserLogin?) -> some View {
        if let displayName = user?.displayName {
            Text(displayName)
                .navTitleStyle()
        }
        
        Text("Guest user")
            .font(.headline)
        
        if let uid = user?.uid {
            KeyValuePair("guest uid", uid)
        }
        
        Section {
            Button {
                store.send(.signInButtonTapped)
            } label: {
                Text("Sign In")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    func signedInUserInfoView(user: UserLogin) -> some View {
        HStack {
            ProfileImage(user: user)
                .frame(width: 60)
            
            Text(user.displayName)
                .navTitleStyle()
        }
        
        Section("User Info") {
            KeyValuePair("uid", user.uid)
            //                KeyValuePair("is Anonymous", user.isAnonymous)
            //                KeyValuePair("is Email Verified", user.isEmailVerified)
            //                KeyValuePair("creation Date", user.creationDate)
            //                KeyValuePair("last Sign In Date", user.lastSignInDate)
            KeyValuePair("signin provider", user.signInProvider)
            //                KeyValuePair("signin name", user.signInName)
            KeyValuePair("email", user.email)
            //                KeyValuePair("phone Number", user.phoneNumber)
            //                KeyValuePair("tenant ID", user.tenantID)
        }
        
        Section {
            Button(role: .destructive) {
                store.send(.signOutButtonTapped)
            } label: {
                Text("Sign Out")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

public struct ProfileImage: View {
    let user: UserLogin?
    
    public init(user: UserLogin?) {
        self.user = user
    }
    
    public var body: some View {
        if let userPhotoURL = user?.photoURL {
            Thumbnail(url: userPhotoURL)

        } else {
            Image(systemName: defaultUserSystemImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }

    var defaultUserSystemImage: String {
        switch user {
        case .none: return "person"
        case let .some(user) where user.isAnonymous: return "person.fill"
        default: return "person.fill.checkmark"
        }
    }
}
//
//#Preview {
//    let store = Store(initialState: UserFeature.State(user: .Shared(UserInfo.mock))) {
//        UserFeature()
//    }
//    return UserView(store: store)
//}

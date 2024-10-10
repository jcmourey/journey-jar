import SwiftUI

// pointfree
import ComposableArchitecture

// dependencies
import AuthenticationClient
import UserDatabaseClient

// models
import UserModel

// features
import ErrorFeature

// UI elements
import Styleguide

@Reducer
public struct UserDetail: Sendable {
    @Reducer
    public enum Destination {
        case editName(EditName)
    }
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var error = ErrorFeature.State()
        var user: UserModel
        
        public init(user: UserModel) {
            self.user = user
        }
    }
    public enum Action {
        case onAppear
        case userUpdated(UserModel)
        case error(ErrorFeature.Action)
        case destination(PresentationAction<Destination.Action>)
        case cancelEditNameButtonTapped
        case doneEditingNameButtonTapped
        case editDisplayNameButtonTapped
        case signOutButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.authenticationClient) var auth

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        Reduce { state, action in
            switch action {
        
            case .onAppear:
                return .run { send in
                    // awaits for changes in user
                    for await user in await auth.listen() {
                        // update user in state or dismiss view if goes to nil
                        if let user {
                            await send(.userUpdated(user))
                        } else {
                            await dismiss()
                        }
                    }
                }
                
            case let .userUpdated(user):
                state.user = user
                return .none
                
            case .error:
                return .none
                
            case .destination:
                return .none
                
            case .cancelEditNameButtonTapped:
                state.destination = nil
                return .none
                
            case .doneEditingNameButtonTapped:
                guard let newName = state.destination?.editName?.name else {
                    return .none
                }
                state.destination = nil
                return .run { send in
                    try await auth.changeUserName(newName: newName)
                } catch: { error, send in
                    await send(.error(.detail(error, "request user name change", #fileID, #function, #line)))
                }
                
            case .editDisplayNameButtonTapped:
                state.destination = .editName(EditName.State(name: state.user.name ?? ""))
                return .none
                
            case .signOutButtonTapped:
                return .run { send in
                    try await auth.signOut()
                    await dismiss()
                } catch: { error, send in
                    await send(.error(.detail(error, "signOut", #fileID, #function, #line)))
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
extension UserDetail.Destination.State: Equatable {}

public struct UserDetailView: View {
    @Bindable var store: StoreOf<UserDetail>
    
    public init(store: StoreOf<UserDetail>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            userInfo(user: store.user)
        }
        .navigationTitle(store.user.name ?? "User Info")
        .animation(.easeInOut, value: store.user)
        .toolbar {
            Button {
                store.send(.editDisplayNameButtonTapped)
            } label: {
                Text("Edit name")
            }
        }
        .sheet(item: $store.scope(state: \.destination?.editName, action: \.destination.editName)) { editNameStore in
            editName(editStore: editNameStore)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    @ViewBuilder
    private func editName(editStore: StoreOf<EditName>) -> some View {
        NavigationStack {
            EditNameView(store: editStore)
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
    
    @ViewBuilder
    private func userInfo(user: UserModel) -> some View {
        ProfileImage(authState: user.authState, photoURL: user.photoURL)
            .frame(width: 120, alignment: .leading)
        
        Section("User Info") {
            KeyValuePair("signin provider", user.provider)
            KeyContentPair("uid") {
                Text(user.uid.rawValue)
                    .font(.caption)
            }
            KeyValuePair("email", user.email)
        }
        
        Button(role: .destructive) {
            store.send(.signOutButtonTapped)
        } label: {
            Text("Sign Out")
        }
        .frame(maxWidth: .infinity, alignment: .center)
   
        ErrorView(store: store.scope(state: \.error, action: \.error))
    }
}

#Preview("User 0") {
    NavigationStack {
        UserDetailView(store: Store(initialState: .init(user: UserModel.mockUsers[0])) { UserDetail() })
    }
}

#Preview("User 1") {
    NavigationStack {
        UserDetailView(store: Store(initialState: .init(user: UserModel.mockUsers[1])) { UserDetail() })
    }
}

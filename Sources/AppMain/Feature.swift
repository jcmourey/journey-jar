// system
import SwiftUI

// pointfree
import ComposableArchitecture

// dependencies
import AuthenticationClient

// models
import TVShowModel
import UserModel

// features
import TVShowFeature
import UserFeature
import TeamFeature
import ErrorFeature

// utilities
import Log


@Reducer
public struct AppFeature: Sendable {
    @Reducer
    public enum Path {
        case profile(UserDetail)
        case detail(TVShowDetail)
        case team(TeamList)
    }
    @Reducer
    public enum Destination {
        case signIn(SignIn)
    }
    @ObservableState
    public struct State: Equatable {
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?
        var tvShowList = TVShowList.State()
        var user: UserModel?
        var error = ErrorFeature.State()
        
        public init() {}
    }
    public enum Action {
        case error(ErrorFeature.Action)
        case teamsButtonTapped
        case userUpdated(UserModel?)
        case onSignInDisappear
        case skipSignInButtonTapped
        case onAppear
        case signIn
        case onOpenURL(URL)
        case userButtonTapped
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
        case tvShowList(TVShowList.Action)
    }
    
    @Dependency(\.authenticationClient) var auth
    @Dependency(\.userDatabaseClient) var userDb
    @Dependency(\.teamDatabaseClient) var teamDb

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.tvShowList, action: \.tvShowList) {
            TVShowList()
        }
        
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case .teamsButtonTapped:
                state.path.append(.team(TeamList.State()))
                return .none
                
            case let .userUpdated(user):
                state.user = user
                logger.debug("userUpdated: \(String(describing: user)), current auth user: \(String(describing: state.user))")
                if user == nil {
                    state.destination = .signIn(SignIn.State())
                }
                return .run { send in
                    do {
                        if let user {
                            try await userDb.save(user: user)
                            try await teamDb.createTeamIfNotExists(user)
                        }
                    } catch {
                        await send(.error(.detail(error("save user"))))
                    }
                    await send(.tvShowList(.onUserUpdated))
                }
                
            case .skipSignInButtonTapped:
                state.destination = nil
                return .none
                
            case .onSignInDisappear:
                if state.user == nil {
                    return .run { _ in try await auth.signInAsGuest() }
                } else {
                    return .none
                }
                
            case .onAppear:
                return .run { send in
                    // awaits for changes in user
                    for await user in await auth.listen() {
                        logger.debug("received user: \(user?.description ?? "nil")")
                        await send(.userUpdated(user))
                    }
                }
                
            case let .onOpenURL(url):
                return .run { _ in
                    await auth.handleGoogleURL(url)
                }
           
            case let .tvShowList(.detailButtonTapped(tvShow)):
                state.path.append(.detail(TVShowDetail.State(tvShow: tvShow)))
                return .none
                                    
            case .signIn:
                state.destination = .signIn(SignIn.State())
                return .none
                
            case .userButtonTapped:
                if let user = state.user, !user.isAnonymous {
                    state.path.append(.profile(UserDetail.State(user: user)))
                } else {
                    state.destination = .signIn(SignIn.State())
                }
                return .none
                    
            case .tvShowList:
                return .none
                
            case .path:
                return .none
                    
            case .destination:
                return .none
                
            case .error:
                return .none
           }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}
extension AppFeature.Path.State: Equatable {}
extension AppFeature.Destination.State: Equatable {}

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            TVShowListView(store: store.scope(state: \.tvShowList, action: \.tvShowList))
        } destination: { store in
            switch store.case {
            case let .profile(profileStore):
                UserDetailView(store: profileStore)
                
            case let .detail(detailStore):
                TVShowDetailView(store: detailStore)
                
            case let .team(teamListStore):
                TeamListView(store: teamListStore)
            }
        }
        .toolbar {
            Button {
                store.send(.teamsButtonTapped)
            } label: {
                Label("Teams", systemImage: "person.2.fill")
            }
            
            Button {
                store.send(.userButtonTapped)
            } label: {
                ProfileLabel(authState: store.user.authState, photoURL: store.user?.photoURL)
                    .animation(.easeInOut, value: store.user)
            }
        }
        .sheet(item: $store.scope(state: \.destination?.signIn, action: \.destination.signIn)) { signInStore in
            signIn(signInStore: signInStore)
        }
        .overlay(alignment: .bottom) {
            prominentSignInButton(authState: store.user.authState)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onOpenURL { url in
            store.send(.onOpenURL(url))
        }
    }
    
    @ViewBuilder
    private func signIn(signInStore: StoreOf<SignIn>) -> some View {
        NavigationStack {
            SignInView(store: signInStore)
                .navigationTitle("Sign in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // MARK: - Guest
                    // Hide `Skip` button if user is signed in as guest.
                    if case .signedOut = store.user.authState {
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                store.send(.skipSignInButtonTapped)
                            } label: {
                                Text("Skip")
                                    .font(.body.bold())
                                    .frame(width: 280, height: 45, alignment: .center)
                            }
                        }
                    }
                }
                .onDisappear {
                    store.send(.onSignInDisappear)
                }
        }
        .presentationDetents([.fraction(0.33)])
    }
    
    @ViewBuilder
    private func prominentSignInButton(authState: AuthState) -> some View {
        Button {
            store.send(.signIn)
        } label: {
            VStack(alignment: .center) {
                switch authState {
                case .guest:
                    Text("Guest mode")
                    Text("Sign in to enable collaborative features")
                case .signedOut:
                    Text("Sign in to view your content")
                case .signedIn:
                    EmptyView()
                }
            }
            .padding(8)
        }
        .buttonStyle(.borderedProminent)
        .opacity(authState == .signedIn ? 0 : 1)
        .animation(.snappy, value: authState)
    }
}

#Preview {    
    AppView(store: Store(initialState: .init()) { AppFeature() })
}

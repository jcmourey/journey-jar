import ComposableArchitecture
import SwiftUI
import TVShow
import Authentication
import PersistenceKeys

@Reducer
struct AppFeature: Reducer {
    @Reducer(state: .equatable)
    enum Path {
        case profile(UserFeature)
        case detail(TVShowDetail)
    }
    @Reducer(state: .equatable)
    enum Destination {
        case signIn(FirebaseSignIn)
    }
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?
        var tvShowList = TVShowList.State()
        @Shared(.user) var user
    }
    
    enum Action {
        case onAppear
        case userButtonTapped
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
        case tvShowList(TVShowList.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.tvShowList, action: \.tvShowList) {
            TVShowList()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // if first time running the app, no user in storage, offer chance to sign in with a provider
                if state.user == nil {
                    state.destination = .signIn(FirebaseSignIn.State())
                }
                return .none
                
            case .userButtonTapped:
                if let user = state.user {
                    state.path.append(.profile(UserFeature.State()))
                } else {
                    state.destination = .signIn(FirebaseSignIn.State())
                }
                return .none
                
            case .path:
                return .none
                    
            case .destination:
                return .none
                    
            case .tvShowList:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

struct AppView: View {
    @Perception.Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                TVShowListView(store: store.scope(state: \.tvShowList, action: \.tvShowList))
            } destination: { store in
                switch store.case {
                case let .profile(profileStore):
                    UserView(store: profileStore)
            
                case let .detail(detailStore):
                    TVShowDetailView(store: detailStore)
                }
            }
            .toolbar {
                Button {
                    store.send(.userButtonTapped)
                } label: {
                    ProfileImage(user: store.user)
                        .frame(width: 20)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .sheet(item: $store.scope(state: \.destination?.signIn, action: \.destination.signIn)) { signInStore in
                FirebaseSignInView(store: signInStore)
            }
        }
    }
}

#Preview {
    @Shared(.tvShows) var tvShows = .mock
    
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    return AppView(store: store)
}

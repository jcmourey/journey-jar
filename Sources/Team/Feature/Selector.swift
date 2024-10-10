import SwiftUI

// pointfree
import ComposableArchitecture
import IdentifiedCollections

// dependencies
import AuthenticationClient
import TeamDatabaseClient

// models
import UserModel
import TeamModel

// features
import ErrorFeature

@Reducer
public struct TeamSelector: Sendable {
    @ObservableState
    public struct State: Equatable {
        var teamList = TeamList.State()
        var error = ErrorFeature.State()
        public var selectedTeam: Team?
        
        public init() {}
        
        var isSelectedTeamValid: Bool {
            guard let selectedTeam else { return false }
            return teamList.teams.contains(selectedTeam)
        }
    }
    
    public init() {}
        
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case error(ErrorFeature.Action)
        case teamList(TeamList.Action)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.teamList, action: \.teamList) { TeamList() }
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case .error:
                return .none
                
            case .binding:
                return .none
                
            case let .teamList(.teamsUpdated(teams)):
                if !state.isSelectedTeamValid {
                    state.selectedTeam = teams.mostRecentlyModified
                }
                return .none
                
            case .teamList:
                return .none
            }
        }
    }
}

public struct TeamSelectorView: View {
    @Bindable var store: StoreOf<TeamSelector>
    
    public init(store: StoreOf<TeamSelector>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Picker("", selection: $store.selectedTeam) {
                ForEach(store.teamList.teams) { team in
                    teamView(team: team)
                        .tag(team as Team?)
                }
            }
            
            ErrorView(store: store.scope(state: \.error, action: \.error))
        }
        .onAppear {
            store.send(.teamList(.onAppear))
        }
    }
    
    @ViewBuilder
    func teamView(team: Team) -> some View {
        Text(team.name)
            .font(.caption)
            .padding()
            .overlay(
                Capsule()
                    .foregroundColor(.accentColor)
            )
    }
}

#Preview {
    TeamSelectorView(store: Store(initialState: .init()) { TeamSelector() })
}

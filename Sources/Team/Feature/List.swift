import SwiftUI

// pointfree
import ComposableArchitecture
import IdentifiedCollections

// dependencies
import TeamDatabaseClient
import AuthenticationClient
import ErrorClient

// models
import TeamModel

@Reducer
public struct TeamList: Sendable {
    @ObservableState
    public struct State: Equatable {
        public var teams: IdentifiedArrayOf<Team>
        var error = ErrorFeature.State()
        
        public init(teams: IdentifiedArrayOf<Team> = []) {
            self.teams = teams
        }
    }
    public enum Action {
        case error(ErrorFeature.Action)
        case teamsUpdated(IdentifiedArrayOf<Team>)
        case onAppear
    }
    
    @Dependency(\.teamDatabaseClient) var teamDb
    
    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case let .teamsUpdated(teams):
                state.teams = teams
                return .none
                
            case .onAppear:
                return .run { send in
                    let stream = try await self.teamDb.listen()
                    for try await teams in stream {
                        await send(.teamsUpdated(teams))
                    }
                } catch: { error, send in
                    await send(.error(.detail(error("team listen"))))
                }
                
            case .error:
                return .none
            }
        }
    }
}

public struct TeamListView: View {
    @Bindable var store: StoreOf<TeamList>
    
    public init(store: StoreOf<TeamList>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ErrorView(store: store.scope(state: \.error, action: \.error))
 
                ForEach(store.teams) {
                    TeamView(team: $0)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct TeamView: View {
    let team: Team
    
    var memberList: String {
        team
            .memberDetails
            .map { $0.name ?? "<unnamed>" }
            .joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(team.name)
            Text(memberList)
                .font(.caption)
        }
    }
}

#Preview("Single Team") {
    TeamView(team: Team.mockTeams[0])
}


#Preview("Static Team List") {
    TeamListView(
        store: Store(
            initialState: .init(teams: Team.mockTeams)
        ) {
            TeamList()
        } withDependencies: {
            $0.teamDatabaseClient = .noop
        }
    )
}

#Preview("Streaming Team List") {
    TeamListView(
        store: Store(
            initialState: .init()
        ) {
            TeamList()
        } withDependencies: {
            $0.teamDatabaseClient = .streamingMock
        }
    )
}

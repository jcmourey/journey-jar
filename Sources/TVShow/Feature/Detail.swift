import SwiftUI

// pointfree
import ComposableArchitecture

// features
import ErrorFeature

// UI elements
import Rating
import Styleguide

// models
import TVShowModel
import TeamModel

@Reducer
public struct TVShowDetail: Sendable {
    @Reducer
    public enum Destination {
        case largePoster(LargePoster)
        case alert(AlertState<Alert>)
        case edit(TVShowForm)
        @CasePathable
        public enum Alert: Sendable {
            case acknowledgeDeletedButtonTapped
            case confirmDeleteButtonTapped
        }
    }
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var tvShow: TVShow
        var teams: IdentifiedArrayOf<Team> = []
        var error = ErrorFeature.State()

        var tvShowTeam: Team? {
            guard let teamId = tvShow.teamId else { return nil }
            return teams[id: teamId]
        }
        
        public init(tvShow: TVShow) {
            self.tvShow = tvShow
        }
    }
    public enum Action {
        case teamsUpdated(IdentifiedArrayOf<Team>)
        case onAppear
        case error(ErrorFeature.Action)
        case posterTapped
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped
        case cancelEditButtonTapped
        case doneEditingButtonTapped
        case editButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now
    @Dependency(\.tvShowDatabaseClient) var tvShowDb
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
                    let stream = try await teamDb.listen()
                    for try await teams in stream {
                        await send(.teamsUpdated(teams))
                    }
                } catch: { error, send in
                    await send(.error(.detail(error("team listen"))))
                }
                
            case .posterTapped:
                if let posterURL = state.tvShow.tvdbInfo?.imageURL {
                    state.destination = .largePoster(LargePoster.State(posterURL: posterURL))
                }
                return .none
                
            case .destination(.presented(.alert(.acknowledgeDeletedButtonTapped))):
                return .run { _ in await dismiss() }
                             
            case .destination(.presented(.alert(.confirmDeleteButtonTapped))):
                return .run { [tvShow = state.tvShow] _ in
                    try await tvShowDb.delete(tvShow)
                    await dismiss()
                } catch: { error, send in
                    await send(.error(.detail(error("delete"))))
                }
                
            case .destination:
                return .none
                
            case .deleteButtonTapped:
                state.destination = .alert(.delete)
                return .none
            
            case .cancelEditButtonTapped:
                state.destination = nil
                return .none

            case .doneEditingButtonTapped:
                guard let editedTVShow = state.destination?.edit?.tvShow else { return .none }
                state.tvShow = editedTVShow
                if let tvdbName = state.tvShow.tvdbInfo?.name {
                    state.tvShow.title = tvdbName
                }
                state.tvShow.dateModified = now
                state.destination = nil
                return .run { [tvShow = state.tvShow] _ in
                    try await self.tvShowDb.save(tvShow)
                } catch: { error, send in
                    await send(.error(.detail(error("update"))))
                }
            
            case .editButtonTapped:
                state.destination = .edit(TVShowForm.State(tvShow: state.tvShow, focus: nil))
                return .none
                
            case .error:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
extension TVShowDetail.Destination.State: Equatable {}

public extension AlertState where Action == TVShowDetail.Destination.Alert {
    static let delete = Self {
        TextState("Delete?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeleteButtonTapped) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this TV show?")
    }
    
    static let deleted = Self {
        TextState("Deleted")
    } actions: {
        ButtonState(action: .acknowledgeDeletedButtonTapped) {
            TextState("I understand")
        }
    } message: {
        TextState("This TV show was deleted on the server")
    }
}

public struct TVShowDetailView: View {
    @Bindable var store: StoreOf<TVShowDetail>
    
    public init(store: StoreOf<TVShowDetail>) {
        self.store = store
    }
    
    public var body: some View {
        Form {
            VStack {
                Text(store.tvShow.title)
                    .navTitleStyle()
                
                poster
            }
            
            info
            deleteButton
            ErrorView(store: store.scope(state: \.error, action: \.error))
            
            tvdbInfo
            
        }
        .toolbar {
            Button("Edit") {
                store.send(.editButtonTapped)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { editStore in
            TVShowFormSheet(detailStore: store, editStore: editStore)
        }
        .sheet(item: $store.scope(state: \.destination?.largePoster, action: \.destination.largePoster)) { largePosterStore in
            LargePosterView(store: largePosterStore)
        }
    }
    
    struct TVShowFormSheet: View {
        let detailStore: StoreOf<TVShowDetail>
        let editStore: StoreOf<TVShowForm>
        
        var body: some View {
            NavigationStack {
                TVShowFormView(store: editStore)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                detailStore.send(.cancelEditButtonTapped)
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                detailStore.send(.doneEditingButtonTapped)
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder var tvdbInfo: some View {
        if let info = store.tvShow.tvdbInfo {
            Section("TVDB Info") {
                TVDBInfoDetail(info: info)
            }
        }
    }
    
    @ViewBuilder var deleteButton: some View {
        Section {
            Button("Delete", role: .destructive) {
                store.send(.deleteButtonTapped)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder var info: some View {
        Section("TVShow Info") {
            KeyContentPair("Interest") {
                RatingView(level: store.tvShow.interest)
            }
            KeyValuePair("Team", store.tvShowTeam?.name)
            KeyValuePair("Progress", store.tvShow.progress)
            
            KeyContentPair("Recommendation", axis: .horizontal) {
                VStack(alignment: .trailing) {
                    ForEach(store.tvShow.recommendations) { recommendation in
                        Text(recommendation.name)
                    }
                }
            }
        }
    }
    
    @ViewBuilder var poster: some View {
        if let info = store.tvShow.tvdbInfo {
            HStack(alignment: .top) {
                Button {
                    store.send(.posterTapped)
                } label: {
                    Thumbnail(
                        url: info.imageURL,
                        lowResolutionURL: info.thumbnailURL,
                        size: Layout.posterSize,
                        placeholderImageName: "tvShowPlaceholder",
                        bundle: .module,
                        altText: store.tvShow.title,
                        showError: true
                    )
                    .frame(alignment: .leading)
                }
                .disabled(info.imageURL == nil)
                
                TVDBInfoSidebar(info: info, fontSize: 14)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}


#Preview {
    NavigationStack {
        let store = Store(initialState: TVShowDetail.State(tvShow: .mock.mock2)) {
            TVShowDetail()
        }
        TVShowDetailView(store: store)
    }
}

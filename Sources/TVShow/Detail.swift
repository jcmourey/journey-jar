import ComposableArchitecture
import SwiftUI
import Combine

@Reducer
struct TVShowDetail: Reducer {
    @Reducer(state: .equatable)
    enum Destination {
        case largePoster(LargePoster)
        case alert(AlertState<Alert>)
        case edit(TVShowForm)
        @CasePathable
        enum Alert {
            case acknowledgeDeletedButtonTapped
            case confirmDeleteButtonTapped
        }
    }
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var tvShow: TVShow
    }
    enum Action {
        case posterTapped
        case tvShowsUpdated(IdentifiedArrayOf<TVShow>)
        case onAppear
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped
        case cancelEditButtonTapped
        case doneEditingButtonTapped
        case editButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .posterTapped:
                if let posterURL = state.tvShow.tvdbInfo?.imageURL {
                    state.destination = .largePoster(LargePoster.State(posterURL: posterURL))
                }
                return .none
                
            case .destination(.presented(.alert(.acknowledgeDeletedButtonTapped))):
                return .run { _ in await dismiss() }
                
            case let .tvShowsUpdated(tvShows):
                if tvShows[id: state.tvShow.id] == nil {
                    state.destination = .alert(.deleted)
                }
                return .none
                
            case .onAppear:
                @Shared(.tvShows) var tvShows
                return .publisher {
                    $tvShows.publisher.map(Action.tvShowsUpdated)
                }
                
            case .destination(.presented(.alert(.confirmDeleteButtonTapped))):
                @Shared(.tvShows) var tvShows
                tvShows.remove(id: state.tvShow.id)
                return .run { _ in await dismiss() }
                
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
                return .none
            
            case .editButtonTapped:
                state.destination = .edit(TVShowForm.State(tvShow: state.tvShow, focus: nil))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == TVShowDetail.Destination.Alert {
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

struct TVShowDetailView: View {
    @Perception.Bindable var store: StoreOf<TVShowDetail>
    
    var body: some View {
        WithPerceptionTracking {
            Form {
                VStack {
                    Text(store.tvShow.title)
                        .navTitleStyle()
                    
                    poster
                }
                
                info
                deleteButton
                tvdbInfo

            }
            .onAppear {
                store.send(.onAppear)
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
        let store = Store(initialState: TVShowDetail.State(tvShow: Shared(.mock.mock2))) {
            TVShowDetail()
        }
        TVShowDetailView(store: store)
    }
}

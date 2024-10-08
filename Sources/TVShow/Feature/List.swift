import SwiftUI

// pointfree
import ComposableArchitecture

// dependencies
import AuthenticationClient
import TeamDatabaseClient
import TVShowDatabaseClient
import ErrorClient

// models
import TVShowModel

// api
import TheTVDBAPI

// UI elements
import Styleguide

// utilities
import Log

@Reducer
public struct TVShowList: Sendable {
    @Reducer
    public enum Destination {
        case add(TVShowForm)
    }
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        public var tvShows: IdentifiedArrayOf<TVShow> = []
        public var lastTVShowAdded: TVShow?
        var error = ErrorFeature.State()

        public init() {}
    }
    public enum Action {
        case onUserUpdated
        case onRefresh
        case error(ErrorFeature.Action)
        case tvShowsUpdated(IdentifiedArrayOf<TVShow>)
        case onAppear
        case addToTVShows(TVShow)
        case addTVShowAppIntent(String)
        case detailButtonTapped(TVShow)
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped(TVShow)
        case cancelAddButtonTapped
        case confirmAddButtonTapped
        case addButtonTapped
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.tvShowDatabaseClient) var tvShowDb
    @Dependency(\.teamDatabaseClient) var teamDb
    
    public init() {}
    
    private func save(tvShow: TVShow, state: inout State) -> Effect<Action> {
        state.lastTVShowAdded = tvShow
        return .run { _ in
            try await tvShowDb.save(tvShow)
        } catch: { error, send in
            await send(.error(.detail(error("save tvShow"))))
        }
    }
    
    private func listen(previousLimit: Int) -> Effect<Action> {
        .run { [previousLimit] send in
            let stream = try await tvShowDb.listen(
                orderBy: "tvdbInfo.score",
                descending: true,
                limit: previousLimit + 10
            )
            for try await tvShows in stream {
                logger.info("found \(tvShows.count) tvShows")
                await send(.tvShowsUpdated(tvShows))
            }
        } catch: { error, send in
            await send(.error(.detail(error("tvShow listen"))))
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case .error:
                return .none
                
            case let .tvShowsUpdated(tvShows):
                logger.debug("tvShowsUpdated(\(tvShows.count))")
                state.tvShows = tvShows
                return .none
                
            case .onAppear, .onUserUpdated:
                return listen(previousLimit: 0)
                
            case .onRefresh:
                return listen(previousLimit: state.tvShows.count)

            case let .addToTVShows(tvShow):
                return save(tvShow: tvShow, state: &state)
                
            case let .addTVShowAppIntent(title):
                return .run { send in
                    let searchResource = TheTVDBSeriesSearchResource(searchQuery: title)
                    var newTVShow = TVShow(id: TVShow.ID(uuid()), title: title, dateAdded: now, dateModified: now, teamId: nil)
                    
                    do {
                        if let firstMatchedSeries = try await searchResource.fetch()?.data.first {
                            newTVShow.tvdbInfo = TVDBInfo(from: firstMatchedSeries)
                            if let tvdbID = newTVShow.tvdbInfo?.tvdbID {
                                let detailResource = TheTVDBSeriesDetailResource(tvdbID: tvdbID.rawValue)
                                if let detail = try await detailResource.fetch()?.data {
                                    newTVShow.tvdbInfo?.populate(detail: detail)
                                }
                            }
                        }
                    } catch {
                        await send(.error(.detail(error("tvdbInfo"))))
                    }
                    if let tvdbName = newTVShow.tvdbInfo?.name {
                        newTVShow.title = tvdbName
                    }
                    await send(.addToTVShows(newTVShow))
                }
                
            case .detailButtonTapped:
                return .none
                
            case .destination:
                return .none
                
            case let .deleteButtonTapped(tvShow):
                return .run { _ in
                    try await tvShowDb.delete(tvShow)
                    await dismiss()
                } catch: { error, send in
                    await send(.error(.detail(error("delete"))))
                }
            
            case .cancelAddButtonTapped:
                state.destination = nil
                return .none
                
            case .confirmAddButtonTapped:
                guard var newTVShow = state.destination?.add?.tvShow else { return .none }
                if let tvdbName = newTVShow.tvdbInfo?.name {
                    newTVShow.title = tvdbName
                }
                state.destination = nil
                return save(tvShow: newTVShow, state: &state)
                
            case .addButtonTapped:
                let newTVShow = TVShow(id: TVShow.ID(uuid()), title: "", dateAdded: now, dateModified: now, teamId: nil)
                state.destination = .add(TVShowForm.State(tvShow: newTVShow, focus: .title))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
extension TVShowList.Destination.State: Equatable {}

public struct TVShowListView: View {
    @Bindable var store: StoreOf<TVShowList>
        
    public init(store: StoreOf<TVShowList>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            ErrorView(store: store.scope(state: \.error, action: \.error))

            LazyVGrid(columns: Layout.gridItems) {
                ForEach(store.tvShows.elements) { tvShow in
                    tvShowElement(tvShow: tvShow)
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("TV Shows")
        .sheet(item: $store.scope(state: \.destination?.add, action: \.destination.add)) { addStore in
            addView(addStore: addStore)
        }
        .toolbar { addButton }
        .onAppear {
            store.send(.onAppear)
        }
        .refreshable {
            store.send(.onRefresh)
        }
    }
    
    @ViewBuilder private func tvShowElement(tvShow: TVShow) -> some View {
        Button {
            store.send(.detailButtonTapped(tvShow))
        } label: {
            Thumbnail(
                url: tvShow.tvdbInfo?.imageURL,
                lowResolutionURL: tvShow.tvdbInfo?.thumbnailURL,
                size: Layout.posterSize,
                placeholderImageName: "tvShowPlaceholder",
                bundle: .module,
                altText: tvShow.title,
                showError: false
            )
            .contextMenu {
                deleteButton(tvShow: tvShow)
            }
        }
    }
    
    @ViewBuilder private var addButton: some View {
        Button {
            store.send(.addButtonTapped)
        } label: {
            Label("Add TV Show", systemImage: "plus")
        }
    }
    
    @ViewBuilder private func deleteButton(tvShow: TVShow) -> some View {
        Button(role: .destructive) {
            store.send(.deleteButtonTapped(tvShow))
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder private func addView(addStore: StoreOf<TVShowForm>) -> some View {
        NavigationStack {
            TVShowFormView(store: addStore)
                .navigationTitle("New TV Show")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Discard") {
                            store.send(.cancelAddButtonTapped)
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            store.send(.confirmAddButtonTapped)
                        }
                    }
                }
        }
    }
}

#Preview {
    @MainActor
    struct Preview: View {
        var store = Store(initialState: TVShowList.State()) {
            TVShowList()
            ._printChanges()
        }
        
        var body: some View {
            NavigationStack {
                 TVShowListView(store: store)
            }
        }
    }
    return Preview()
}


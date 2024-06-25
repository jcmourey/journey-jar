import SwiftUI
import TheTVDBAPI
import ComposableArchitecture
import Styleguide
import Persistence

@Reducer
public struct TVShowList {
    @Reducer(state: .equatable)
    public enum Destination {
        case add(TVShowForm)
    }
    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        @Shared(.tvShows) public var tvShows
        public var lastTVShowAdded: TVShow?
        
        public init() {}
        
        var sortedTVShowElements: some RandomAccessCollection<Shared<TVShow>> {
            $tvShows.elements.sorted { show0, show1 in
                guard let score0 = show0.wrappedValue.tvdbInfo?.score else { return false }
                guard let score1 = show1.wrappedValue.tvdbInfo?.score else { return true }
                return score0 > score1
            }
        }
    }
    public enum Action {
        case addToTVShows(TVShow)
        case addTVShowAppIntent(String)
        case detailButtonTapped(Shared<TVShow>)
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped(id: TVShow.ID)
        case cancelAddButtonTapped
        case confirmAddButtonTapped
        case addButtonTapped
    }
    
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    @Dependency(\.dismiss) var dismiss
    
    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .addToTVShows(tvShow):
                state.tvShows.append(tvShow)
                state.lastTVShowAdded = tvShow
                return .none
                
            case let .addTVShowAppIntent(title):
                return .run { send in
                    let searchResource = TheTVDBSeriesSearchResource(searchQuery: title)
                    var newTVShow = TVShow(id: TVShow.ID(uuid()), title: title, dateAdded: now, dateModified: now)
                    
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
                        print("unable to get series info or details: \(error)")
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
                
            case let .deleteButtonTapped(id):
                state.tvShows.remove(id: id)
                return .none
            
            case .cancelAddButtonTapped:
                state.destination = nil
                return .none
                
            case .confirmAddButtonTapped:
                guard var newTVShow = state.destination?.add?.tvShow else { return .none }
                if let tvdbName = newTVShow.tvdbInfo?.name {
                    newTVShow.title = tvdbName
                }
                state.tvShows.append(newTVShow)
                state.lastTVShowAdded = newTVShow
                state.destination = nil
                return .none
                
            case .addButtonTapped:
                let newTVShow = TVShow(id: TVShow.ID(uuid()), dateAdded: now, dateModified: now)
                state.destination = .add(TVShowForm.State(tvShow: newTVShow, focus: .title))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct TVShowListView: View {
    @Perception.Bindable var store: StoreOf<TVShowList>
        
    public init(store: StoreOf<TVShowList>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                LazyVGrid(columns: Layout.gridItems) {
                    ForEach(store.sortedTVShowElements) { $tvShow in
                        Button {
                            store.send(.detailButtonTapped($tvShow))
                        } label: {
                            Thumbnail(
                                url: tvShow.tvdbInfo?.imageURL,
                                lowResolutionURL: tvShow.tvdbInfo?.thumbnailURL,
                                size: Layout.posterSize,
                                placeholderImageName: "tvShowPlaceholder",
                                altText: tvShow.title,
                                showError: false
                            )
                            .contextMenu {
                                deleteButton(id: tvShow.id)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("TV Shows")
            .sheet(item: $store.scope(state: \.destination?.add, action: \.destination.add)) { addStore in
                addView(addStore: addStore)
            }
            .toolbar { addButton }
        }
    }
    
    @ViewBuilder private var addButton: some View {
        Button {
            store.send(.addButtonTapped)
        } label: {
            Label("Add TV Show", systemImage: "plus")
        }
    }
    
    @ViewBuilder private func deleteButton(id: TVShow.ID) -> some View {
        Button(role: .destructive) {
            store.send(.deleteButtonTapped(id: id))
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
        @Shared(.tvShows) var tvShows = .mock
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


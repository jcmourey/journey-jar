import ComposableArchitecture
import SwiftUI
import Styleguide
import Rating

struct TVShowFormView: View {
    @Perception.Bindable var store: StoreOf<TVShowForm>
    @FocusState var focus: TVShowForm.State.Field?
    
    @Environment(\.layoutDirection) var layoutDirection

    var body: some View {
        WithPerceptionTracking {
            Form {
                Section("TVShow Info") {
                    VStack(alignment: .center) {
                        HStack {
                            TextField("Title", text: $store.tvShow.title, axis: .vertical)
                                .focused($focus, equals: .title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .navTitleStyle()

                            
                            Button {
                                store.send(.clearTitle)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.headline)
                            }
                            .disabled(store.tvShow.title.isEmpty)
                        }
                        
                        posterSelector
                    }
                    
                    KeyContentPair("How interested are you in the show?") {
                        RatingSelector(level: $store.tvShow.interest)
                    }
                    
                    KeyContentPair("Where are you with the show?", axis: .vertical) {
                        Picker("Progress", selection: $store.tvShow.progress) {
                            ForEach(TVShow.Progress.allCases, id: \.self) { progress in
                                Text(progress.rawValue)
                                    .tag(progress as TVShow.Progress?)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle.segmentedIfAvailable)
                    }
                
                    ForEach($store.tvShow.recommendations) { $recommendation in
                        KeyContentPair("Recommended by") {
                            TextField("Name", text: $recommendation.name)
                                .focused($focus, equals: .recommendation(recommendation.id))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .onDelete { indices in
                        store.send(.onDeleteRecommendations(indices))
                    }
                    
                    Button("Add recommendation") {
                        store.send(.addRecommendationButtonTapped)
                    }
                    
                }
                
                Section("TVDB Info") {
                    if let errorDescription = store.errorDescription {
                        Text(errorDescription)
                            .font(.caption)
                    }
                    
                    if let info = store.tvShow.tvdbInfo {
                        OptionalText(info.name)
                            .navTitleStyle(font: .title)
                        
                        TVDBInfoDetail(info: info)
                    }
                }
            }
            .bind($store.focus, to: $focus)
            .task(id: store.tvShow.title) {
                store.send(.titleChanged)
            }
            .refreshable {
                store.send(.refresh)
            }
        }
    }
    
    var directionFactor: Double {
        switch layoutDirection {
        case .leftToRight: 1
        case .rightToLeft: -1
        @unknown default: 1
        }
    }
    
    @ViewBuilder
    var posterSelector: some View {
        if let info = store.tvShow.tvdbInfo, let imageURL = info.imageURL {
            HStack {
                if store.series.count > 1 {
                    VStack {
                        Spacer()
                        Button {
                            store.send(.previousTVDBSeriesButtonTapped)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(store.seriesCountBefore == 0)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    }
                }
                
                VStack {
                    Thumbnail(
                        url: imageURL,
                        lowResolutionURL: info.thumbnailURL,
                        size: Layout.posterSize,
                        placeholderImageName: nil,
                        altText: store.tvShow.title
                    )
                    .onTapGesture {
                        store.send(.posterTapped)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                guard store.series.count > 1 else { return }
                                let translationDirection = gesture.translation.width * directionFactor
                                if translationDirection < 0 {
                                    store.send(.nextTVDBSeriesButtonTapped)
                                } else {
                                    store.send(.previousTVDBSeriesButtonTapped)
                                }
                            }
                    )
                    
                    if store.series.count > 1, let seriesIndex = store.seriesIndex {
                        Text("\(seriesIndex + 1) of \(store.series.count)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.caption)
                    }
                }
                
                VStack {
                    TVDBInfoSidebar(info: info, fontSize: 12)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)

                    Spacer()
                    
                    if store.series.count > 1 {
                        Button {
                            store.send(.nextTVDBSeriesButtonTapped)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(store.seriesCountAfter == 0)
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .font(.title)
                    }
                }
            }
            .buttonStyle(.borderless) // needed for multiple buttons inside Form (hack, bug in SwiftUI)
        }
    }
}

#Preview("Edit TV Show") {
    NavigationStack {
        let store = Store(initialState: TVShowForm.State(tvShow: .mock.mock2, focus: nil)) {
            TVShowForm()
        }
        TVShowFormView(store: store)
    }
}

#Preview("Add TV Show") {
    NavigationStack {
        let store = Store(initialState: TVShowForm.State(tvShow: TVShow(id: TVShow.ID(), dateAdded: .now, dateModified: .now), focus: .title)) {
            TVShowForm()
        }
        TVShowFormView(store: store)
    }
}


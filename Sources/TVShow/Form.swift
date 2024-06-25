import ComposableArchitecture
import SwiftUI
import IdentifiedCollections
import TheTVDBAPI
import CollectionConvenience

@Reducer
public struct TVShowForm {
    @ObservableState
    public struct State: Equatable {
        var errorDescription: String?
        var currentSeries: TheTVDBSeries?
        var series: IdentifiedArrayOf<TheTVDBSeries> = []
        public var tvShow: TVShow
        var focus: Field? = .title

        enum Field: Hashable {
            case title
            case recommendation(Recommendation.ID)
            
            var recommendationID: Recommendation.ID? {
                switch self {
                case .title: return nil
                case let .recommendation(id): return id
                }
            }
        }
        
        var seriesCountBefore: Int {
            series.count(before: currentSeries?.id)
        }
        
        var seriesIndex: Int? {
            guard let id = currentSeries?.id else { return nil }
            return series.index(id: id)
        }
        
        var seriesCountAfter: Int {
            series.count(after: currentSeries?.id)
        }
        
        var previousSeries: TheTVDBSeries? {
            guard let currentSeries else { return nil }
            return series.element(before: currentSeries.id)
        }
        
        var nextSeries: TheTVDBSeries? {
            guard let currentSeries else { return nil }
            return series.element(after: currentSeries.id)
        }
    }
    
    public enum Action: BindableAction {
        case clearTitle
        case posterTapped
        case tvdbDetailResponse(Result<TheTVDBSeriesDetail, Error>)
        case fetchDetail
        case previousTVDBSeriesButtonTapped
        case nextTVDBSeriesButtonTapped
        case tvdbSeriesResponse(Result<IdentifiedArrayOf<TheTVDBSeries>, Error>)
        case refresh
        case titleChanged
        case addRecommendationButtonTapped
        case binding(BindingAction<State>)
        case onDeleteRecommendations(IndexSet)
    }
    
    enum CancelID { case fetchSeriesTask, fetchDetailTask }
    
    @Dependency(\.uuid) var uuid
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .clearTitle:
                state.tvShow.title = ""
                state.tvShow.tvdbInfo = nil
                state.focus = .title
                return .none
                
            case .posterTapped:
                state.focus = nil
                return .none
                
            case let .tvdbDetailResponse(result):
                switch result {
                case let .success(detail):
                    state.errorDescription = nil
                    state.tvShow.tvdbInfo?.populate(detail: detail)
                    
                case let .failure(error):
                    let errorDescription = "\(error): \(error.localizedDescription)"
                    state.errorDescription = errorDescription
                    print(errorDescription)
                }
                return .none
                
            case .fetchDetail:
                guard let tvdbID = state.tvShow.tvdbInfo?.tvdbID else { return .none }
                return .run { [tvdbID = tvdbID] send in
                    let resource = TheTVDBSeriesDetailResource(tvdbID: tvdbID.rawValue)
                    
                    do {
                        guard let detail = try await resource.fetch()?.data else { return }
                        await send(.tvdbDetailResponse(.success(detail)))
                    } catch {
                        await send(.tvdbDetailResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.fetchDetailTask, cancelInFlight: true)

                
            case .previousTVDBSeriesButtonTapped:
                state.focus = nil
                guard let previousSeries = state.previousSeries else { return .none }
                state.tvShow.tvdbInfo = TVDBInfo(from: previousSeries)
                state.currentSeries = previousSeries
                return .run { send in
                    await send(.fetchDetail)
                }
                
            case .nextTVDBSeriesButtonTapped:
                state.focus = nil
                guard let nextSeries = state.nextSeries else { return .none }
                state.tvShow.tvdbInfo = TVDBInfo(from: nextSeries)
                state.currentSeries = nextSeries
                return .run { send in
                    await send(.fetchDetail)
                }
                
            case let .tvdbSeriesResponse(result):
                switch result {
                case let .success(series):
                    state.series = series
                    state.errorDescription = nil
                    let bestMatch: TheTVDBSeries
                    if let tvdbID = state.tvShow.tvdbInfo?.tvdbID, let seriesMatch = series[id: String(tvdbID)] {
                        bestMatch = seriesMatch
                    } else if let firstMatch = series.first {
                        bestMatch = firstMatch
                    } else {
                        state.currentSeries = nil
                        return .none
                    }
                    
                    state.tvShow.tvdbInfo = TVDBInfo(from: bestMatch)
                    state.currentSeries = bestMatch
                    return .run { send in
                        await send(.fetchDetail)
                    }
                    
                case let .failure(error):
                    state.series = []
                    state.currentSeries = nil
                    let errorDescription = "\(error): \(error.localizedDescription)"
                    state.errorDescription = errorDescription
                    print(errorDescription)
                    return .none
                }
                
            case .titleChanged, .refresh:
                state.errorDescription = nil
                guard !state.tvShow.title.isEmpty else { return .none }
                
                return .run { [title = state.tvShow.title] send in
                    let resource = TheTVDBSeriesSearchResource(searchQuery: title)

                    do {
                        guard let series = try await resource.fetch()?.data else { return }
                        await send(.tvdbSeriesResponse(.success(series)))
                     } catch {
                        await send(.tvdbSeriesResponse(.failure(error)))
                     }
                }
                .cancellable(id: CancelID.fetchSeriesTask, cancelInFlight: true)
                
            case .addRecommendationButtonTapped:
                let recommendation = Recommendation(id: Recommendation.ID(uuid()))
                state.tvShow.recommendations.append(recommendation)
                state.focus = .recommendation(recommendation.id)
                return .none
                
            case .binding:
                return .none
                
            case let .onDeleteRecommendations(indices):
                state.tvShow.recommendations.remove(atOffsets: indices)
                
                // Adjust recommendation focus
                guard let focusedRecommendationID = state.focus?.recommendationID else {
                    return .none
                }
                
                // Move focus to title if no more recommendations
                guard !state.tvShow.recommendations.isEmpty else {
                    state.focus = .title
                    return .none
                }
                
                // If focus was on one of the removed recommendations, move it to a neighbor recommendation
                guard state.tvShow.recommendations.filter({ $0.id == focusedRecommendationID }).isEmpty else {
                    return .none
                }
                
                guard let firstDeletedIndex = indices.first else {
                    return .none
                }
                
                // first deleted index becomes index of first non-deleted item after remove operation
                let neighborIndex = min(firstDeletedIndex, state.tvShow.recommendations.endIndex - 1)
                state.focus = .recommendation(state.tvShow.recommendations[neighborIndex].id)
                return .none
            }
        }
    }
}

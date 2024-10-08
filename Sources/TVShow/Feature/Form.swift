import SwiftUI

// pointfree
import ComposableArchitecture
import IdentifiedCollections

// dependencies
import AuthenticationClient
import TeamDatabaseClient

// models
import TVShowModel
import TeamModel

// features
import TeamFeature
import ErrorFeature

// api
import TheTVDBAPI

// types
import CollectionConvenience


@Reducer
public struct TVShowForm: Sendable {
    public enum TVShowError: Error {
        case noTeamSelected
        case noSeriesSearchResult
        case noSeriesDetailResult
    }
    
    @ObservableState
    public struct State: Equatable {
        var error = ErrorFeature.State()
        var currentSeries: TheTVDBSeries?
        var series: IdentifiedArrayOf<TheTVDBSeries> = []
        public var tvShow: TVShow
        var focus: Field? = .title
        var teamSelector = TeamSelector.State()

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
        case error(ErrorFeature.Action)
        case teamSelector(TeamSelector.Action)
        case clearTitle
        case posterTapped
        case tvdbDetailResponse(TheTVDBSeriesDetail)
        case fetchDetail
        case previousTVDBSeriesButtonTapped
        case nextTVDBSeriesButtonTapped
        case tvdbSeriesResponse(IdentifiedArrayOf<TheTVDBSeries>)
        case titleChanged
        case addRecommendationButtonTapped
        case binding(BindingAction<State>)
        case onDeleteRecommendations(IndexSet)
    }
    
    enum CancelID { case fetchSeriesTask, fetchDetailTask }
    
    @Dependency(\.uuid) var uuid
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.teamSelector, action: \.teamSelector) {
            TeamSelector()
        }
        
        Scope(state: \.error, action: \.error) { ErrorFeature() }
        
        Reduce { state, action in
            switch action {
            case .teamSelector:
                guard let team = state.teamSelector.selectedTeam else {
                    return .run { send in
                        let error = TVShowError.noTeamSelected
                        await send(.error(.detail(error("teamSelector"))))
                    }
                }
                state.tvShow.teamId = team.id
                state.tvShow.memberIds = team.memberIds
                return .none
    
            case .clearTitle:
                state.tvShow.title = ""
                state.tvShow.tvdbInfo = nil
                state.focus = .title
                return .none
                
            case .posterTapped:
                state.focus = nil
                return .none
                
            case let .tvdbDetailResponse(detail):
                state.tvShow.tvdbInfo?.populate(detail: detail)
                return .none
                
            case .fetchDetail:
                guard let tvdbID = state.tvShow.tvdbInfo?.tvdbID else { return .none }
                return .run { [tvdbID] send in
                    let resource = TheTVDBSeriesDetailResource(tvdbID: tvdbID.rawValue)
                    guard let detail = try await resource.fetch()?.data else {
                        throw TVShowError.noSeriesDetailResult
                    }
                    await send(.tvdbDetailResponse(detail))
                } catch: { error, send in
                    await send(.error(.detail(error("fetchDetail"))))
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
                
            case let .tvdbSeriesResponse(series):
                state.series = series
                
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
                
            case .titleChanged:
                guard !state.tvShow.title.isEmpty else { return .none }
                state.series = []
                state.currentSeries = nil
                
                return .run { [title = state.tvShow.title] send in
                    let resource = TheTVDBSeriesSearchResource(searchQuery: title)
                    guard let series = try await resource.fetch()?.data else {
                        throw TVShowError.noSeriesSearchResult
                    }
                    await send(.tvdbSeriesResponse(series))
                } catch: { error, send in
                    await send(.error(.detail(error("tvdbSeriesSearch"))))
                }
                .cancellable(id: CancelID.fetchSeriesTask, cancelInFlight: true)
                
            case .addRecommendationButtonTapped:
                let recommendation = Recommendation(id: Recommendation.ID(uuid()))
                state.tvShow.recommendations.append(recommendation)
                state.focus = .recommendation(recommendation.id)
                return .none
                
            case .binding:
                return .none
                                   
            case .error:
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

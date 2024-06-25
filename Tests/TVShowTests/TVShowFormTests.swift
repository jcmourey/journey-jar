//
//  TVShowFormTests.swift
//  JourneyJarTests
//
//  Created by Jean-Charles Mourey on 09/06/2024.
//

import ComposableArchitecture
import XCTest
import Tagged

@testable import JourneyJar

final class TVShowFormTests: XCTestCase {
    @MainActor
    func testRemoveRecommendation() async {
        let mockTVShow = TVShow.mock.multipleRecommendations
        let store = TestStore(initialState: TVShowForm.State(tvShow: mockTVShow)) {
            TVShowForm()
        }
                
        await store.send(.onDeleteRecommendations([0])) {
            $0.tvShow.recommendations.removeFirst()
        }
    }
    
    @MainActor
    func testRemoveFocusedRecommendation() async {
        let mockTVShow = TVShow.mock.multipleRecommendations
        let recommendation1 = mockTVShow.recommendations[0]
        let recommendation2 = mockTVShow.recommendations[1]
        
        let store = TestStore(initialState: TVShowForm.State(
            focus: .recommendation(recommendation1.id),
            tvShow: mockTVShow
        )) {
            TVShowForm()
        }
                
        await store.send(.onDeleteRecommendations([0])) {
            $0.tvShow.recommendations.removeFirst()
            $0.focus = .recommendation(recommendation2.id)
        }
    }
    
    @MainActor
    func testAddRecommendation() async {
        let mockTVShow = TVShow.mock.noRecommendation
        let store = TestStore(initialState: TVShowForm.State(tvShow: mockTVShow)) {
            TVShowForm()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addRecommendationButtonTapped) {
            let recommendation = Recommendation(id: Tagged<Recommendation, UUID>(rawValue: UUID(0)))
            $0.focus = .recommendation(recommendation.id)
            $0.tvShow.recommendations.append(recommendation)
        }
    }
}

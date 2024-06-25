//
//  TVShowListTests.swift
//  JourneyJar
//
//  Created by Jean-Charles Mourey on 09/06/2024.
//

import ComposableArchitecture
import IdentifiedCollections
import XCTest

@testable import JourneyJar

final class TVShowListTests: XCTestCase {
    
    @MainActor
    func testDelete() async {
        let mockTVShow = TVShow.mock.mock1
        @Shared(.tvShows) var tvShows = [mockTVShow]
        
        let store = TestStore(initialState: TVShowList.State()) {
            TVShowList()
        }
        
        await store.send(.deleteButtonTapped(id: mockTVShow.id)) {
            $0.tvShows = []
        }
    }
    
    @MainActor
    func testAdd() async {
        let store = TestStore(initialState: TVShowList.State()) {
            TVShowList()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = .distantPast
        }

        await store.send(.addButtonTapped) {
            $0.destination = .add(TVShowForm.State(tvShow: TVShow(id: TVShow.ID(UUID(0)), dateAdded: .distantPast, dateModified: .distantPast), focus: .title))
        }
        
        let mockTVShow = TVShow(
            id: TVShow.ID(UUID(0)),
            title: "Dexter",
            dateAdded: .distantPast,
            dateModified: .distantPast,
            recommendations: [.mock.mock1, .mock.mock2]
        )
        await store.send(\.destination.add.binding.tvShow, mockTVShow) {
            $0.destination?.add?.tvShow = mockTVShow
        }
        
        await store.send(.confirmAddButtonTapped) {
            $0.destination = nil
            $0.tvShows = [mockTVShow]
        }
    }
    
    @MainActor
    func testAdd_NonExhaustive() async {
        let store = TestStore(initialState: TVShowList.State()) {
            TVShowList()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = .distantPast
        }
        store.exhaustivity = .off
        
        await store.send(.addButtonTapped)
        
        let mockTVShow = TVShow(
            id: TVShow.ID(UUID(0)),
            title: "Dexter",
            dateAdded: .distantPast,
            dateModified: .distantPast,
            recommendations: [.mock.mock1, .mock.mock2]
        )
        await store.send(\.destination.add.binding.tvShow, mockTVShow)
        
        await store.send(\.confirmAddButtonTapped) {
            $0.tvShows = [mockTVShow]
        }
    }
}

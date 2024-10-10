import Testing

// pointfree
import ComposableArchitecture

@testable import TVShowFeature

@Suite("TVShowList")
struct TVShowListTests {
    @Test
    func delete() async {
        let mockTVShow = TVShow.mock.mock1
        
        let store = TestStore(initialState: TVShowList.State()) {
            TVShowList()
        }
        
        await store.send(.deleteButtonTapped(id: mockTVShow.id)) {
            $0.tvShows = []
        }
    }
    
    @Test
    func add() async {
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
    
    @Test
    func add_NonExhaustive() async {
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

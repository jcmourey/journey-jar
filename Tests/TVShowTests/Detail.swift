import Testing

// pointfree
import ComposableArchitecture

@testable import TVShowFeature

@Suite("TVShowDetail")
struct TVShowDetailTests {
    @Test
    func edit() async {
        let mockTVShow = TVShow.mock.mock2
        
        let store = TestStore(initialState: TVShowDetail.State(tvShow: Shared(mockTVShow))) {
            TVShowDetail()
        }
        
        await store.send(.editButtonTapped) {
            $0.destination = .edit(TVShowForm.State(tvShow: mockTVShow, focus: nil))
        }
        
        var editedTVShow = mockTVShow
        editedTVShow.title = "Something else"
        await store.send(\.destination.edit.binding.tvShow, editedTVShow) {
            $0.destination?.edit?.tvShow = editedTVShow
        }
        
        await store.send(.doneEditingButtonTapped) {
            $0.destination = nil
            $0.tvShow = editedTVShow
        }
    }

}

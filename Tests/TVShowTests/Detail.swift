import Testing
import Foundation

// pointfree
import ComposableArchitecture

@testable import TVShowFeature
@testable import TVShowModel
@testable import TeamModel

@MainActor
@Suite("TVShowDetail")
struct TVShowDetailTests {
    @Test
    func edit() async {
        let mockTVShow = TVShow.mock.mock2
        let mockTeams = Team.mockTeams(numberOfTeams: 1)
        let now = Date.now
        
        let store = TestStore(initialState: TVShowDetail.State(tvShow: mockTVShow)) {
            TVShowDetail()
        } withDependencies: {
            $0.teamDatabaseClient.listen = {
                AsyncThrowingStream { continuation in
                    continuation.yield(mockTeams)
                    continuation.finish()
                }
            }
            $0.date.now = now
            $0.tvShowDatabaseClient.save = { tvShow in print("Saving TVShow \(tvShow.title)") }
        }
        
        await store.send(.onAppear)
        await store.receive(\.teamsUpdated) {
            $0.teams = mockTeams
        }
        await store.send(.editButtonTapped) {
            $0.destination = .edit(TVShowForm.State(tvShow: mockTVShow))
        }
        
        var editedTVShow = mockTVShow
        editedTVShow.title = "Something else"
        await store.send(\.destination.edit.binding.tvShow, editedTVShow) {
            $0.destination = .edit(TVShowForm.State(tvShow: editedTVShow))
        }
        
        await store.send(.doneEditingButtonTapped) {
            $0.destination = nil
            editedTVShow.dateModified = now
            $0.tvShow = editedTVShow
        }
    }

}

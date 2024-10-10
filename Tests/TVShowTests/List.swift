import Testing
import Foundation

// pointfree
import ComposableArchitecture

@testable import TVShowFeature
@testable import TVShowModel

@MainActor
@Suite("TVShowList")
struct TVShowListTests {
    actor TVShowMockDatabase {
        var tvShows: IdentifiedArrayOf<TVShow>
        var continuation: AsyncThrowingStream<IdentifiedArrayOf<TVShow>, any Error>.Continuation? = nil
        
        init(tvShows: IdentifiedArrayOf<TVShow>) {
            self.tvShows = tvShows
        }
        
        func setContinuation(_ continuation: AsyncThrowingStream<IdentifiedArrayOf<TVShow>, any Error>.Continuation) {
            self.continuation = continuation
            yield()
        }
        
        func yield() {
            continuation?.yield(tvShows)
        }
        
        func finish() {
            continuation?.finish()
        }
        
        func add(_ tvShow: TVShow) {
            tvShows.append(tvShow)
            yield()
            finish()
        }

        func delete(_ tvShow: TVShow) {
            tvShows.remove(tvShow)
            yield()
            finish()
        }
    }
    
    func testStore(initialTVShows: IdentifiedArrayOf<TVShow>, now: Date = .now) -> TestStore<TVShowList.State, TVShowList.Action> {
        TestStore(initialState: TVShowList.State()) {
            TVShowList()
        } withDependencies: {
            let tvShowMockDatabase = TVShowMockDatabase(tvShows: initialTVShows)

            $0.tvShowDatabaseClient.listen = { @Sendable _,_,_ in
                AsyncThrowingStream { continuation in
                    Task {
                        await tvShowMockDatabase.setContinuation(continuation)
                    }
                }
            }
            $0.tvShowDatabaseClient.save = { tvShow in
                print("Adding TVShow \(tvShow.title)")
                await tvShowMockDatabase.add(tvShow)
            }
            $0.tvShowDatabaseClient.delete = { tvShow in
                print("Deleting TVShow \(tvShow.title)")
                await tvShowMockDatabase.delete(tvShow)
            }
            
            $0.date.now = now
            $0.uuid = .incrementing
        }
    }
    
    @Test func delete() async {
        let mockTVShow = TVShow.mock.mock1
        let store = testStore(initialTVShows: [mockTVShow])
        
        await store.send(.onAppear)
            
        await store.receive(\.tvShowsUpdated) {
            $0.tvShows = [mockTVShow]
        }

        await store.send(.deleteButtonTapped(mockTVShow))
        await store.receive(\.tvShowsUpdated) {
            $0.tvShows = []
        }
    }
    
    @Test func add() async {
        let now = Date.now
        let store = testStore(initialTVShows: [], now: now)
        
        await store.send(.onAppear)
        await store.receive(\.tvShowsUpdated)
        
        await store.send(.addButtonTapped) {
            $0.destination = .add(TVShowForm.State(tvShow: TVShow(id: TVShow.ID(UUID(0)), title: "", dateAdded: now, dateModified: now), focus: .title))
        }
        
        let mockTVShow = TVShow(
            id: TVShow.ID(UUID(0)),
            title: "Dexter",
            dateAdded: now,
            dateModified: now,
            recommendations: [.mock.mock1, .mock.mock2]
        )
        await store.send(\.destination.add.binding.tvShow, mockTVShow) {
            $0.destination = .add(TVShowForm.State(tvShow: mockTVShow))
        }
        
        await store.send(.confirmAddButtonTapped) {
            $0.destination = nil
            $0.lastTVShowAdded = mockTVShow
        }
        
        await store.receive(\.tvShowsUpdated) {
            $0.tvShows = [mockTVShow]
        }
    }
    
    @Test func add_NonExhaustive() async {
        let now = Date.now
        let store = testStore(initialTVShows: [], now: now)

        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.addButtonTapped)
        
        let mockTVShow = TVShow(
            id: TVShow.ID(UUID(0)),
            title: "Dexter",
            dateAdded: now,
            dateModified: now,
            recommendations: [.mock.mock1, .mock.mock2]
        )
        await store.send(\.destination.add.binding.tvShow, mockTVShow)
        
        await store.send(\.confirmAddButtonTapped)
        await store.receive(\.tvShowsUpdated) {
            $0.tvShows = [mockTVShow]
        }
    }
}

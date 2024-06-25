import ComposableArchitecture
import SwiftUI

@Reducer
struct LargePoster {
    @ObservableState
    struct State: Equatable {
        let posterURL: URL
    }
    enum Action {
        case posterTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .posterTapped:
                .run { _ in await dismiss() }
            }
        }
    }
}

struct LargePosterView: View {
    let store: StoreOf<LargePoster>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.posterTapped)
            } label: {
                Thumbnail(url: store.posterURL)
            }
        }
    }
}

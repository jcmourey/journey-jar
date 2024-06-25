import ComposableArchitecture
import SwiftUI

@Reducer
public struct LargePoster: Reducer {
    @ObservableState
    public struct State: Equatable {
        let posterURL: URL
        
        public init(posterURL: URL) {
            self.posterURL = posterURL
        }
    }
    public enum Action {
        case posterTapped
    }
        
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .posterTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}

public struct LargePosterView: View {
    let store: StoreOf<LargePoster>
    
    public init(store: StoreOf<LargePoster>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.posterTapped)
            } label: {
                Thumbnail(url: store.posterURL)
            }
        }
    }
}

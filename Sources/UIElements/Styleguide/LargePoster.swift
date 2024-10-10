import SwiftUI

// pointfree
import ComposableArchitecture

@Reducer
public struct LargePoster: Sendable {   // public reducers must be marked as Sendable manually
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
    
    @Dependency(\.isPresented) var isPresented
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .posterTapped:
                return .run { _ in
                    if isPresented {
                        await dismiss()
                    }
                }
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
        Button {
            store.send(.posterTapped)
        } label: {
            Thumbnail(url: store.posterURL)
        }
    }
}

#Preview {
    List(Array(URL.mockImages), id: \.key) { key, url in
        if let url {
            HStack(alignment: .top) {
                Text(key)
                LargePosterView(store: Store(initialState: .init(posterURL: url)) { LargePoster() })
            }
        } else {
            Text("\(key): nil url")
        }
    }
}

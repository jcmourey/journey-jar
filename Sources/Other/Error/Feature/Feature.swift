import SwiftUI

// pointfree
import ComposableArchitecture

// utilities
import Log

@Reducer
public struct ErrorFeature {
    @ObservableState
    public struct State: Equatable {
        public var errorDescription: String? {
            didSet {
                if let errorDescription {
                    logError(errorDescription)
                }
            }
        }
        
        public init(errorDescription: String? = nil) {
            self.errorDescription = errorDescription
        }
    }
    
    public enum Action {
        case detail(String)
    }
    
    public init() {}
    
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            state.errorDescription = nil
            
            switch action {
            case let .detail(errorDescription):
                state.errorDescription = errorDescription
                return .none
            }
        }
    }
}

public struct ErrorView: View {
    let store: StoreOf<ErrorFeature>
    
    public init(store: StoreOf<ErrorFeature>) {
        self.store = store
    }
    
    public var body: some View {
        if let errorString = store.errorDescription {
            Text("🛑 \(errorString)")
                .font(.caption)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 350, maxHeight: 500)
        }
    }
}

#Preview {
    let errorDescriptions = [
        "short error",
        nil,
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    ]
    return List(errorDescriptions, id: \.self) {
        ErrorView(store: Store(initialState: .init(errorDescription: $0)) { ErrorFeature() })
    }
}


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
                    logger.error("🛑 \(errorDescription)")
                }
            }
        }
        
        public init(errorDescription: String? = nil) {
            self.errorDescription = errorDescription
        }
    }
    
    public enum Action {
        case detail(error: any Error, label: String?, file: StaticString, function: StaticString, line: UInt)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            state.errorDescription = nil
            
            switch action {
            case let .detail(error, label, file, function, line):
                let localizedDescription = error.localizedDescription
                let labeledErrorDescription = if let label { "\(label): \(localizedDescription)" } else { "\(localizedDescription)" }
                state.errorDescription = "🛑 \(file): \(function):\(line): \(labeledErrorDescription)"
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
//                .lineLimit(nil)
//                .multilineTextAlignment(.center)
//                .padding()
//                .fixedSize(horizontal: false, vertical: true)
//                .frame(maxWidth: 350, maxHeight: 500)
        }
    }
}

#Preview {
    let errorDescriptions = [
        "short error",
        nil,
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    ]
    List(Array(errorDescriptions.enumerated()), id: \.0) { index, errorDescription in
        HStack {
            Text("error \(index)")
            ErrorView(store: Store(initialState: .init(errorDescription: errorDescription)) { ErrorFeature() })
        }
    }
}


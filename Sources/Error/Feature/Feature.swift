import SwiftUI

// pointfree
import ComposableArchitecture

// utilities
import Log

@Reducer
public struct ErrorFeature {
    @ObservableState
    public struct State: Equatable {
        public var errorDescription: String?
        
        public init(errorDescription: String? = nil) {
            self.errorDescription = errorDescription
        }
    }
    
    public enum Action {
        case detail(any Error, String?, StaticString, StaticString, UInt)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            state.errorDescription = nil
            
            switch action {
            case let .detail(error, label, file, function, line):
                let localizedDescription = error.localizedDescription
                let labeledError = if let label { "\(label): \(localizedDescription)" } else { localizedDescription }
                let errorDescription = "🛑 \(file): \(function):\(line): \(labeledError)"
                logger.error("\(errorDescription)")
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
        if let errorDescription = store.errorDescription {
            Text(errorDescription)
                .font(.caption)
//                .lineLimit(nil)
//                .multilineTextAlignment(.center)
//                .padding()
//                .fixedSize(horizontal: false, vertical: true)
//                .frame(maxWidth: 350, maxHeight: 500)
        }
    }
}




#Preview("Static errors") {
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

enum SomeError: Error, CaseIterable {
    case error1
    case error2
    case error3
    
    var next: Self {
        switch self {
        case .error1: .error2
        case .error2: .error3
        case .error3: .error1
        }
    }
}

#Preview("Dynamic errors") {
    @Previewable @State var error = SomeError.error1
    let store = Store(initialState: ErrorFeature.State()) { ErrorFeature() }
    
    let labels: [SomeError: String] = [
        .error1: "first error",
        .error2: "other error",
        .error3: "last error"
    ]
    
    Form {
        VStack(spacing: 20) {
            Button {
                error = error.next
                store.send(.detail(error, labels[error], #fileID, #function, #line))
            } label: {
                Text("Click to change error")
            }
            ErrorView(store: store)
        }
        .onAppear {
            store.send(.detail(error, labels[error], #fileID, #function, #line))
        }
    }
}


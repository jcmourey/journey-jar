import SwiftUI

// pointfree
import ComposableArchitecture

// modules
import FirebaseStart

public struct AppRoot: View {
    @MainActor
    static let store: Store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    public init() {
        startFirebase()
    }
    
    public var body: some View {
        AppView(store: Self.store)
    }
}

#Preview {
    AppRoot()
}

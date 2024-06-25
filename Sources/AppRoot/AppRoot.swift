import SwiftUI
import ComposableArchitecture

struct AppRoot: View {
    @MainActor
    static let store: Store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some View {
        AppView(store: Self.store)
    }
}

#Preview {
    AppRootView()
}

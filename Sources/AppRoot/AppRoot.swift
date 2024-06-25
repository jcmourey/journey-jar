import SwiftUI
import ComposableArchitecture

public struct AppRoot: View {
    @MainActor
    static let store: Store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    public init() {}
    
    public var body: some View {
        AppView(store: Self.store)
    }
}

#Preview {
    AppRoot()
}

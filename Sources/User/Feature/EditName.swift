import SwiftUI

// pointfree
import ComposableArchitecture

@Reducer
public struct EditName: Sendable {
    @ObservableState
    public struct State: Equatable {
        var name: String
        var focus: Field? = .name
        
        public enum Field: Hashable {
            case name
        }
        
        public init(name: String, focus: Field? = nil) {
            self.name = name
            self.focus = focus
        }
    }
    
    public init() {}

    public enum Action: BindableAction, Sendable {
        case clearButtonTapped
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .clearButtonTapped:
                state.name = ""
                state.focus = .name
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct EditNameView: View {
    @Bindable var store: StoreOf<EditName>
    @FocusState var focus: EditName.State.Field?

    var body: some View {
        Form {
            HStack {
                TextField("enter name", text: $store.name)
                    .focused($focus, equals: .name)
                
                Button {
                    store.send(.clearButtonTapped)
                } label: {
                    Image(systemName: "x.circle.fill")
                }
                .disabled(store.name.isEmpty)
            }
        }
        .bind($store.focus, to: $focus)
    }
}

import SwiftUI
import ComposableArchitecture

@Reducer
struct EditName {
    @ObservableState
    struct State: Equatable {
        var name: String = ""
    }
    enum Action: BindableAction, Sendable {
        case clearButtonTapped
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .clearButtonTapped:
                state.name = ""
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct EditNameView: View {
    @Perception.Bindable var store: StoreOf<EditName>
    
    var body: some View {
        WithPerceptionTracking {
            Form {
                HStack {
                    TextField("enter name", text: $store.name)
                    
                    Button {
                        store.send(.clearButtonTapped)
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .disabled(store.name.isEmpty)
                }
            }
        }
    }
}

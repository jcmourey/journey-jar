import SwiftUI
import ComposableArchitecture

@Reducer
public struct EditName {
    @ObservableState
    public struct State: Equatable {
        var name: String = ""
    }
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
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

public struct EditNameView: View {
    @Perception.Bindable var store: StoreOf<EditName>
    
    public var body: some View {
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

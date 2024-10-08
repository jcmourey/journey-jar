import SwiftUI

// pointfree
import ComposableArchitecture

public struct KeyContentPair<Content: View>: View {
    let key: String
    let content: () -> Content
    let axis: Axis
    
    public init(_ key: String, axis: Axis = .horizontal, @ViewBuilder content: @escaping () -> Content) {
        self.key = key.capitalized
        self.axis = axis
        self.content = content
    }
    
    public var body: some View {
        switch axis {
        case .vertical:
            VStack(alignment: .leading) {
                Text(key)
                content()
            }
        case .horizontal:
            HStack {
                Text(key)
                Spacer()
                content()
            }
        }
    }
}

#Preview {
    List {
        KeyContentPair("Heart") {
            Image(systemName: "heart.fill")
        }
    }
}

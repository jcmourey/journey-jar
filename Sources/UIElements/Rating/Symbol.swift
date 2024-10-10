import SwiftUI

public enum Symbol: String {
    case star = "star.fill"
    case heart = "heart.fill"
    
    var color: Color {
        switch self {
        case .star: .yellow
        case .heart: .red
        }
    }
    
    @ViewBuilder
    var image: some View {
        Image(systemName: rawValue)
    }
    
    @ViewBuilder
    var onImage: some View {
        image
            .foregroundColor(color)
    }
    
    @ViewBuilder
    var offImage: some View {
        image
            .foregroundColor(.gray)
    }
}

public struct SymbolView: View {
    let value: Int?
    let index: Int
    let symbol: Symbol
    
    public var body: some View {
        if let value, index <= value {
            symbol.onImage
        } else {
            symbol.offImage
        }
    }
}

#Preview {
    List {
        HStack {
            Text("full heart")
            SymbolView(value: 3, index: 2, symbol: .heart)
        }
        HStack {
            Text("nil value star")
            SymbolView(value: nil, index: 1, symbol: .star)
        }
        HStack {
            Text("value != index star")
            SymbolView(value: 4, index: 6, symbol: .star)
        }
    }
}

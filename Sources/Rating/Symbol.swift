import SwiftUI

struct SymbolView<T>: View {
    let value: Int?
    let index: Int
    let symbol: Symbol
    
    var body: some View {
        symbol
            .image
            .foregroundStyle(color)
    }
    
    var color: Color {
        if let value, index <= value {
            symbol.color
        } else {
            .gray
        }
    }
}


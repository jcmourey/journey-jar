import SwiftUI

public struct RatingView: View {
    let value: Int?
    let label: String?
    let symbol: Symbol
    let min: Int
    let max: Int
    
    public init(value: Int?, label: String? = nil, symbol: Symbol, min: Int, max: Int) {
        self.value = value
        self.label = label
        self.symbol = symbol
        self.min = min
        self.max = max
    }
    
    public var body: some View {
        HStack {
            if let label {
                Text(label)
            }
            Spacer()
                        
            ForEach(min...max, id: \.self) {
                SymbolView(value: value, index: $0, symbol: symbol)
            }
        }
    }
}

#Preview {
    List {
        RatingView(value: 3, label: "Stars", symbol: .star, min: 1, max: 5)
        RatingView(value: nil, label: nil, symbol: .star, min: 1, max: 4)
        RatingView(value: 6, label: "Hearts", symbol: .heart, min: 0, max: 4)
    }
}

extension RatingView {
    public init<T: RawRepresentable & CaseIterable>(level: T?, label: String? = nil, symbol: Symbol) where T.RawValue == Int {
        let rawValues = T.allCases.map(\.rawValue)
        self.init(
            value: level?.rawValue,
            label: label,
            symbol: symbol,
            min: rawValues.min() ?? 1,
            max: rawValues.max() ?? level?.rawValue ?? 1
        )
    }
    
    public init<T: RawRepresentable & CaseIterable & Symbolized>(level: T?, label: String? = nil) where T.RawValue == Int {
        self.init(level: level, label: label, symbol: T.symbol)
    }
}

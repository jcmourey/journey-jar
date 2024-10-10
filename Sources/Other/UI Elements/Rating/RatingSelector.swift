import SwiftUI

public struct RatingSelector<T>: View {
    @Binding var level: T?
    var label: String? = nil
    let symbol: Symbol
    let min: Int
    let max: Int
    let get: (T) -> Int
    let set: (Int) -> T?

    public var body: some View {
        HStack {
            if let label {
                Text(label)
            }
            Spacer()
            ForEach(min...max, id: \.self) { index in
                Button {
                    level = set(index)
                } label: {
                    let value: Int? = if let level { get(level) } else { nil }
                    SymbolView(value: value, index: index, symbol: symbol)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension RatingSelector where T: CaseIterable & RawRepresentable, T.RawValue == Int {
    public init(level: Binding<T?>, label: String? = nil, symbol: Symbol) {
        let rawValues = T.allCases.map(\.rawValue)
        self.init(
            level: level,
            label: label,
            symbol: symbol,
            min: rawValues.min() ?? 1,
            max: rawValues.max() ?? level.wrappedValue?.rawValue ?? 1,
            get: { $0.rawValue },
            set: { T.init(rawValue: $0) }
        )
    }
}

extension RatingSelector where T: CaseIterable & RawRepresentable & Symbolized, T.RawValue == Int {
    public init(level: Binding<T?>, label: String? = nil) {
        self.init(level: level, label: label, symbol: T.symbol)
    }
}

extension RatingSelector where T == Int {
    public init(level: Binding<T?>, label: String? = nil, symbol: Symbol, max: Int) {
        self.init(
            level: level,
            label: label,
            symbol: symbol,
            min: 1,
            max: max,
            get: { $0 },
            set: { $0 }
        )
    }
}


#Preview {
    enum Test: Int, CaseIterable {
        case one = 1
        case another
        case yetAnother
    }
    @Previewable @State var test: Test? = .another
    @Previewable @State var level: Int? = nil
    @Previewable @State var otherLevel: Int? = 4
    
    return Form {
        RatingSelector(level: $test, label: "Test", symbol: .star)
        RatingSelector(level: $level, symbol: .heart, max: 5)
        RatingSelector(level: $otherLevel, symbol: .heart, max: 5)
        RatingSelector(level: $otherLevel, symbol: .heart, max: 3)
   }
}

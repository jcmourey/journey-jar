import SwiftUI

struct RatingView<Level: Rating>: View {
    @Binding var level: Level?
    let label: String?
    let changeable: Bool
    let onSymbol: Symbol
    let offSymbol: Symbol?
    
    init(level: Binding<Level?>, label: String? = nil, changeable: Bool = true, onSymbol: Symbol? = nil, offSymbol: Symbol? = nil) {
        self._level = level
        self.label = label
        self.changeable = changeable
        self.onSymbol = if let onSymbol { onSymbol } else { Level.onSymbol }
        self.offSymbol = if let offSymbol { offSymbol } else { Level.offSymbol }
    }
    
    init(level: Level?, label: String? = nil, onSymbol: Symbol? = nil, offSymbol: Symbol? = nil) {
        self.init(
            level: .constant(level),
            label: label,
            changeable: false,
            onSymbol: onSymbol,
            offSymbol: offSymbol
        )
    }
    
    var body: some View {
        HStack {
            if let label {
                Text(label)
            }
            Spacer()
            HStack {
                ForEach(Level.allCases, id: \.self) { shownLevel in
                    if changeable {
                        Button {
                            level = shownLevel
                        } label: {
                            imageView(for: shownLevel)
                        }
                        .buttonStyle(.plain)
                    } else {
                        imageView(for: shownLevel)
                    }
                }
            }
        }
    }

    
    @ViewBuilder
    func imageView(for shownLevel: Level) -> some View {
        symbol(for: shownLevel)
            .image
            .foregroundStyle(color(for: shownLevel))
    }
    
    func symbol(for shownLevel: Level) -> Symbol {
        if let level, shownLevel <= level {
            onSymbol
        } else {
            offSymbol ?? onSymbol
        }
    }
    
    func color(for shownLevel: Level) -> Color {
        if let level, shownLevel <= level {
            onSymbol.color
        } else {
            offSymbol?.color ?? .gray
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var stars: Stars? = .two
        @State private var interest: Interest? = nil

        var body: some View {
            Form {
                RatingView(level: $interest, label: "Interest: \(String(describing: interest))")

                RatingView(level: interest, label: "Not changeable")
                RatingView(level: $interest)
                
                RatingView(level: $stars, label: "Stars", onSymbol: .star)
                RatingView(level: $stars, label: "Heart Stars", onSymbol: .heart)
                RatingView(level: stars, label: "Weird Fixed stars", onSymbol: .star, offSymbol: .heart)
            }
        }
    }
    return Preview()
}

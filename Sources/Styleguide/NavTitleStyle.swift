import SwiftUI

struct NavTitleStyle: ViewModifier {
    let font: Font
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .bold()
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.leading)
    }
}

extension View {
    func navTitleStyle(font: Font = .largeTitle) -> some View {
        modifier(NavTitleStyle(font: font))
    }
}


#Preview {
    Text("Navigation Title Style")
        .navTitleStyle()
}

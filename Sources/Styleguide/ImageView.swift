import SwiftUI

struct ImageView: View {
    let image: Image?
    
    init(_ uiImage: UIImage?) {
        image = if let uiImage { Image(uiImage: uiImage) } else { nil }
    }
    
    init(_ image: Image?) {
        self.image = image
    }
    
    init(systemName: String) {
        self.image = Image(systemName: systemName)
    }
    
    var body: some View {
        OptionalView(image, noDataLabel: .noImage) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

#Preview {
    Form {
        ImageView(Image("tvdb"))
        ImageView(UIImage(named: "tvdb"))
        ImageView(Image(systemName: "apple.logo"))
    }

}

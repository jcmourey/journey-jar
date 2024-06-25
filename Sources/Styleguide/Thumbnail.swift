import SwiftUI
import Kingfisher

struct Thumbnail: View {
    let url: URL?
    var lowResolutionURL: URL?
    var size: CGSize = CGSize(width: Double.infinity, height: .infinity)
    var placeholderImageName: String?
    var altText: String?
    var showError: Bool = true
    
    @State private var errorOccurred: Bool = false
    
    @ViewBuilder
    var errorView: some View {
        ContentUnavailableView {
            Label("No image", systemImage: "eye.slash")
        }
    }
    
    @ViewBuilder
    var placeholderImageView: some View {
        if let placeholderImageName {
            Image(placeholderImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    var body: some View {
        let lowResolutionSource: Source? = if let lowResolutionURL {
            .network(lowResolutionURL)
        } else {
            nil as Source?
        }
        
        if let url {
            KFImage.url(url)
                .placeholder { progress in
                    ZStack(alignment: .center) {
                        placeholderImageView
                        
                        if errorOccurred {
                            if showError {
                                errorView
                            }
                        } else {
                            ProgressView()
                        }
                    }
                }
                .fade(duration: 0.25)
                .lowDataModeSource(lowResolutionSource)
                .onProgress { receivedSize, totalSize in  }
                .onSuccess { result in  }
                .onFailure { error in errorOccurred = true }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: size.width, maxHeight: size.height)
        } else {
            VStack {
                placeholderImageView
                    .frame(maxWidth: size.width, maxHeight: size.height)
                if let altText {
                    Text(altText)
                }
            }
        }
    }
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            if let image = phase.image {
//                ImageView(image)
//            } else if phase.error != nil || url == nil {
//                if showError {
//                    errorView
//                }
//                if let altText {
//                    Text(altText)
//                        .frame(maxHeight: .infinity, alignment: .bottom)
//                }
//            } else {
//                ProgressView()
//            }
//        }
//    }
}


#Preview {
    ScrollView {
        LazyVGrid(columns: Layout.gridItems) {
//            Thumbnail(url: .mock.thumbnail)
//            Thumbnail(url: .mock.empty, showError: false)
//            Thumbnail(url: .mock.bogus)
//            Thumbnail(url: .mock.empty, altText: "altText")
        }
    }
    .padding()
}

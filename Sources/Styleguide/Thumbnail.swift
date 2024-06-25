import SwiftUI
import Kingfisher
import Future

public struct Thumbnail: View {
    let url: URL?
    let lowResolutionURL: URL?
    let size: CGSize
    let placeholderImageName: String?
    let altText: String?
    let showError: Bool
    
    public init(url: URL?, lowResolutionURL: URL? = nil, size: CGSize = CGSize(width: Double.infinity, height: .infinity), placeholderImageName: String? = nil, altText: String? = nil, showError: Bool = true) {
        self.url = url
        self.lowResolutionURL = lowResolutionURL
        self.size = size
        self.placeholderImageName = placeholderImageName
        self.altText = altText
        self.showError = showError
        self.errorOccurred = errorOccurred
    }
    
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
    
    public var body: some View {
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

import SwiftUI

/**
 A view that shows a no data label if content is not available or empty
 */
struct OptionalView<T, Content>: View where Content: View {
    let noDataLabel: Label<Text, Image>?
    let content: Content?

    init(noDataLabel: Label<Text, Image>?, content: Content?) {
        self.noDataLabel = noDataLabel
        self.content = content
    }
    
    init(_ item: T?, noDataLabel: Label<Text, Image>? = nil, @ViewBuilder content: @escaping (T) -> Content) where T: Collection {
        
        let content = if let item, !item.isEmpty { content(item) } else { nil as Content? }
        
        self.init(
            noDataLabel: noDataLabel,
            content: content
        )
    }
    
    init(_ item: T?, noDataLabel: Label<Text, Image>? = nil, @ViewBuilder content: @escaping (T) -> Content) {
        
        let content = if let item { content(item) } else { nil as Content? }
        
        self.init(
            noDataLabel: noDataLabel,
            content: content
        )
    }

    var body: some View {
        if let content {
            content
        } else if let noDataLabel {
            ContentUnavailableView {
                noDataLabel
            }
        }
    }
}

struct OptionalText: View {
    let text: String?
    
    init(_ text: String?) {
        self.text = text
    }
    
    var body: some View {
        OptionalView(text) {
            Text($0)
        }
    }
}

extension Label where Title == Text, Icon == Image {
    static let noImage = Label("no image", systemImage: "eye.slash")
    static let noData = Label("no data", systemImage: "icloud.slash")
}

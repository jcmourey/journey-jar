import Foundation

@MainActor
extension URL {
    struct Mock {
        let thumbnail = URL(string: "https://artworks.thetvdb.com/banners/posters/292174-1_t.jpg")
        let bogus = URL(string: "https://bogus.com")
        let empty = nil as URL?
    }
    static var mock: Mock { Mock() }
}

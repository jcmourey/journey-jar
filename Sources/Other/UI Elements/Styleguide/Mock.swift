import Foundation

extension URL {
    static let mockImages: [String: URL?] = [
        "thumbnail": URL(string: "https://artworks.thetvdb.com/banners/posters/292174-1_t.jpg"),
        "bogus": URL(string: "qswmlkf"),
        "empty": nil,
        "poster": URL(string: "https://artworks.thetvdb.com/banners/v4/movie/330830/posters/660c5a1673668.jpg")
    ]
}

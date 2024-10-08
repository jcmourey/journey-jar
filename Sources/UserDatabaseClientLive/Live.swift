import Dependencies
import TVShowDatabaseClient
import FirebaseService
import TVShowModel

extension TVShowDatabaseClient: FirebaseDependencyKey, DependencyKey {
    public typealias Object = TVShow
    public static var liveValue: TVShowDatabaseClient = Self.liveValue()
}

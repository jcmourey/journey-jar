import ComposableArchitecture
import TVShow

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FirebaseStorageKey<TVShow>> {
   static var tvShows: Self {
       .firebase()
   }
}

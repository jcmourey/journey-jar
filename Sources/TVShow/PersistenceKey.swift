import ComposableArchitecture
import Persistence

extension PersistenceKey where Self == PersistenceKeyDefault<FirebaseStorageKey<TVShow>> {
   public static var tvShows: PersistenceKeyDefault<FirebaseStorageKey<TVShow>> {
       .firebase()
   }
}

import ComposableArchitecture

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FileStorageKey<UserInfo?>> {
   public static var user: Self {
       PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "user.json")), nil)
   }
}

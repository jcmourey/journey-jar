import ComposableArchitecture

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FileStorageKey<UserLogin?>> {
   public static var userLogin: Self {
       PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "user.json")), nil)
   }
}

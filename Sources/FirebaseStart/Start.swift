// firebase
import FirebaseAppCheck
import FirebaseCore
import FirebaseFirestore

public func startFirebase() {
    // To make AppAttest work in Simulator mode
    // source: https://firebase.google.com/docs/app-check/ios/debug-provider
    #if DEBUG
    let providerFactory = AppCheckDebugProviderFactory()
    #else
    let providerFactory = MyAppCheckProvider()
    #endif
    
    AppCheck.setAppCheckProviderFactory(providerFactory)
    FirebaseConfiguration.shared.setLoggerLevel(.min)
    FirebaseApp.configure()

    // Connect to firestore emulator (from firebaseCloudFunctions Webstorm project > firebase.json)
    #if DEBUG
    let settings = Firestore.firestore().settings
    settings.host = "127.0.0.1:8080"
    settings.cacheSettings = MemoryCacheSettings()
    settings.isSSLEnabled = false
    Firestore.firestore().settings = settings
    #endif
}

class MyAppCheckProvider: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        AppAttestProvider(app: app)
    }
}

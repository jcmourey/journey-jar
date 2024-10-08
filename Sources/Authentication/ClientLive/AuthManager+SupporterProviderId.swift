// firebase
import FirebaseAuth

extension AuthManager {
    enum SupportedProviderId {
        case apple
        case google
        
        init(rawValue: String?) throws {
            guard let rawValue else {
                throw AuthError.noProvider
            }
            switch rawValue {
            case AuthProviderID.apple.rawValue: self = .apple
            case AuthProviderID.google.rawValue: self = .google
            default: throw AuthError.unknownProvider(rawValue)
            }
        }
    }
}

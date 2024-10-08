import FirebaseAuth

extension AuthManager {
    enum SupportedProviderId: RawRepresentable {
        case apple
        case google
        
        init(rawValue: String) throws {
            switch rawValue {
            case AuthProviderID.apple.rawValue, AuthProviderID.google.rawValue: return
            default: throw AuthError.unknownProvider(rawValue)
            }
        }
        
        var rawValue: String {
            switch self {
            case .apple: SupportedProviderId.apple.rawValue
            case .google: AuthProviderID.google.rawValue
            }
        }
    }
}

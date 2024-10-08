import SwiftUI

// models
import UserModel

// UI elements
import Styleguide

public struct ProfileLabel: View {
    let authState: AuthState
    let photoURL: URL?
    
    public init(authState: AuthState, photoURL: URL?) {
        self.authState = authState
        self.photoURL = photoURL
    }
    
    public var body: some View {
        switch authState {
        case .signedOut, .guest:
            Text("Sign In")
        case .signedIn:
            ProfileImage(authState: authState, photoURL: photoURL)
                .frame(width: 35)
        }
    }
}

public struct ProfileImage: View {
    let authState: AuthState
    let photoURL: URL?
    
    public init(authState: AuthState, photoURL: URL?) {
        self.authState = authState
        self.photoURL = photoURL
    }
    
    public var body: some View {
        if let photoURL {
            Thumbnail(url: photoURL)
        } else {
            Image(systemName: userSystemImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }

    var userSystemImage: String {
        switch authState {
        case .signedOut: "person.slash"
        case .guest: "person"
        case .signedIn: "person.badge.shield.checkmark.fill"
        }
    }
}

#Preview {
    Form {
        ProfileLabel(authState: .signedIn, photoURL: nil)
        ProfileLabel(authState: .guest, photoURL: nil)
        ProfileLabel(authState: .signedOut, photoURL: nil)
    }
}


import FirebaseAuthUI
import UserLogin

func update(user: inout UserLogin?) {
    guard let currentUser = Auth.auth().currentUser else {
        return
    }
    
    let provider = currentUser.providerData.first
    
    user = UserLogin(
        id: UserLogin.ID(),
        uid: currentUser.uid,
        name: user?.name,
        photoURL: currentUser.photoURL,
        isAnonymous: currentUser.isAnonymous,
        isEmailVerified: currentUser.isEmailVerified,
        creationDate: currentUser.metadata.creationDate,
        lastSignInDate: currentUser.metadata.lastSignInDate,
        tenantID: currentUser.tenantID,
        email: currentUser.email,
        phoneNumber: currentUser.phoneNumber,
        signInProvider: provider?.providerID,
        signInName: provider?.displayName
    )
}

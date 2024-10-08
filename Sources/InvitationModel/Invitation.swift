import Foundation

struct Invitation: Transferable {
    let code: String
    let creationDate: Date

    static var transferRepresentation: some TransferRepresentation {
        // Define a representation for copying the invitation code
        ProxyRepresentation { invitation in
            return invitation.code
        }
    }
}

// Generate an invitation code
func generateInvitationCode() -> String {
    return UUID().uuidString
}

// Save invitation code in Firestore
func saveInvitationCode(teamId: String, code: String) {
    let invitationData: [String: Any] = ["teamId": teamId, "createdAt": Timestamp()]
    db.collection("invitations").document(code).setData(invitationData) { error in
        if let error = error {
            print("Error saving invitation code: \(error)")
        } else {
            print("Invitation code saved")
        }
    }
}

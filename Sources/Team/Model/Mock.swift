// pointfree
import IdentifiedCollections

// models
import UserModel

public extension Team {
    static let mockTeams: IdentifiedArrayOf<Team> = {
        let teams = generateRandomSubsets(from: UserModel.mockUsers, numberOfSubsets: 5)
            .enumerated()
            .map { index, users in
                let uids = users.map(\.uid)
                let members = users.map { TeamMember(from: $0, joinDate: .now) }
                return Team(id: ID(), name: "Team \(index)", dateAdded: .now, dateModified: .now, ownerId: uids[0], memberIds: uids, memberDetails: members)
            }
        return IdentifiedArray(uniqueElements: teams)
    }()
    
    static let mockTeamsList: [IdentifiedArrayOf<Team>] = {
        generateRandomSubsets(from: Team.mockTeams, numberOfSubsets: 5)
    }()
}

// Function to generate random subsets
func generateRandomSubsets<C: RangeReplaceableCollection>(from collection: C, numberOfSubsets: Int) -> [C] {
    var subsets: [C] = []
    
    for _ in 1...numberOfSubsets {
        let randomSize = Int.random(in: 1...collection.count) // Random subset size from 1 to array.count
        let randomSubset = C(collection.shuffled().prefix(randomSize)) // Generate random subset
        subsets.append(randomSubset)
    }
    
    return subsets
}

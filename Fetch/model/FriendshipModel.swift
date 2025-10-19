//
//  FriendshipModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

enum FriendshipStatus: String, Codable {
    case pending
    case accepted
    case blocked
}

struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?
    
    var userId1: String            // First user (alphabetically)
    var userId2: String            // Second user (alphabetically)
    var status: FriendshipStatus
    var initiatedBy: String        // Who sent the request
    var createdAt: Timestamp
    var acceptedAt: Timestamp?
    
    // Cached data for performance
    var user1Name: String
    var user2Name: String
    var user1Username: String
    var user2Username: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId1, userId2, status, initiatedBy
        case createdAt, acceptedAt
        case user1Name, user2Name
        case user1Username, user2Username
    }
    
    // Helper to get the other user's ID
    func otherUserId(currentUserId: String) -> String {
        return userId1 == currentUserId ? userId2 : userId1
    }
    
    // Helper to get the other user's name
    func otherUserName(currentUserId: String) -> String {
        return userId1 == currentUserId ? user2Name : user1Name
    }
    
    // Helper to get the other user's username
    func otherUsername(currentUserId: String) -> String {
        return userId1 == currentUserId ? user2Username : user1Username
    }
}

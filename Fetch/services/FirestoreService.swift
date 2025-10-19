//
//  FirestoreService.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw FirestoreError.invalidUserId
        }
        
        var userData = user
        userData.createdAt = Timestamp()
        userData.lastActive = Timestamp()
        
        try db.collection("users").document(userId).setData(from: userData)
    }
    
    func getUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard document.exists else {
            throw FirestoreError.userNotFound
        }
        return try document.data(as: User.self)
    }
    
    func updateUser(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        return snapshot.documents.isEmpty
    }
    
    func isStudentIdAvailable(_ studentId: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments()
        return snapshot.documents.isEmpty
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let lowercaseQuery = query.lowercased()
        
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: lowercaseQuery)
            .whereField("username", isLessThanOrEqualTo: lowercaseQuery + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func updateLastActive(userId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "lastActive": Timestamp()
        ])
    }
    
    // Real-time listener for user data
    func listenToUser(userId: String, completion: @escaping (User?) -> Void) -> ListenerRegistration {
        return db.collection("users").document(userId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                let user = try? snapshot.data(as: User.self)
                completion(user)
            }
    }
    
    // MARK: - Friendship Operations
    
    func sendFriendRequest(from senderId: String, to receiverId: String) async throws {
        // Check if friendship already exists
        let existing = try await getFriendship(userId1: senderId, userId2: receiverId)
        if existing != nil {
            throw FirestoreError.friendshipExists
        }
        
        let sender = try await getUser(userId: senderId)
        let receiver = try await getUser(userId: receiverId)
        
        // Store userIds alphabetically to prevent duplicates
        let sortedIds = [senderId, receiverId].sorted()
        
        let friendship = Friendship(
            userId1: sortedIds[0],
            userId2: sortedIds[1],
            status: .pending,
            initiatedBy: senderId,
            createdAt: Timestamp(),
            acceptedAt: nil,
            user1Name: sortedIds[0] == senderId ? sender.name : receiver.name,
            user2Name: sortedIds[1] == senderId ? sender.name : receiver.name,
            user1Username: sortedIds[0] == senderId ? sender.username : receiver.username,
            user2Username: sortedIds[1] == senderId ? sender.username : receiver.username
        )
        
        try db.collection("friendships").addDocument(from: friendship)
        
        // Create notification for receiver
        try await createNotification(
            userId: receiverId,
            type: .friendRequest,
            title: "New friend request",
            message: "\(sender.name) wants to be friends",
            relatedUserId: senderId
        )
    }
    
    func acceptFriendRequest(friendshipId: String, acceptedBy: String) async throws {
        try await db.collection("friendships").document(friendshipId).updateData([
            "status": "accepted",
            "acceptedAt": Timestamp()
        ])
        
        // Get friendship to notify the requester
        let doc = try await db.collection("friendships").document(friendshipId).getDocument()
        let friendship = try doc.data(as: Friendship.self)
        
        // Notify the original requester
        let otherUserId = friendship.otherUserId(currentUserId: acceptedBy)
        let accepter = try await getUser(userId: acceptedBy)
        
        try await createNotification(
            userId: otherUserId,
            type: .friendAccepted,
            title: "Friend request accepted",
            message: "\(accepter.name) accepted your friend request",
            relatedUserId: acceptedBy,
            relatedFriendshipId: friendshipId
        )
    }
    
    func getFriendship(userId1: String, userId2: String) async throws -> Friendship? {
        let sortedIds = [userId1, userId2].sorted()
        
        let snapshot = try await db.collection("friendships")
            .whereField("userId1", isEqualTo: sortedIds[0])
            .whereField("userId2", isEqualTo: sortedIds[1])
            .getDocuments()
        
        return try snapshot.documents.first.flatMap { try $0.data(as: Friendship.self) }
    }
    
    func getFriends(userId: String) async throws -> [User] {
        // Query where user is userId1
        let snapshot1 = try await db.collection("friendships")
            .whereField("userId1", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()
        
        // Query where user is userId2
        let snapshot2 = try await db.collection("friendships")
            .whereField("userId2", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()
        
        var friendIds: Set<String> = []
        
        for doc in snapshot1.documents {
            let friendship = try doc.data(as: Friendship.self)
            friendIds.insert(friendship.userId2)
        }
        
        for doc in snapshot2.documents {
            let friendship = try doc.data(as: Friendship.self)
            friendIds.insert(friendship.userId1)
        }
        
        // Fetch all friend users
        var friends: [User] = []
        for friendId in friendIds {
            if let friend = try? await getUser(userId: friendId) {
                friends.append(friend)
            }
        }
        
        // Sort by points gifted (most generous first)
        return friends.sorted { $0.totalPointsGifted > $1.totalPointsGifted }
    }
    
    func getPendingFriendRequests(userId: String) async throws -> [(Friendship, User)] {
        // Get requests where user is userId2 and status is pending
        let snapshot = try await db.collection("friendships")
            .whereField("userId2", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        var requests: [(Friendship, User)] = []
        
        for doc in snapshot.documents {
            let friendship = try doc.data(as: Friendship.self)
            // Get the requester's info
            if let requester = try? await getUser(userId: friendship.userId1) {
                requests.append((friendship, requester))
            }
        }
        
        return requests
    }
    
    func areFriends(userId1: String, userId2: String) async throws -> Bool {
        let friendship = try await getFriendship(userId1: userId1, userId2: userId2)
        return friendship?.status == .accepted
    }
    
    // MARK: - Transaction Operations
    
    func sendGift(from senderId: String, to receiverId: String, amount: Int, message: String?) async throws {
        // Get both users
        let sender = try await getUser(userId: senderId)
        let receiver = try await getUser(userId: receiverId)
        
        // Validate sender has enough points
        guard sender.points >= amount else {
            throw FirestoreError.insufficientPoints
        }
        
        // Create transaction
        let transaction = Transaction(
            type: .gift,
            fromUserId: senderId,
            toUserId: receiverId,
            amount: amount,
            message: message,
            status: .completed,
            createdAt: Timestamp(),
            completedAt: Timestamp(),
            fromUserName: sender.name,
            toUserName: receiver.name,
            fromUsername: sender.username,
            toUsername: receiver.username
        )
        
        // Save transaction
        try db.collection("transactions").addDocument(from: transaction)
        
        // Update sender points
        try await db.collection("users").document(senderId).updateData([
            "points": FieldValue.increment(Int64(-amount)),
            "totalPointsGifted": FieldValue.increment(Int64(amount)),
            "giftsGiven": FieldValue.increment(Int64(1))
        ])
        
        // Update receiver points
        try await db.collection("users").document(receiverId).updateData([
            "points": FieldValue.increment(Int64(amount)),
            "totalPointsEarned": FieldValue.increment(Int64(amount)),
            "giftsReceived": FieldValue.increment(Int64(1))
        ])
        
        // Create notification
        try await createNotification(
            userId: receiverId,
            type: .giftReceived,
            title: "Points received!",
            message: "\(sender.name) sent you \(amount) points",
            relatedUserId: senderId
        )
    }
    
    func getTransactions(userId: String, limit: Int = 20) async throws -> [Transaction] {
        // Get sent transactions
        let sentSnapshot = try await db.collection("transactions")
            .whereField("fromUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit / 2)
            .getDocuments()
        
        // Get received transactions
        let receivedSnapshot = try await db.collection("transactions")
            .whereField("toUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit / 2)
            .getDocuments()
        
        var transactions: [Transaction] = []
        
        transactions += try sentSnapshot.documents.compactMap { try $0.data(as: Transaction.self) }
        transactions += try receivedSnapshot.documents.compactMap { try $0.data(as: Transaction.self) }
        
        // Sort by date
        return transactions
            .sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
            .prefix(limit)
            .map { $0 }
    }
    
    // Real-time listener for transactions
    func listenToTransactions(userId: String, completion: @escaping ([Transaction]) -> Void) -> ListenerRegistration {
        // Note: We can only listen to one query at a time, so we'll listen to received transactions
        // For a complete solution, we'd need to maintain two listeners
        return db.collection("transactions")
            .whereField("toUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion([])
                    return
                }
                let transactions = snapshot.documents.compactMap { try? $0.data(as: Transaction.self) }
                completion(transactions)
            }
    }
    
    // MARK: - Notification Operations
    
    func createNotification(
        userId: String,
        type: NotificationType,
        title: String,
        message: String,
        relatedUserId: String? = nil,
        relatedTransactionId: String? = nil,
        relatedFriendshipId: String? = nil
    ) async throws {
        let notification = AppNotification(
            userId: userId,
            type: type,
            title: title,
            message: message,
            relatedUserId: relatedUserId,
            relatedTransactionId: relatedTransactionId,
            relatedFriendshipId: relatedFriendshipId,
            read: false,
            createdAt: Timestamp(),
            readAt: nil,
            actionUrl: nil
        )
        
        try db.collection("notifications").addDocument(from: notification)
    }
    
    func getNotifications(userId: String, limit: Int = 50) async throws -> [AppNotification] {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: AppNotification.self) }
    }
    
    func markNotificationRead(notificationId: String) async throws {
        try await db.collection("notifications").document(notificationId).updateData([
            "read": true,
            "readAt": Timestamp()
        ])
    }
    
    func getUnreadCount(userId: String) async throws -> Int {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("read", isEqualTo: false)
            .getDocuments()
        
        return snapshot.documents.count
    }
    
    // Real-time listener for notifications
    func listenToNotifications(userId: String, completion: @escaping ([AppNotification]) -> Void) -> ListenerRegistration {
        return db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion([])
                    return
                }
                let notifications = snapshot.documents.compactMap { try? $0.data(as: AppNotification.self) }
                completion(notifications)
            }
    }
    
    // MARK: - Leaderboard Operations
    
    func getLeaderboard(limit: Int = 100) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .order(by: "totalPointsGifted", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func getUserRank(userId: String) async throws -> Int {
        let user = try await getUser(userId: userId)
        
        let snapshot = try await db.collection("users")
            .whereField("totalPointsGifted", isGreaterThan: user.totalPointsGifted)
            .getDocuments()
        
        return snapshot.documents.count + 1
    }
}

// MARK: - Error Types

enum FirestoreError: LocalizedError {
    case invalidUserId
    case userNotFound
    case insufficientPoints
    case friendshipExists
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "Invalid user ID"
        case .userNotFound:
            return "User not found"
        case .insufficientPoints:
            return "Not enough points to complete this transaction"
        case .friendshipExists:
            return "Friendship already exists"
        }
    }
}

🏗️ FETCH CAMPUS - COMPLETE BUILD GUIDE

## 📊 DATABASE SCHEMA DESIGN

### Overview

Fetch Campus uses Firebase Firestore with the following collections:

```
Firestore Database
├── users/                    (Main user profiles)
├── friendships/              (Friend relationships)
├── transactions/             (Point transfers/gifts)
├── notifications/            (User notifications)
└── leaderboard_cache/        (Pre-calculated leaderboard data)
```

---

### Collection 1: `users/`

**Purpose:** Store all user profile information

**Document ID:** Firebase Auth UID

**Schema:**

```swift
struct User: Codable, Identifiable {
    @DocumentID var id: String?

    // Profile
    var name: String                   // "Madison Chen"
    var username: String               // "madisonc" (unique, indexed)
    var email: String                  // "madison@wisc.edu"
    var studentId: String              // "9081234567" (unique, indexed)
    var school: String                 // "University of Wisconsin-Madison"

    // Points & Stats
    var points: Int                    // Current balance (default: 500)
    var totalPointsEarned: Int         // Lifetime earned (default: 500)
    var totalPointsGifted: Int         // Lifetime given (default: 0)
    var giftsGiven: Int                // Count of gifts sent (default: 0)
    var giftsReceived: Int             // Count of gifts received (default: 0)

    // Ranking
    var rank: Int                      // Current rank position
    var generosityLevel: String        // "Newbie", "Helper", "Giver", etc.
    var generosityScore: Int           // 0-100 (based on gifts given)

    // Metadata
    var createdAt: Timestamp           // Account creation
    var emailVerified: Bool            // Verification status
    var profileImageUrl: String?       // Optional photo URL
    var lastActive: Timestamp          // Last activity
    var achievements: [String]         // Achievement IDs
    var isPrivate: Bool                // Profile visibility
}
```

**Firestore Indexes Required:**

-  Single field: `username` (Ascending) - for search & uniqueness
-  Single field: `studentId` (Ascending) - for uniqueness check
-  Single field: `points` (Descending) - for leaderboard
-  Single field: `totalPointsGifted` (Descending) - for ranking

**Security Rules:**

```
match /users/{userId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && request.auth.uid == userId &&
                !request.resource.data.diff(resource.data).affectedKeys()
                  .hasAny(['points', 'rank']);
  allow delete: if false;
}
```

---

### Collection 2: `friendships/`

**Purpose:** Store friend relationships

**Document ID:** Auto-generated

**Schema:**

```swift
struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?

    var userId1: String                // First user (alphabetically)
    var userId2: String                // Second user (alphabetically)
    var status: String                 // "pending", "accepted", "blocked"
    var initiatedBy: String            // Who sent request
    var createdAt: Timestamp           // When created
    var acceptedAt: Timestamp?         // When accepted (nil if pending)

    // Cached data for performance
    var user1Name: String
    var user2Name: String
    var user1Username: String
    var user2Username: String
}

enum FriendshipStatus: String, Codable {
    case pending
    case accepted
    case blocked
}
```

**Why userId1/userId2 alphabetically?**

-  Prevents duplicates (A→B vs B→A)
-  Simpler queries

**Firestore Indexes Required:**

-  Composite: `userId1` (Ascending) + `status` (Ascending)
-  Composite: `userId2` (Ascending) + `status` (Ascending)

**Security Rules:**

```
match /friendships/{friendshipId} {
  allow read: if request.auth != null &&
              (resource.data.userId1 == request.auth.uid ||
               resource.data.userId2 == request.auth.uid);
  allow create: if request.auth != null &&
                (request.resource.data.userId1 == request.auth.uid ||
                 request.resource.data.userId2 == request.auth.uid);
  allow update: if request.auth != null &&
                (resource.data.userId1 == request.auth.uid ||
                 resource.data.userId2 == request.auth.uid);
  allow delete: if request.auth != null &&
                (resource.data.userId1 == request.auth.uid ||
                 resource.data.userId2 == request.auth.uid);
}
```

---

### Collection 3: `transactions/`

**Purpose:** Record all point transfers

**Document ID:** Auto-generated

**Schema:**

```swift
struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?

    var type: String                   // "gift", "bonus", "earned", "penalty"
    var fromUserId: String?            // Sender (nil for bonuses)
    var toUserId: String               // Receiver
    var amount: Int                    // Points (always positive)
    var message: String?               // Optional message
    var status: String                 // "pending", "completed", "failed"
    var createdAt: Timestamp
    var completedAt: Timestamp?

    // Cached data
    var fromUserName: String?
    var toUserName: String
    var fromUsername: String?
    var toUsername: String
}

enum TransactionType: String, Codable {
    case gift
    case bonus
    case earned
    case penalty
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}
```

**Firestore Indexes Required:**

-  Composite: `toUserId` (Ascending) + `createdAt` (Descending)
-  Composite: `fromUserId` (Ascending) + `createdAt` (Descending)
-  Single field: `createdAt` (Descending) - for global feed

**Security Rules:**

```
match /transactions/{transactionId} {
  allow read: if request.auth != null &&
              (resource.data.fromUserId == request.auth.uid ||
               resource.data.toUserId == request.auth.uid);
  allow write: if false; // Cloud Functions only for atomic operations
}
```

---

### Collection 4: `notifications/`

**Purpose:** User notifications

**Document ID:** Auto-generated

**Schema:**

```swift
struct AppNotification: Codable, Identifiable {
    @DocumentID var id: String?

    var userId: String                 // Notification owner
    var type: String                   // Notification type
    var title: String                  // "Jake sent you points!"
    var message: String                // Full message
    var relatedUserId: String?         // Related user
    var relatedTransactionId: String?  // Related transaction
    var relatedFriendshipId: String?   // Related friendship
    var read: Bool                     // Read status
    var createdAt: Timestamp
    var readAt: Timestamp?
    var actionUrl: String?             // Deep link
}

enum NotificationType: String, Codable {
    case giftReceived = "gift_received"
    case friendRequest = "friend_request"
    case friendAccepted = "friend_accepted"
    case achievementUnlocked = "achievement_unlocked"
}
```

**Firestore Indexes Required:**

-  Composite: `userId` (Ascending) + `read` (Ascending) + `createdAt` (Descending)

**Security Rules:**

```
match /notifications/{notificationId} {
  allow read: if request.auth != null &&
              resource.data.userId == request.auth.uid;
  allow create: if false; // Cloud Functions only
  allow update: if request.auth != null &&
                resource.data.userId == request.auth.uid &&
                request.resource.data.diff(resource.data).affectedKeys()
                  .hasOnly(['read', 'readAt']);
  allow delete: if false;
}
```

---

### Collection 5: `leaderboard_cache/`

**Purpose:** Pre-calculated leaderboard (optional, for performance)

**Document ID:** `weekly`, `monthly`, `alltime`

**Schema:**

```swift
struct LeaderboardCache: Codable, Identifiable {
    @DocumentID var id: String?        // "weekly", "monthly", "alltime"

    var type: String                   // Same as ID
    var topUsers: [LeaderboardEntry]   // Top 100 users
    var lastUpdated: Timestamp
    var totalUsers: Int
}

struct LeaderboardEntry: Codable {
    var userId: String
    var name: String
    var username: String
    var school: String
    var giftsGiven: Int
    var totalPointsGifted: Int
    var rank: Int
}
```

**Security Rules:**

```
match /leaderboard_cache/{cacheId} {
  allow read: if request.auth != null;
  allow write: if false; // Cloud Functions only
}
```

---

## 🔐 COMPLETE FIRESTORE SECURITY RULES

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update: if isSignedIn() && isOwner(userId) &&
                    !request.resource.data.diff(resource.data).affectedKeys()
                      .hasAny(['points', 'rank', 'totalPointsEarned']);
      allow delete: if false;
    }

    match /friendships/{friendshipId} {
      allow read: if isSignedIn() &&
                  (resource.data.userId1 == request.auth.uid ||
                   resource.data.userId2 == request.auth.uid);
      allow create: if isSignedIn() &&
                    (request.resource.data.userId1 == request.auth.uid ||
                     request.resource.data.userId2 == request.auth.uid);
      allow update: if isSignedIn() &&
                    (resource.data.userId1 == request.auth.uid ||
                     resource.data.userId2 == request.auth.uid);
      allow delete: if isSignedIn() &&
                    (resource.data.userId1 == request.auth.uid ||
                     resource.data.userId2 == request.auth.uid);
    }

    match /transactions/{transactionId} {
      allow read: if isSignedIn() &&
                  (resource.data.fromUserId == request.auth.uid ||
                   resource.data.toUserId == request.auth.uid);
      allow write: if false;
    }

    match /notifications/{notificationId} {
      allow read: if isSignedIn() &&
                  resource.data.userId == request.auth.uid;
      allow create: if false;
      allow update: if isSignedIn() &&
                    resource.data.userId == request.auth.uid &&
                    request.resource.data.diff(resource.data).affectedKeys()
                      .hasOnly(['read', 'readAt']);
      allow delete: if false;
    }

    match /leaderboard_cache/{cacheId} {
      allow read: if isSignedIn();
      allow write: if false;
    }
  }
}
```

---

## 🏗️ BUILD STEPS

**Complete each step fully before moving to next. Test thoroughly after each step.**

---

### **B-001**: Set up Firestore indexes

**Task:** Create required indexes in Firebase Console

**Steps:**

1. Firebase Console → Firestore Database → Indexes tab
2. Create these indexes:

**users collection:**

-  Field: `username`, Order: Ascending
-  Field: `studentId`, Order: Ascending
-  Field: `points`, Order: Descending
-  Field: `totalPointsGifted`, Order: Descending

**friendships collection:**

-  Composite: `userId1` Ascending + `status` Ascending
-  Composite: `userId2` Ascending + `status` Ascending

**transactions collection:**

-  Composite: `toUserId` Ascending + `createdAt` Descending
-  Composite: `fromUserId` Ascending + `createdAt` Descending
-  Field: `createdAt`, Order: Descending

**notifications collection:**

-  Composite: `userId` Ascending + `read` Ascending + `createdAt` Descending

**Verify:** All indexes show "Enabled" status

---

### **B-002**: Update data models with complete schemas

**Task:** Update all model files with complete Firestore-compatible schemas

**Files to update:**

**models/User.swift** - Add all fields from schema
**models/Friendship.swift** - Create with full schema
**models/Transaction.swift** - Create with full schema  
**models/AppNotification.swift** - Create with full schema

**Code for each file:**

```swift
// models/User.swift
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var username: String
    var email: String
    var studentId: String
    var school: String
    var points: Int
    var totalPointsEarned: Int
    var totalPointsGifted: Int
    var giftsGiven: Int
    var giftsReceived: Int
    var rank: Int
    var generosityLevel: String
    var generosityScore: Int
    var createdAt: Timestamp
    var emailVerified: Bool
    var profileImageUrl: String?
    var lastActive: Timestamp
    var achievements: [String]
    var isPrivate: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name, username, email, studentId, school
        case points, totalPointsEarned, totalPointsGifted
        case giftsGiven, giftsReceived, rank
        case generosityLevel, generosityScore
        case createdAt, emailVerified, profileImageUrl
        case lastActive, achievements, isPrivate
    }

    var pointsExpirationDays: Int {
        let calendar = Calendar.current
        let createdDate = createdAt.dateValue()
        let expirationDate = calendar.date(byAdding: .day, value: 30, to: createdDate)!
        let days = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return max(0, days)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        studentId = try container.decode(String.self, forKey: .studentId)
        school = try container.decode(String.self, forKey: .school)
        points = try container.decodeIfPresent(Int.self, forKey: .points) ?? 500
        totalPointsEarned = try container.decodeIfPresent(Int.self, forKey: .totalPointsEarned) ?? 500
        totalPointsGifted = try container.decodeIfPresent(Int.self, forKey: .totalPointsGifted) ?? 0
        giftsGiven = try container.decodeIfPresent(Int.self, forKey: .giftsGiven) ?? 0
        giftsReceived = try container.decodeIfPresent(Int.self, forKey: .giftsReceived) ?? 0
        rank = try container.decodeIfPresent(Int.self, forKey: .rank) ?? 999
        generosityLevel = try container.decodeIfPresent(String.self, forKey: .generosityLevel) ?? "Newbie"
        generosityScore = try container.decodeIfPresent(Int.self, forKey: .generosityScore) ?? 0
        createdAt = try container.decode(Timestamp.self, forKey: .createdAt)
        emailVerified = try container.decode(Bool.self, forKey: .emailVerified)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        lastActive = try container.decode(Timestamp.self, forKey: .lastActive)
        achievements = try container.decodeIfPresent([String].self, forKey: .achievements) ?? []
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
    }
}
```

```swift
// models/Friendship.swift
import Foundation
import FirebaseFirestore

struct Friendship: Codable, Identifiable {
    @DocumentID var id: String?
    var userId1: String
    var userId2: String
    var status: FriendshipStatus
    var initiatedBy: String
    var createdAt: Timestamp
    var acceptedAt: Timestamp?
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
}

enum FriendshipStatus: String, Codable {
    case pending
    case accepted
    case blocked
}
```

```swift
// models/Transaction.swift
import Foundation
import FirebaseFirestore

struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?
    var type: TransactionType
    var fromUserId: String?
    var toUserId: String
    var amount: Int
    var message: String?
    var status: TransactionStatus
    var createdAt: Timestamp
    var completedAt: Timestamp?
    var fromUserName: String?
    var toUserName: String
    var fromUsername: String?
    var toUsername: String

    enum CodingKeys: String, CodingKey {
        case id, type, fromUserId, toUserId, amount, message, status
        case createdAt, completedAt
        case fromUserName, toUserName, fromUsername, toUsername
    }

    var displayText: String {
        switch type {
        case .gift:
            if let fromName = fromUserName {
                return amount > 0 ? "\(fromName) sent you \(amount) points" : "You sent \(abs(amount)) points to \(toUserName)"
            }
            return "Gift transaction"
        case .bonus:
            return "Weekly bonus earned"
        case .earned:
            return message ?? "Points earned"
        case .penalty:
            return message ?? "Points deducted"
        }
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt.dateValue(), relativeTo: Date())
    }

    var amountText: String {
        let prefix = (fromUserId != nil && type == .gift) ? "-" : "+"
        return "\(prefix)\(amount)"
    }

    var amountColor: Color {
        (fromUserId != nil && type == .gift) ? Color(hex: "8E8E93") : Color(hex: "34C759")
    }
}

enum TransactionType: String, Codable {
    case gift
    case bonus
    case earned
    case penalty
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}
```

```swift
// models/AppNotification.swift
import Foundation
import FirebaseFirestore

struct AppNotification: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var type: NotificationType
    var title: String
    var message: String
    var relatedUserId: String?
    var relatedTransactionId: String?
    var relatedFriendshipId: String?
    var read: Bool
    var createdAt: Timestamp
    var readAt: Timestamp?
    var actionUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, type, title, message
        case relatedUserId, relatedTransactionId, relatedFriendshipId
        case read, createdAt, readAt, actionUrl
    }
}

enum NotificationType: String, Codable {
    case giftReceived = "gift_received"
    case friendRequest = "friend_request"
    case friendAccepted = "friend_accepted"
    case achievementUnlocked = "achievement_unlocked"
}
```

**Test:** Models compile without errors

---

### **B-003**: Build complete FirestoreService

**Task:** Create comprehensive Firestore service with all database operations

**File:** services/FirestoreService.swift

**Implementation:**

```swift
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
            .whereField("username", isEqualTo: username)
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

    // MARK: - Friendship Operations

    func sendFriendRequest(from senderId: String, to receiverId: String) async throws {
        let sender = try await getUser(userId: senderId)
        let receiver = try await getUser(userId: receiverId)

        let friendship = Friendship(
            userId1: min(senderId, receiverId),
            userId2: max(senderId, receiverId),
            status: .pending,
            initiatedBy: senderId,
            createdAt: Timestamp(),
            user1Name: senderId < receiverId ? sender.name : receiver.name,
            user2Name: senderId < receiverId ? receiver.name : sender.name,
            user1Username: senderId < receiverId ? sender.username : receiver.username,
            user2Username: senderId < receiverId ? receiver.username : sender.username
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

    func acceptFriendRequest(friendshipId: String) async throws {
        try await db.collection("friendships").document(friendshipId).updateData([
            "status": "accepted",
            "acceptedAt": Timestamp()
        ])
    }

    func getFriends(userId: String) async throws -> [User] {
        let snapshot1 = try await db.collection("friendships")
            .whereField("userId1", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()

        let snapshot2 = try await db.collection("friendships")
            .whereField("userId2", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()

        var friendIds: Set = []

        for doc in snapshot1.documents {
            let friendship = try doc.data(as: Friendship.self)
            friendIds.insert(friendship.userId2)
        }

        for doc in snapshot2.documents {
            let friendship = try doc.data(as: Friendship.self)
            friendIds.insert(friendship.userId1)
        }

        var friends: [User] = []
        for friendId in friendIds {
            if let friend = try? await getUser(userId: friendId) {
                friends.append(friend)
            }
        }

        return friends.sorted { $0.totalPointsGifted > $1.totalPointsGifted }
    }

    func areFriends(userId1: String, userId2: String) async throws -> Bool {
        let sortedIds = [userId1, userId2].sorted()

        let snapshot = try await db.collection("friendships")
            .whereField("userId1", isEqualTo: sortedIds[0])
            .whereField("userId2", isEqualTo: sortedIds[1])
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()

        return !snapshot.documents.isEmpty
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
        let sentSnapshot = try await db.collection("transactions")
            .whereField("fromUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit / 2)
            .getDocuments()

        let receivedSnapshot = try await db.collection("transactions")
            .whereField("toUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit / 2)
            .getDocuments()

        var transactions: [Transaction] = []

        transactions += try sentSnapshot.documents.compactMap { try $0.data(as: Transaction.self) }
        transactions += try receivedSnapshot.documents.compactMap { try $0.data(as: Transaction.self) }

        return transactions.sorted { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Notification Operations

    func createNotification(userId: String, type: NotificationType, title: String, message: String, relatedUserId: String? = nil) async throws {
        let notification = AppNotification(
            userId: userId,
            type: type,
            title: title,
            message: message,
            relatedUserId: relatedUserId,
            read: false,
            createdAt: Timestamp()
        )

        try db.collection("notifications").addDocument(from: notification)
    }

    func getNotifications(userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
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

enum FirestoreError: LocalizedError {
    case invalidUserId
    case userNotFound
    case insufficientPoints

    var errorDescription: String? {
        switch self {
        case .invalidUserId: return "Invalid user ID"
        case .userNotFound: return "User not found"
        case .insufficientPoints: return "Not enough points"
        }
    }
}
```

**Test:** All methods compile and work with test data

---

### **B-004**: Update HomeView to use real Firebase data

**Task:** Replace sample data with live Firestore queries

**File:** views/Main/HomeView.swift

**Changes:**

1. Remove sample activities
2. Fetch real transactions
3. Use real user points
4. Add real-time listeners

**Test:**

-  Points display correctly
-  Activity feed shows real data
-  Updates when data changes

---

### **B-005**: Build FriendsView with real data

**Task:** Build complete friends list screen

**File:** views/Main/FriendsView.swift

**Features:**

-  Fetch friends from Firestore
-  Show friend count
-  Display ranked friends
-  Add friend button
-  Navigate to profiles

**Test:**

-  Friends load correctly
-  Count is accurate
-  Add friend works

---

### **B-006**: Build AddFriendView with search

**Task:** Create friend search and add functionality

**File:** views/Main/AddFriendView.swift

**Features:**

-  Search users by username
-  Show search results
-  Send friend requests
-  Handle different states

**Test:**

-  Search finds users
-  Friend requests send successfully
-  States update correctly

---

### **B-007**: Build GiftPointsView

**Task:** Build gift sending interface

**File:** views/Main/GiftPointsView.swift

**Features:**

-  Select friend recipient
-  Choose amount with presets
-  Add optional message
-  Validate balance
-  Send gift via Firestore

**Test:**

-  Can select friend
-  Amount validation works
-  Gift sends successfully
-  Balances update correctly

---

### **B-008**: Build GiftSuccessView modal

**Task:** Create success celebration modal

**File:** views/Main/GiftSuccessView.swift

**Features:**

-  Animated checkmark
-  Show transaction details
-  Display new balance
-  Navigate to leaderboard or close

**Test:**

-  Animation plays smoothly
-  Data displays correctly
-  Navigation works

---

### **B-009**: Build LeaderboardView

**Task:** Build leaderboard with real rankings

**File:** views/Main/LeaderboardView.swift

**Features:**

-  Top 3 podium visualization
-  Remaining users list
-  Highlight current user
-  Real-time rankings

**Test:**

-  Rankings are correct
-  Current user highlighted
-  Updates in real-time

---

### **B-010**: Update ProfileView with real data

**Task:** Add real activity and functional settings

**File:** views/Main/ProfileView.swift

**Features:**

-  Real recent activity
-  Functional settings
-  Working logout

**Test:**

-  Activity loads
-  Settings work
-  Logout successful

---

### **B-011**: Build settings screens

**Task:** Create placeholder settings screens

**Files:**

-  views/Settings/PrivacySettingsView.swift
-  views/Settings/HelpSupportView.swift
-  views/Settings/AboutView.swift

**Test:** All navigate correctly

---

### **B-012**: Add notification badge to bell

**Task:** Show unread count on notification icon

**File:** views/Main/HomeView.swift

**Test:** Badge shows correct count

---

### **B-013**: Test entire app end-to-end

**Task:** Complete testing with real data

**Test Scenarios:**

-  Sign up → Verify → Login
-  Add friends
-  Send gifts
-  Check leaderboard
-  View profile
-  Logout

**Fix all bugs found**

---

### **B-014**: Add loading states and error handling

**Task:** Improve UX with proper states

**Add to all views:**

-  Loading spinners
-  Error messages
-  Empty states
-  Retry buttons

**Test:** All states work correctly

---

### **B-015**: Add animations and polish

**Task:** Smooth transitions and animations

**Add:**

-  Tab transitions
-  Gift celebration
-  Points count-up
-  List stagger animations

**Test:** Animations feel smooth

---

### **B-016**: Test on different iPhone sizes

**Task:** Ensure UI works on all devices

**Test on:**

-  iPhone SE
-  iPhone 15
-  iPhone 15 Pro Max

**Fix:** Layout issues

---

### **B-017**: Test in dark mode

**Task:** Ensure dark mode compatibility

**Test:** All screens in dark mode
**Fix:** Contrast issues

---

### **B-018**: Final optimization

**Task:** Performance and bug fixes

**Optimize:**

-  Reduce Firestore reads
-  Cache data appropriately
-  Fix memory leaks

**Test:** No crashes, smooth performance

---

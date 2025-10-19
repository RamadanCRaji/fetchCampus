## 🏗️ BUILD: Complete Friend Request System

**Current State:** FriendsView exists but search doesn't work. No user profiles, no friend requests, no notifications.

**Goal:** Build Instagram-style friend system with search, requests, notifications, and profile viewing.

---

## 📋 FEATURE REQUIREMENTS

### 1. **Search Users**

-  Search by username or name
-  Show results as you type (debounced)
-  Display user avatar, name, username, school
-  Show current friendship status (Add/Pending/Friends)

### 2. **Add Friends**

-  Option A: "Add" button next to each search result
-  Option B: Tap user → view profile → "Add Friend" button
-  Send friend request → creates Firestore document
-  Button changes to "Pending" after sending

### 3. **Friend Requests**

-  Sender sees "Pending" status
-  Receiver gets notification
-  Notification shows in bell icon with badge count
-  Tap notification → opens requests list
-  Can Accept or Decline request

### 4. **User Profiles**

-  Tap any user → view their profile (read-only)
-  Shows: avatar, name, username, school, points, rank, gifts given
-  Cannot see their activity or friends list (privacy)
-  "Add Friend" button (if not friends)
-  "Remove Friend" button (if already friends)

### 5. **Notifications**

-  Bell icon in HomeView shows unread count
-  Tap bell → NotificationsView
-  Shows: friend requests, accepted requests, gifts received
-  Mark as read when viewed
-  Tap notification → navigate to relevant screen

---

## 🗂️ FILES TO CREATE/UPDATE

### New Files to Create:

1. `views/Main/AddFriendView.swift` - Search and add friends
2. `views/Main/UserProfileView.swift` - View other users' profiles
3. `views/Main/NotificationsView.swift` - Notification center
4. `views/Components/FriendRequestRow.swift` - Friend request UI component
5. `views/Components/NotificationRow.swift` - Notification UI component

### Files to Update:

1. `views/Main/FriendsView.swift` - Add navigation to AddFriendView
2. `views/Main/HomeView.swift` - Add notification bell with badge
3. `services/FirestoreService.swift` - Already has friend methods, may need updates
4. `models/AppNotification.swift` - Already exists

---

## 🏗️ BUILD STEP 1: Update AddFriendView with Working Search

**File:** `views/Main/AddFriendView.swift`

**Requirements:**

-  Search bar at top
-  Debounced search (wait 0.5s after typing stops)
-  Show loading spinner while searching
-  Display results in list
-  Each result shows:
   -  Avatar circle (with first letter of name)
   -  Name (bold)
   -  @username (gray)
   -  School (small, gray)
   -  Status button (Add/Pending/Friends)
-  Tap user → navigate to UserProfileView
-  Tap "Add" → send friend request, change to "Pending"

**Code Structure:**

```swift
import SwiftUI
import FirebaseFirestore

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var friendshipStatuses: [String: FriendshipStatus] = [:] // userId: status
    @State private var errorMessage: String?

    // Debounce timer
    @State private var searchTask: Task?

    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search by name or username", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color(hex: "F2F2F7"))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Results List
                if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchText.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)

                        Text("Search for friends")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Find people by name or username")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !isSearching {
                    // No results
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)

                        Text("No users found")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Try searching with a different name")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults) { user in
                                SearchResultRow(
                                    user: user,
                                    status: friendshipStatuses[user.id ?? ""] ?? .notFriends,
                                    onAddFriend: { sendFriendRequest(to: user) },
                                    onViewProfile: { /* Navigate to profile */ }
                                )
                            }
                        }
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: searchText) { newValue in
                // Cancel previous search
                searchTask?.cancel()

                // Debounce: wait 0.5s after typing stops
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)

                    if !Task.isCancelled {
                        await performSearch(query: newValue)
                    }
                }
            }
        }
    }

    func performSearch(query: String) async {
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            // Search users
            let users = try await FirestoreService.shared.searchUsers(query: query)

            // Filter out current user
            let filteredUsers = users.filter { $0.id != currentUserId }

            // Load friendship statuses for all results
            for user in filteredUsers {
                if let userId = user.id, let currentUserId = currentUserId {
                    let status = await getFriendshipStatus(between: currentUserId, and: userId)
                    friendshipStatuses[userId] = status
                }
            }

            searchResults = filteredUsers
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }

        isSearching = false
    }

    func getFriendshipStatus(between userId1: String, userId2: String) async -> FriendshipStatus {
        do {
            let isFriends = try await FirestoreService.shared.areFriends(userId1: userId1, userId2: userId2)
            if isFriends {
                return .friends
            }

            // Check if request is pending
            let hasPendingRequest = try await FirestoreService.shared.hasPendingFriendRequest(
                from: userId1,
                to: userId2
            )

            return hasPendingRequest ? .pending : .notFriends
        } catch {
            return .notFriends
        }
    }

    func sendFriendRequest(to user: User) {
        guard let currentUserId = currentUserId, let targetUserId = user.id else { return }

        Task {
            do {
                try await FirestoreService.shared.sendFriendRequest(
                    from: currentUserId,
                    to: targetUserId
                )

                // Update status
                friendshipStatuses[targetUserId] = .pending

            } catch {
                errorMessage = "Failed to send request: \(error.localizedDescription)"
            }
        }
    }
}

enum FriendshipStatus {
    case notFriends
    case pending
    case friends
}

struct SearchResultRow: View {
    let user: User
    let status: FriendshipStatus
    let onAddFriend: () -> Void
    let onViewProfile: () -> Void

    var body: some View {
        Button(action: onViewProfile) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color(hex: "E5E5EA"))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "007AFF"))
                    )

                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)

                    Text("@\(user.username)")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8E8E93"))

                    Text(user.school)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .lineLimit(1)
                }

                Spacer()

                // Action Button
                Button(action: {
                    if status == .notFriends {
                        onAddFriend()
                    }
                }) {
                    Text(statusButtonText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(statusButtonColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(statusButtonBackground)
                        .cornerRadius(8)
                }
                .disabled(status != .notFriends)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    var statusButtonText: String {
        switch status {
        case .notFriends: return "Add"
        case .pending: return "Pending"
        case .friends: return "Friends"
        }
    }

    var statusButtonColor: Color {
        switch status {
        case .notFriends: return .white
        case .pending: return Color(hex: "8E8E93")
        case .friends: return Color(hex: "34C759")
        }
    }

    var statusButtonBackground: Color {
        switch status {
        case .notFriends: return Color(hex: "007AFF")
        case .pending: return Color(hex: "F2F2F7")
        case .friends: return Color(hex: "E8F5E9")
        }
    }
}
```

**Missing FirestoreService Method - Add to `services/FirestoreService.swift`:**

```swift
func hasPendingFriendRequest(from senderId: String, to receiverId: String) async throws -> Bool {
    let sortedIds = [senderId, receiverId].sorted()

    let snapshot = try await db.collection("friendships")
        .whereField("userId1", isEqualTo: sortedIds[0])
        .whereField("userId2", isEqualTo: sortedIds[1])
        .whereField("status", isEqualTo: "pending")
        .getDocuments()

    return !snapshot.documents.isEmpty
}
```

---

## 🏗️ BUILD STEP 2: Create UserProfileView (Read-Only Profile)

**File:** `views/Main/UserProfileView.swift`

**Requirements:**

-  Similar to ProfileView but read-only
-  Shows: avatar, name, username, school, points, rank, gifts given
-  "Add Friend" button (if not friends yet)
-  "Pending" button (if request sent)
-  "Remove Friend" button (if already friends)
-  Cannot see their activity feed or friends list
-  Back button to return

**Code Structure:**

```swift
import SwiftUI

struct UserProfileView: View {
    let user: User
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var friendshipStatus: FriendshipStatus = .notFriends
    @State private var isLoading = true

    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 128, height: 128)

                        Circle()
                            .fill(Color(hex: "E3F2FD"))
                            .frame(width: 120, height: 120)

                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "007AFF"))
                    }

                    // Name
                    Text(user.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)

                    // Username
                    Text("@\(user.username)")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "8E8E93"))

                    // School Badge
                    HStack(spacing: 6) {
                        Text("🎓")
                            .font(.system(size: 16))
                        Text(user.school)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "007AFF"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "E3F2FD"))
                    .cornerRadius(20)

                    // Action Button
                    if isLoading {
                        ProgressView()
                            .frame(height: 44)
                    } else {
                        actionButton
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .padding(.horizontal, 16)

                // Stats Section
                HStack(spacing: 0) {
                    StatColumn(icon: "⭐", value: "\(user.points)", label: "Points")
                    StatColumn(icon: "🏆", value: "#\(user.rank)", label: "Rank", valueColor: Color(hex: "007AFF"))
                    StatColumn(icon: "🎁", value: "\(user.giftsGiven)", label: "Gifts Sent")
                }
                .padding(.vertical, 20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal, 16)

                // Privacy Notice
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "8E8E93"))

                    Text("Activity and friends are private")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .padding(.vertical, 40)

                Spacer()
            }
            .padding(.top, 16)
        }
        .background(Color(hex: "F2F2F7"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
        }
        .onAppear {
            loadFriendshipStatus()
        }
    }

    var actionButton: some View {
        Group {
            switch friendshipStatus {
            case .notFriends:
                Button(action: sendFriendRequest) {
                    Text("Add Friend")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color(hex: "007AFF"))
                        .cornerRadius(12)
                }

            case .pending:
                Text("Request Pending")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .frame(width: 200, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "8E8E93"), lineWidth: 2)
                    )

            case .friends:
                Button(action: removeFriend) {
                    Text("Remove Friend")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 200, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red, lineWidth: 2)
                        )
                }
            }
        }
    }

    func loadFriendshipStatus() {
        guard let currentUserId = currentUserId, let userId = user.id else { return }

        Task {
            let status = await getFriendshipStatus(between: currentUserId, and: userId)
            await MainActor.run {
                friendshipStatus = status
                isLoading = false
            }
        }
    }

    func getFriendshipStatus(between userId1: String, and userId2: String) async -> FriendshipStatus {
        do {
            let isFriends = try await FirestoreService.shared.areFriends(userId1: userId1, userId2: userId2)
            if isFriends {
                return .friends
            }

            let hasPending = try await FirestoreService.shared.hasPendingFriendRequest(from: userId1, to: userId2)
            return hasPending ? .pending : .notFriends
        } catch {
            return .notFriends
        }
    }

    func sendFriendRequest() {
        guard let currentUserId = currentUserId, let userId = user.id else { return }

        Task {
            do {
                try await FirestoreService.shared.sendFriendRequest(from: currentUserId, to: userId)
                friendshipStatus = .pending
            } catch {
                print("Failed to send friend request: \(error)")
            }
        }
    }

    func removeFriend() {
        // Implement unfriend logic
        guard let currentUserId = currentUserId, let userId = user.id else { return }

        Task {
            do {
                // Find and delete friendship document
                let sortedIds = [currentUserId, userId].sorted()
                let snapshot = try await Firestore.firestore()
                    .collection("friendships")
                    .whereField("userId1", isEqualTo: sortedIds[0])
                    .whereField("userId2", isEqualTo: sortedIds[1])
                    .whereField("status", isEqualTo: "accepted")
                    .getDocuments()

                for doc in snapshot.documents {
                    try await doc.reference.delete()
                }

                friendshipStatus = .notFriends
            } catch {
                print("Failed to remove friend: \(error)")
            }
        }
    }
}

struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    var valueColor: Color = .black

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(valueColor)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .frame(maxWidth: .infinity)
    }
}
```

---

## 🏗️ BUILD STEP 3: Update AddFriendView Navigation

**Update AddFriendView to navigate to UserProfileView:**

In `SearchResultRow`, update the `onViewProfile` action in `AddFriendView`:

```swift
NavigationLink(destination: UserProfileView(user: user).environmentObject(authManager)) {
    SearchResultRow(
        user: user,
        status: friendshipStatuses[user.id ?? ""] ?? .notFriends,
        onAddFriend: { sendFriendRequest(to: user) },
        onViewProfile: {}
    )
}
.buttonStyle(.plain)
```

---

## 🏗️ BUILD STEP 4: Create NotificationsView

**File:** `views/Main/NotificationsView.swift`

**Requirements:**

-  Shows all notifications (friend requests, accepted friends, gifts)
-  Friend requests section at top
-  Each request shows: avatar, name, "Accept" and "Decline" buttons
-  Recent activity below
-  Mark notifications as read when viewed
-  Empty state if no notifications

**Code Structure:**

```swift
import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var friendRequests: [Friendship] = []
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = true

    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Friend Requests Section
                    if !friendRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Friend Requests")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 16)

                            ForEach(friendRequests) { request in
                                FriendRequestRow(
                                    friendship: request,
                                    onAccept: { acceptRequest(request) },
                                    onDecline: { declineRequest(request) }
                                )
                            }
                        }
                    }

                    // Notifications Section
                    if !notifications.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activity")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 16)

                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification)
                            }
                        }
                    }

                    // Empty State
                    if friendRequests.isEmpty && notifications.isEmpty && !isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)

                            Text("No notifications")
                                .font(.system(size: 20, weight: .semibold))

                            Text("You're all caught up!")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    }

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(hex: "F2F2F7"))
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    func loadData() {
        guard let userId = currentUserId else { return }

        Task {
            do {
                async let requests = FirestoreService.shared.getFriendRequests(userId: userId)
                async let notifs = FirestoreService.shared.getNotifications(userId: userId)

                friendRequests = try await requests
                notifications = try await notifs

                // Mark notifications as read
                for notification in notifications where !notification.read {
                    try? await FirestoreService.shared.markNotificationRead(
                        notificationId: notification.id ?? ""
                    )
                }

                isLoading = false
            } catch {
                print("Error loading notifications: \(error)")
                isLoading = false
            }
        }
    }

    func acceptRequest(_ friendship: Friendship) {
        guard let friendshipId = friendship.id else { return }

        Task {
            do {
                try await FirestoreService.shared.acceptFriendRequest(friendshipId: friendshipId)

                // Remove from list
                friendRequests.removeAll { $0.id == friendshipId }

                // Create notification for sender
                let senderId = friendship.initiatedBy
                if let currentUser = authManager.currentUser {
                    try? await FirestoreService.shared.createNotification(
                        userId: senderId,
                        type: .friendAccepted,
                        title: "Friend request accepted",
                        message: "\(currentUser.name) accepted your friend request",
                        relatedUserId: currentUser.id
                    )
                }
            } catch {
                print("Error accepting request: \(error)")
            }
        }
    }

    func declineRequest(_ friendship: Friendship) {
        guard let friendshipId = friendship.id else { return }

        Task {
            do {
                // Delete the friendship document
                try await Firestore.firestore()
                    .collection("friendships")
                    .document(friendshipId)
                    .delete()

                // Remove from list
                friendRequests.removeAll { $0.id == friendshipId }
            } catch {
                print("Error declining request: \(error)")
            }
        }
    }
}
```

---

## 🏗️ BUILD STEP 5: Create FriendRequestRow Component

**File:** `views/Components/FriendRequestRow.swift`

```swift
import SwiftUI

struct FriendRequestRow: View {
    let friendship: Friendship
    let onAccept: () -> Void
    let onDecline: () -> Void

    var senderName: String {
        friendship.user1Name
    }

    var senderUsername: String {
        friendship.user1Username
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "E5E5EA"))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(senderName.prefix(1)).uppercased())
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(senderName)
                    .font(.system(size: 17, weight: .semibold))

                Text("@\(senderUsername)")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "8E8E93"))

                Text("wants to be friends")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 8) {
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "34C759"))
                        .cornerRadius(6)
                }

                Button(action: onDecline) {
                    Text("Decline")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "F2F2F7"))
                        .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal, 16)
    }
}
```

---

## 🏗️ BUILD STEP 6: Create NotificationRow Component

**File:** `views/Components/NotificationRow.swift`

```swift
import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification

    var icon: String {
        switch notification.type {
        case .giftReceived: return "🎁"
        case .friendRequest: return "👥"
        case .friendAccepted: return "✅"
        case .achievementUnlocked: return "🏆"
        default: return "📢"
        }
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(
            for: notification.createdAt.dateValue(),
            relativeTo: Date()
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Text(icon)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

                Text(notification.message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .lineLimit(2)

                Text(timeAgo)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "C7C7CC"))
            }

            Spacer()

            // Unread indicator
            if !notification.read {
                Circle()
                    .fill(Color(hex: "007AFF"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(notification.read ? Color.white : Color(hex: "E3F2FD").opacity(0.3))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}
```

---

## 🏗️ BUILD STEP 7: Add Notification Bell to HomeView

**File:** `views/Main/HomeView.swift`

**Add to top of struct:**

```swift
@State private var unreadNotificationCount: Int = 0
@State private var showNotifications = false
```

**Add notification bell button:**

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showNotifications = true }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "007AFF"))

                if unreadNotificationCount > 0 {
                    Text("\(unreadNotificationCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
        }
    }
}
.sheet(isPresented: $showNotifications) {
    NotificationsView()
        .environmentObject(authManager)
}
.onAppear {
    loadUnreadCount()
}
```

**Add method:**

```swift
func loadUnreadCount() {
    guard let userId = authManager.currentUser?.id else { return }

    Task {
        do {
            unreadNotificationCount = try await FirestoreService.shared.getUnreadCount(userId: userId)
        } catch {
            print("Error loading unread count: \(error)")
        }
    }
}
```

---

## 🏗️ BUILD STEP 8: Update FirestoreService with Missing Methods

**File:** `services/FirestoreService.swift`

**Add these methods:**

```swift
func getFriendRequests(userId: String) async throws -> [Friendship] {
    // Get requests where user is receiver
    let snapshot1 = try await db.collection("friendships")
        .whereField("userId2", isEqualTo: userId)
        .whereField("status", isEqualTo: "pending")
        .getDocuments()

    let snapshot2 = try await db.collection("friendships")
        .whereField("userId1", isEqualTo: userId)
        .whereField("status", isEqualTo: "pending")
        .getDocuments()

    var requests: [Friendship] = []

    for doc in snapshot1.documents {
        if let friendship = try? doc.data(as: Friendship.self),
           friendship.initiatedBy != userId {
            requests.append(friendship)
        }
    }

    for doc in snapshot2.documents {
        if let friendship = try? doc.data(as: Friendship.self),
           friendship.initiatedBy != userId {
            requests.append(friendship)
        }
    }

    return requests
}
```

---

## 🏗️ BUILD STEP 9: Update FriendsView Navigation

**File:** `views/Main/FriendsView.swift`

**Update the "Add Friend" button to present AddFriendView:**

```swift
@State private var showAddFriend = false

// In the UI:
.sheet(isPresented: $showAddFriend) {
    AddFriendView()
        .environmentObject(authManager)
}
```

---

## ✅ TESTING CHECKLIST

After implementation, test these scenarios:

**Search & Add:**

-  [ ] Search finds users by name
-  [ ] Search finds users by username
-  [ ] Can't see yourself in results
-  [ ] "Add" button sends request
-  [ ] Button changes to "Pending"

**Friend Requests:**

-  [ ] Receiver gets notification
-  [ ] Notification shows in bell badge
-  [ ] Can accept request from notifications
-  [ ] Can decline request from notifications
-  [ ] Accepted friends appear in Friends list

**User Profiles:**

-  [ ] Can view any user's profile
-  [ ] Shows correct stats
-  [ ] Can add friend from profile
-  [ ] Can remove friend from profile
-  [ ] Activity is hidden (privacy)

**Notifications:**

-  [ ] Bell shows unread count
-  [ ] Tap bell opens notifications
-  [ ] Friend requests at top
-  [ ] Recent activity below
-  [ ] Mark as read when viewed
-  [ ] Empty state shows when no notifications

---

## 🎯 CURSOR EXECUTION COMMAND

To build each step, tell Cursor:

```
Build Step [NUMBER] from instructions.md "Complete Friend Request System"

[Copy the specific step requirements]

Create complete, production-ready code with:
- Proper error handling
- Loading states
- Empty states
- Real-time updates
- SwiftUI best practices

No placeholders. Full implementation.
```

//
//  AddFriendView.swift
//  Fetch
//

import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var friendshipStatuses: [String: FriendStatus] = [:] // userId: status
    @State private var errorMessage: String?
    
    // Debounce timer
    @State private var searchTask: Task<Void, Never>?
    
    var currentUserId: String? {
        authManager.currentUser?.id
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "8E8E93"))
                            .font(.system(size: 18))
                        
                        TextField("Search by name or username...", text: $searchText)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: searchText) { oldValue, newValue in
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
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "8E8E93"))
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(16)
                    
                    // Results
                    if isSearching {
                        ProgressView()
                            .padding(.top, 40)
                    } else if searchText.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Text("🔍")
                                .font(.system(size: 80))
                            Text("Search for Friends")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("Enter a username to find and add friends")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else if searchResults.isEmpty {
                        // No results
                        VStack(spacing: 20) {
                            Text("😕")
                                .font(.system(size: 80))
                            Text("No Users Found")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("Try searching for a different username")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // Results list
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(searchResults) { user in
                                    UserSearchRow(
                                        user: user,
                                        status: friendshipStatuses[user.id ?? ""] ?? .none,
                                        onAddFriend: {
                                            sendFriendRequest(to: user)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
        }
    }
    
    // MARK: - Search Logic
    
    func performSearch(query: String) async {
        guard !query.isEmpty, query.count >= 2 else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
            errorMessage = nil
        }
        
        do {
            // Search users
            let users = try await FirestoreService.shared.searchUsers(query: query)
            
            // Filter out current user
            let filteredUsers = users.filter { $0.id != currentUserId }
            
            // Load friendship statuses for all results
            for user in filteredUsers {
                if let userId = user.id, let currentUserId = currentUserId {
                    let status = await getFriendshipStatus(between: currentUserId, and: userId)
                    await MainActor.run {
                        friendshipStatuses[userId] = status
                    }
                }
            }
            
            await MainActor.run {
                searchResults = filteredUsers
                isSearching = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Search failed: \(error.localizedDescription)"
                searchResults = []
                isSearching = false
            }
        }
    }
    
    func getFriendshipStatus(between userId1: String, and userId2: String) async -> FriendStatus {
        do {
            // Get the friendship document if it exists
            if let friendship = try await FirestoreService.shared.getFriendship(userId1: userId1, userId2: userId2) {
                // Map Firestore FriendshipStatus to our display FriendStatus
                switch friendship.status {
                case .pending:
                    return .pending
                case .accepted:
                    return .friends
                case .blocked:
                    return .blocked
                }
            }
            
            // No friendship document exists
            return .none
        } catch {
            return .none
        }
    }
    
    func sendFriendRequest(to user: User) {
        guard let currentUserId = authManager.currentUser?.id,
              let receiverId = user.id else { return }
        
        Task {
            do {
                try await FirestoreService.shared.sendFriendRequest(from: currentUserId, to: receiverId)
                
                await MainActor.run {
                    // Update status to pending
                    friendshipStatuses[receiverId] = .pending
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to send request: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Friend Status Enum (for UI display)

enum FriendStatus {
    case none       // Not friends, no pending request
    case pending    // Friend request pending
    case friends    // Already friends
    case blocked    // User is blocked
}

// MARK: - User Search Row

struct UserSearchRow: View {
    let user: User
    let status: FriendStatus
    let onAddFriend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
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
                    .frame(width: 52, height: 52)
                
                Circle()
                    .fill(Color(hex: "E3F2FD"))
                    .frame(width: 48, height: 48)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
            }
            
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
            }
            
            Spacer()
            
            // Status Button
            Button(action: {
                if status == .none {
                    onAddFriend()
                }
            }) {
                Text(statusButtonText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(statusButtonColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(statusButtonBackground)
                    .cornerRadius(20)
            }
            .disabled(status != .none)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    var statusButtonText: String {
        switch status {
        case .none: return "Add"
        case .pending: return "Pending"
        case .friends: return "Friends"
        case .blocked: return "Blocked"
        }
    }
    
    var statusButtonColor: Color {
        switch status {
        case .none: return .white
        case .pending: return Color(hex: "8E8E93")
        case .friends: return Color(hex: "34C759")
        case .blocked: return Color(hex: "FF3B30")
        }
    }
    
    var statusButtonBackground: Color {
        switch status {
        case .none: return Color(hex: "007AFF")
        case .pending: return Color(hex: "F2F2F7")
        case .friends: return Color(hex: "E8F5E9")
        case .blocked: return Color(hex: "FFE5E5")
        }
    }
}

#Preview {
    AddFriendView()
        .environmentObject(AuthenticationManager())
}


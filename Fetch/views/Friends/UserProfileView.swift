//
//  UserProfileView.swift
//  Fetch
//

import SwiftUI
import FirebaseFirestore

// UI-specific enum for friendship status display
enum ProfileFriendshipStatus {
    case notFriends
    case pending
    case friends
}

struct UserProfileView: View {
    let user: User
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var friendshipStatus: ProfileFriendshipStatus = .notFriends
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
    
    func getFriendshipStatus(between userId1: String, and userId2: String) async -> ProfileFriendshipStatus {
        do {
            // Get the friendship document if it exists
            if let friendship = try await FirestoreService.shared.getFriendship(userId1: userId1, userId2: userId2) {
                // Map Firestore FriendshipStatus to our display ProfileFriendshipStatus
                switch friendship.status {
                case .pending:
                    return .pending
                case .accepted:
                    return .friends
                case .blocked:
                    return .notFriends // Treat blocked as not friends for now
                }
            }
            return .notFriends // No friendship document means not friends
        } catch {
            print("Error getting friendship status: \(error)")
            return .notFriends
        }
    }
    
    func sendFriendRequest() {
        guard let currentUserId = currentUserId, let userId = user.id else { return }
        
        Task {
            do {
                try await FirestoreService.shared.sendFriendRequest(from: currentUserId, to: userId)
                await MainActor.run {
                    friendshipStatus = .pending
                }
            } catch {
                print("Failed to send friend request: \(error)")
            }
        }
    }
    
    func removeFriend() {
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
                
                await MainActor.run {
                    friendshipStatus = .notFriends
                }
            } catch {
                print("Failed to remove friend: \(error)")
            }
        }
    }
}


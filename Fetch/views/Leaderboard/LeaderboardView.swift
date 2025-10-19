//
//  LeaderboardView.swift
//  Fetch
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var leaderboardUsers: [User] = []
    @State private var userRank: Int?
    @State private var isLoading = true
    @State private var selectedFilter: LeaderboardFilter = .weekly
    
    enum LeaderboardFilter: String, CaseIterable {
        case weekly = "This Week"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Segmented Control
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(LeaderboardFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .onChange(of: selectedFilter) { oldValue, newValue in
                        loadLeaderboard()
                    }
                    
                    if isLoading {
                        ProgressView()
                            .padding(.top, 60)
                        Spacer()
                    } else if leaderboardUsers.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Text("🏆")
                                .font(.system(size: 80))
                            Text("No Leaderboard Data")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("Be the first to gift points and climb the ranks!")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                // Top 3 Podium
                                if leaderboardUsers.count >= 3 {
                                    PodiumView(users: Array(leaderboardUsers.prefix(3)))
                                        .padding(.vertical, 24)
                                        .padding(.horizontal, 16)
                                }
                                
                                // Rest of the leaderboard
                                VStack(spacing: 8) {
                                    ForEach(Array(leaderboardUsers.enumerated()), id: \.element.id) { index, user in
                                        if index >= 3 {
                                            LeaderboardRow(
                                                user: user,
                                                rank: index + 1,
                                                isCurrentUser: user.id == authManager.currentUser?.id
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100) // Space for tab bar
                            }
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadLeaderboard()
        }
    }
    
    func loadLeaderboard() {
        isLoading = true
        
        Task {
            do {
                let users = try await FirestoreService.shared.getLeaderboard(limit: 50)
                
                await MainActor.run {
                    leaderboardUsers = users
                    isLoading = false
                }
                
                // Get current user rank
                if let userId = authManager.currentUser?.id {
                    let rank = try? await FirestoreService.shared.getUserRank(userId: userId)
                    await MainActor.run {
                        userRank = rank
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Error loading leaderboard: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Podium View

struct PodiumView: View {
    let users: [User]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd place
            if users.count >= 2 {
                PodiumCard(user: users[1], rank: 2, height: 140)
            }
            
            // 1st place
            if users.count >= 1 {
                PodiumCard(user: users[0], rank: 1, height: 180)
            }
            
            // 3rd place
            if users.count >= 3 {
                PodiumCard(user: users[2], rank: 3, height: 120)
            }
        }
    }
}

// MARK: - Podium Card

struct PodiumCard: View {
    let user: User
    let rank: Int
    let height: CGFloat
    
    var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var gradientColors: [Color] {
        switch rank {
        case 1: return [Color(hex: "FFD700"), Color(hex: "FFA500")]
        case 2: return [Color(hex: "C0C0C0"), Color(hex: "808080")]
        case 3: return [Color(hex: "CD7F32"), Color(hex: "8B4513")]
        default: return [Color.gray, Color.gray]
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Medal
            Text(medalEmoji)
                .font(.system(size: 32))
            
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 66, height: 66)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(gradientColors[0])
            }
            
            // Name
            Text(user.name.components(separatedBy: " ").first ?? user.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            // Points
            Text("\(user.totalPointsGifted)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(gradientColors[0])
            
            Text("gifted")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: gradientColors[0].opacity(0.3), radius: 8, y: 4)
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let user: User
    let rank: Int
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(isCurrentUser ? Color(hex: "007AFF") : Color(hex: "8E8E93"))
                .frame(width: 40, alignment: .leading)
            
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
                    .frame(width: 46, height: 46)
                
                Circle()
                    .fill(Color(hex: "E3F2FD"))
                    .frame(width: 42, height: 42)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
            }
            
            // User info
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.system(size: 17, weight: isCurrentUser ? .semibold : .regular))
                    .foregroundColor(.black)
                
                Text("@\(user.username)")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(user.totalPointsGifted)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isCurrentUser ? Color(hex: "007AFF") : .black)
                
                Text("gifted")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
        .padding(12)
        .background(isCurrentUser ? Color(hex: "007AFF").opacity(0.1) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color(hex: "007AFF") : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AuthenticationManager())
}


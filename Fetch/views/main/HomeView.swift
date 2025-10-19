//
//  HomeView.swift
//  Fetch
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var activities: [Activity] = []
    @State private var userListener: ListenerRegistration?
    @State private var activityListener: ListenerRegistration?
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTabView(activities: $activities)
                .environmentObject(authManager)
                .tabItem {
                    VStack {
                        Text("🏠")
                            .font(.system(size: 26))
                        Text("Home")
                            .font(.system(size: 11))
                    }
                }
                .tag(0)
            
            // Friends Tab
            FriendsTabView()
                .tabItem {
                    VStack {
                        Text("👥")
                            .font(.system(size: 26))
                        Text("Friends")
                            .font(.system(size: 11))
                    }
                }
                .tag(1)
            
            // Leaderboard Tab
            LeaderboardTabView()
                .tabItem {
                    VStack {
                        Text("📊")
                            .font(.system(size: 26))
                        Text("Leaderboard")
                            .font(.system(size: 11))
                    }
                }
                .tag(2)
            
            // You Tab
            YouTabView()
                .environmentObject(authManager)
                .tabItem {
                    VStack {
                        Text("👤")
                            .font(.system(size: 26))
                        Text("You")
                            .font(.system(size: 11))
                    }
                }
                .tag(3)
        }
        .accentColor(Color(hex: "007AFF"))
        .onAppear {
            setupListeners()
        }
        .onDisappear {
            cleanupListeners()
        }
    }
    
    func setupListeners() {
        guard let userId = authManager.currentUser?.id else { return }
        
        // Listen to user data changes
        userListener = FirestoreService.shared.listenToUser(userId: userId) { user in
            if let user = user {
                authManager.currentUser = user
            }
        }
        
        // Listen to activity feed changes
        activityListener = FirestoreService.shared.listenToActivities(userId: userId) { newActivities in
            activities = newActivities
        }
    }
    
    func cleanupListeners() {
        userListener?.remove()
        activityListener?.remove()
    }
}

// MARK: - Home Tab View

struct HomeTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var activities: [Activity]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Points Card
                        VStack(spacing: 12) {
                            Text("Campus Points")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "8E8E93"))
                            
                            Text("\(authManager.currentUser?.points ?? 500)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black)
                            
                            HStack(spacing: 4) {
                                Text("⏰")
                                    .font(.system(size: 15))
                                Text("Expires in \(authManager.currentUser?.pointsExpirationDays ?? 28) days")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Action Buttons
                        HStack(spacing: 8) {
                            // Gift Button
                            Button(action: {
                                // Navigate to gift view
                            }) {
                                HStack(spacing: 8) {
                                    Text("🎁")
                                        .font(.system(size: 20))
                                    Text("Gift")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: "007AFF"))
                                .cornerRadius(10)
                                .shadow(color: .blue.opacity(0.2), radius: 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Invite Button
                            Button(action: {
                                // Navigate to invite view
                            }) {
                                HStack(spacing: 8) {
                                    Text("➕")
                                        .font(.system(size: 20))
                                    Text("Invite")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "007AFF"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "E5E5EA"), lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 16)
                        
                        // Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Activity")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                            
                            if activities.isEmpty {
                                // Empty state
                                VStack(spacing: 12) {
                                    Text("🎉")
                                        .font(.system(size: 48))
                                    Text("No activity yet")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    Text("Start gifting points to see your activity here")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(32)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                                .padding(.horizontal, 16)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(activities) { activity in
                                        ActivityCard(activity: activity)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Navigate to notifications
                    }) {
                        Text("🔔")
                            .font(.system(size: 22))
                    }
                }
            }
        }
    }
}

// MARK: - Activity Card Component

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "007AFF").opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("👤")
                        .font(.system(size: 16))
                )
            
            // Activity Text and Time
            VStack(alignment: .leading, spacing: 4) {
                Text(activityText)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                
                Text(activity.timeAgo)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Points Value
            Text(pointsText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(pointsColor)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    var activityText: String {
        switch activity.type {
        case .received:
            return "\(activity.fromName ?? "Someone") sent you points"
        case .sent:
            return "You sent \(activity.amount) points to \(activity.toName ?? "someone")"
        case .earned:
            return activity.message ?? "You earned points"
        }
    }
    
    var pointsText: String {
        let sign = activity.type == .sent ? "-" : "+"
        return "\(sign)\(activity.amount)"
    }
    
    var pointsColor: Color {
        activity.type == .sent ? Color(hex: "8E8E93") : Color(hex: "34C759")
    }
}

// MARK: - Placeholder Tab Views

struct FriendsTabView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                Text("Friends")
                    .font(.system(size: 32, weight: .bold))
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LeaderboardTabView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                Text("Leaderboard")
                    .font(.system(size: 32, weight: .bold))
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct YouTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Profile")
                        .font(.system(size: 32, weight: .bold))
                    
                    if let user = authManager.currentUser {
                        VStack(spacing: 12) {
                            Text(user.name)
                                .font(.system(size: 24, weight: .semibold))
                            Text("@\(user.username)")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                            Text(user.school)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    }
                    
                    Button(action: {
                        try? authManager.logout()
                    }) {
                        Text("Log Out")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding(.top, 32)
            }
            .navigationTitle("You")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
}


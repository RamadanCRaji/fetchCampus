import SwiftUI
import FirebaseFirestore

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Tab Content
            TabView(selection: $selectedTab) {
                // Home Tab
                HomeTabContent()
                    .environmentObject(authManager)
                    .tag(0)
                
                // Friends Tab
                FriendsTabContent()
                    .tag(1)
                
                // Leaderboard Tab
                LeaderboardTabContent()
                    .tag(2)
                
                // Profile Tab
                ProfileView()
                    .environmentObject(authManager)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar Overlay
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Home Tab Content

struct HomeTabContent: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var activities: [Activity] = []
    @State private var userListener: ListenerRegistration?
    @State private var activityListener: ListenerRegistration?
    
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
                            // Gift Button (60% width)
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
                            .frame(maxWidth: .infinity)
                            
                            // Invite Button (40% width)
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
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 16)
                        
                        // Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Activity")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                            
                            if activities.isEmpty {
                                // Show sample activities from Figma
                                VStack(spacing: 8) {
                                    SampleActivityCard(
                                        name: "Jake",
                                        action: "accepted your gift 🎉",
                                        time: "2m ago",
                                        amount: "+200",
                                        isPositive: true
                                    )
                                    
                                    SampleActivityCard(
                                        name: "Emma",
                                        action: "You sent 150 points to Emma",
                                        time: "1h ago",
                                        amount: "-150",
                                        isPositive: false
                                    )
                                    
                                    SampleActivityCard(
                                        name: "Tyler",
                                        action: "sent you points",
                                        time: "3h ago",
                                        amount: "+100",
                                        isPositive: true
                                    )
                                }
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
                        
                        // Bottom spacing for tab bar
                        Spacer()
                            .frame(height: 80)
                    }
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

// MARK: - Sample Activity Card (for demo)

struct SampleActivityCard: View {
    let name: String
    let action: String
    let time: String
    let amount: String
    let isPositive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "007AFF").opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(hex: "007AFF"))
                        .font(.system(size: 20))
                )
            
            // Activity Text and Time
            VStack(alignment: .leading, spacing: 4) {
                Text(action.contains("You") ? action : "\(name) \(action)")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                
                Text(time)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Points Value
            Text(amount)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isPositive ? Color(hex: "34C759") : Color(hex: "8E8E93"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Friends Tab Content

struct FriendsTabContent: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("👥")
                        .font(.system(size: 64))
                    Text("Friends")
                        .font(.system(size: 24, weight: .bold))
                    Text("Coming soon...")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Leaderboard Tab Content

struct LeaderboardTabContent: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("📊")
                        .font(.system(size: 64))
                    Text("Leaderboard")
                        .font(.system(size: 24, weight: .bold))
                    Text("Coming soon...")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
}


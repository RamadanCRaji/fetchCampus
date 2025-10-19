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
                    .environmentObject(authManager)
                    .tag(1)
                
            // Leaderboard Tab
            LeaderboardView()
                .environmentObject(authManager)
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
    @State private var transactions: [Transaction] = []
    @State private var userListener: ListenerRegistration?
    @State private var transactionListener: ListenerRegistration?
    @State private var showGiftPoints = false
    @State private var showNotifications = false
    @State private var unreadCount = 0
    
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
                                showGiftPoints = true
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
                            
                            if transactions.isEmpty {
                                // Show sample activities from Figma (for demo purposes)
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
                                // Show real transactions from Firestore
                                VStack(spacing: 8) {
                                    ForEach(transactions) { transaction in
                                        TransactionCard(
                                            transaction: transaction,
                                            currentUserId: authManager.currentUser?.id ?? ""
                                        )
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
                        showNotifications = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "007AFF"))
                            
                            if unreadCount > 0 {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 18, height: 18)
                                    
                                    Text("\(min(unreadCount, 9))")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showGiftPoints) {
                GiftPointsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            setupListeners()
            loadUnreadCount()
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
        
        // Listen to transaction feed changes
        transactionListener = FirestoreService.shared.listenToTransactions(userId: userId) { newTransactions in
            transactions = newTransactions
        }
    }
    
    func cleanupListeners() {
        userListener?.remove()
        transactionListener?.remove()
    }
    
    func loadUnreadCount() {
        guard let userId = authManager.currentUser?.id else { return }
        
        Task {
            do {
                let count = try await FirestoreService.shared.getUnreadCount(userId: userId)
                await MainActor.run {
                    unreadCount = count
                }
            } catch {
                print("Error loading unread count: \(error.localizedDescription)")
            }
        }
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

// MARK: - Transaction Card (for real Firestore data)

struct TransactionCard: View {
    let transaction: Transaction
    let currentUserId: String
    
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
                Text(transaction.activityText(currentUserId: currentUserId))
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                
                Text(transaction.timeAgo)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Points Value
            Text(transaction.amountText(currentUserId: currentUserId))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(transaction.amountColor(currentUserId: currentUserId))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Friends Tab Content

struct FriendsTabContent: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var friends: [User] = []
    @State private var isLoading = false
    @State private var showAddFriend = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .tint(Color(hex: "007AFF"))
                } else if friends.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Text("👥")
                            .font(.system(size: 80))
                        
                        Text("No Friends Yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Add friends to start gifting points")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { showAddFriend = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.plus.fill")
                                Text("Add Friends")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(hex: "007AFF"))
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.2), radius: 8, y: 2)
                        }
                        .padding(.top, 16)
                    }
                } else {
                    // Friends List
                    ScrollView {
                        VStack(spacing: 16) {
                            // Friends Count Card
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Friends")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    Text("\(friends.count)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Button(action: { showAddFriend = true }) {
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "007AFF"))
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            // Friends List
                            VStack(spacing: 8) {
                                ForEach(friends) { friend in
                                    FriendRow(friend: friend)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Bottom spacing for tab bar
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
                    .environmentObject(authManager)
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    func loadFriends() {
        guard let userId = authManager.currentUser?.id else { return }
        
        isLoading = true
        
        Task {
            do {
                let fetchedFriends = try await FirestoreService.shared.getFriends(userId: userId)
                await MainActor.run {
                    friends = fetchedFriends
                    isLoading = false
                }
            } catch {
                print("Error loading friends: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Friend Row Component

struct FriendRow: View {
    let friend: User
    
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
                
                Text(String(friend.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("@\(friend.username)")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("🎁")
                        .font(.system(size: 14))
                    Text("\(friend.giftsGiven)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                Text("\(friend.points) pts")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
}


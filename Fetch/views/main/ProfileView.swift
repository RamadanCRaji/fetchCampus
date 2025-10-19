import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    var user: User? {
        authManager.currentUser
    }
    
    var body: some View {
        NavigationView {
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
                            
                            Text(String(user?.name.prefix(1) ?? "M").uppercased())
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "007AFF"))
                        }
                        .padding(.top, 24)
                        
                        // Name
                        Text(user?.name ?? "User")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        // Username
                        Text("@\(user?.username ?? "username")")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: "8E8E93"))
                        
                        // School Badge
                        HStack(spacing: 6) {
                            Text("🎓")
                                .font(.system(size: 16))
                            Text(user?.school ?? "University")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "007AFF"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "E3F2FD"))
                        .cornerRadius(20)
                        
                        // Edit Profile Button
                        Button(action: { showEditProfile = true }) {
                            Text("Edit Profile")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "007AFF"))
                                .frame(width: 150, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "007AFF"), lineWidth: 2)
                                )
                        }
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Stats Section
                    HStack(spacing: 0) {
                        StatColumn(
                            icon: "⭐",
                            value: "\(user?.points ?? 500)",
                            label: "Points"
                        )
                        
                        StatColumn(
                            icon: "🎁",
                            value: "\(user?.giftsGiven ?? 0)",
                            label: "Gifts Sent"
                        )
                        
                        StatColumn(
                            icon: "🏆",
                            value: "#\(user?.rank ?? 3)",
                            label: "Your Rank",
                            valueColor: Color(hex: "007AFF")
                        )
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Generosity Level Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            // Icon + Text
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "E8F5E9"))
                                        .frame(width: 56, height: 56)
                                    Text("🌱")
                                        .font(.system(size: 28))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Generosity Level")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    Text("Newbie")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                            
                            // Score
                            Text("0 / 100")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "007AFF"))
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(hex: "E5E5EA"))
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * 0.0) // 0% progress
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        
                        // Help Text
                        Text("Send 88 more gifts to reach 'Helper' 🌿")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal, 16)
                    
                    // Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Achievements")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("View All >")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                        }
                        
                        // Achievement icons placeholder
                        HStack(spacing: 16) {
                            AchievementIcon(emoji: "🏠")
                            AchievementIcon(emoji: "👥")
                            AchievementIcon(emoji: "📊")
                            AchievementIcon(emoji: "👤")
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Sign Out Button
                    Button(action: {
                        try? authManager.logout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Bottom spacing for tab bar
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.top, 8)
            }
            .background(Color(hex: "F2F2F7"))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Stat Column Component

struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    var valueColor: Color = .black
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 40))
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(valueColor)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8E8E93"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement Icon Component

struct AchievementIcon: View {
    let emoji: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            
            Text(emoji)
                .font(.system(size: 32))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}


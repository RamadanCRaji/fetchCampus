import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color(hex: "E5E5EA"))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                // Home Tab
                TabBarItem(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                // Friends Tab
                TabBarItem(
                    icon: "person.2.fill",
                    title: "Friends",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                // Leaderboard Tab
                TabBarItem(
                    icon: "chart.bar.fill",
                    title: "Leaderboard",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
                
                // Profile Tab
                TabBarItem(
                    icon: "person.fill",
                    title: "You",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )
            }
            .frame(height: 60)
            .background(.ultraThinMaterial)
        }
        .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .frame(height: 26)
                
                Text(title)
                    .font(.system(size: 11, weight: .regular))
            }
            .foregroundColor(isSelected ? Color(hex: "007AFF") : Color(hex: "8E8E93"))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(0))
    }
}


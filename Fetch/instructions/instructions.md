# 🎨 UI FIXES - MATCH FIGMA DESIGNS EXACTLY

## Issue 1: Bottom Tab Bar Icons Are Too Small

**PROBLEM:**
The tab bar icons at the bottom are TINY (look like dots) instead of proper sized icons.

**COMPARISON:**

-  **Figma Design:** Icons are 26pt, clearly visible
-  **Current App:** Icons appear to be ~12-14pt, barely visible

**FIX REQUIRED:**

````swift
FILE: Create a new file - views/Components/CustomTabBar.swift

Build a custom tab bar that matches Figma exactly.

DESIGN SPECS FROM FIGMA:

Tab Bar Container:
- Height: 80pt (includes safe area)
- Background: White with blur effect
- Top border: 0.5pt, color #E5E5EA
- Shadow: 0 -2px 8px rgba(0,0,0,0.05)

Each Tab Item:
- Icon size: 26pt x 26pt
- Label: 11pt, regular weight
- Spacing between icon and label: 4pt
- Active color: #007AFF (blue)
- Inactive color: #8E8E93 (gray)
- Vertical padding: 8pt top, 4pt bottom

4 Tabs (left to right):
1. Home
   - Active icon: 🏠 (filled house emoji or SF Symbol "house.fill")
   - Inactive icon: 🏠 (outlined house or "house")
   - Label: "Home"

2. Friends
   - Active icon: 👥 (filled people emoji or SF Symbol "person.2.fill")
   - Inactive icon: 👥 (outlined or "person.2")
   - Label: "Friends"

3. Leaderboard
   - Active icon: 📊 (filled chart emoji or SF Symbol "chart.bar.fill")
   - Inactive icon: 📊 (outlined or "chart.bar")
   - Label: "Leaderboard"

4. You (Profile)
   - Active icon: 👤 (filled person emoji or SF Symbol "person.fill")
   - Inactive icon: 👤 (outlined or "person")
   - Label: "You"

IMPLEMENTATION:
```swift
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
```

USAGE in FetchApp.swift or MainTabView.swift:
```swift
@State private var selectedTab = 0

var body: some View {
    ZStack {
        // Content
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)

            FriendsView()
                .tag(1)

            LeaderboardView()
                .tag(2)

            ProfileView()
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))

        // Custom tab bar overlay
        VStack {
            Spacer()
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
```

OR simpler approach - just increase icon size in existing TabView:
```swift
.tabItem {
    Image(systemName: "house.fill")
        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
        .font(.system(size: 26)) // ← ADD THIS
    Text("Home")
        .font(.system(size: 11)) // ← ADD THIS
}
```
````

---

## Issue 2: HomeView UI Doesn't Match Figma

**DIFFERENCES FOUND:**

Comparing actual app (Image 1) to Figma (Image 2):

1. **Activity Section - Empty State**

   -  ✅ Currently shows: "No activity yet" with party emoji
   -  ❌ Should show: Activity cards (Jake, Emma, Tyler examples)
   -  FIX: Use placeholder/sample data until real transactions exist

2. **Points Card Styling**

   -  Current: Good match
   -  Potential improvement: Verify corner radius is exactly 14pt
   -  Verify shadow matches: `shadowColor: .black.opacity(0.08), radius: 8, y: 2`

3. **Button Sizing**
   -  Current: Good
   -  Verify Gift button is exactly 60% width, Invite is 40%

**FIX:**

````swift
FILE: views/Main/HomeView.swift

UPDATES NEEDED:

1. ADD SAMPLE ACTIVITY DATA (for demo/testing):
```swift
// At top of HomeView
let sampleActivities = [
    Activity(
        id: "1",
        userId: "current_user",
        type: .received,
        fromUserId: "jake_id",
        fromName: "Jake",
        amount: 200,
        message: "accepted your gift",
        timestamp: Timestamp(date: Date().addingTimeInterval(-120))
    ),
    Activity(
        id: "2",
        userId: "current_user",
        type: .sent,
        toUserId: "emma_id",
        toName: "Emma",
        amount: 150,
        timestamp: Timestamp(date: Date().addingTimeInterval(-3600))
    ),
    Activity(
        id: "3",
        userId: "current_user",
        type: .received,
        fromUserId: "tyler_id",
        fromName: "Tyler",
        amount: 100,
        timestamp: Timestamp(date: Date().addingTimeInterval(-10800))
    )
]
```

2. UPDATE ACTIVITY SECTION to show sample data:
```swift
// Activity Section
VStack(alignment: .leading, spacing: 16) {
    Text("Activity")
        .font(.system(size: 22, weight: .bold))
        .foregroundColor(.black)
        .padding(.horizontal, 16)

    // Show sample activities (replace with real data when available)
    if sampleActivities.isEmpty {
        // Empty state
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 64))
            Text("No activity yet")
                .font(.system(size: 17, weight: .semibold))
            Text("Start gifting points to see your activity here")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "8E8E93"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    } else {
        ForEach(sampleActivities) { activity in
            ActivityRow(activity: activity)
                .padding(.horizontal, 16)
        }
    }
}
```

3. CREATE ActivityRow component:
```swift
struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "E5E5EA"))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(hex: "8E8E93"))
                        .font(.system(size: 20))
                )

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.displayText)
                    .font(.system(size: 15))
                    .foregroundColor(.black)

                Text(activity.timeAgo)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }

            Spacer()

            // Amount
            Text(activity.amountText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(activity.amountColor)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// Helper computed properties for Activity model
extension Activity {
    var displayText: String {
        switch type {
        case .received:
            if let name = fromName {
                return "\(name) sent you points"
            }
            return "You received points"
        case .sent:
            if let name = toName {
                return "You sent \(amount) points to \(name)"
            }
            return "You sent points"
        case .earned:
            return message ?? "You earned points"
        }
    }

    var amountText: String {
        type == .sent ? "-\(amount)" : "+\(amount)"
    }

    var amountColor: Color {
        type == .sent ? Color(hex: "8E8E93") : Color(hex: "34C759")
    }
}
```
````

---

## Issue 3: Build Profile Page (Screen 10)

**PROBLEM:**
Profile page doesn't exist yet. Need to build it matching Figma design.

**FIGMA DESIGN SPECS:**
CREATE: views/Main/ProfileView.swift
LAYOUT (from top to bottom):

HEADER SECTION (White card, rounded 16pt, centered content):

Profile Avatar:

Circle: 120pt diameter
Border: 4pt, gradient (blue to purple)
Background: Light blue
Initial letter: First letter of name, 48pt, blue, bold

Name: "Ramadan Raji" (28pt, bold, black)
Username: "@madisonc" (17pt, gray #8E8E93)
School Badge: "🎓 UW Madison" (15pt, gray text, light blue background pill)
Edit Profile Button:

Text: "Edit Profile" (17pt, semibold, blue)
Background: White
Border: 2pt, blue
Corner radius: 12pt
Height: 44pt
Width: ~150pt

STATS SECTION (3 columns, white background):
HStack with equal spacing:
Column 1 - Points:

Icon: ⭐ (40pt)
Number: "500" (32pt, bold, black)
Label: "Points" (13pt, gray)

Column 2 - Gifts Sent:

Icon: 🎁 (40pt)
Number: "12" (32pt, bold, black)
Label: "Gifts Sent" (13pt, gray)

Column 3 - Rank:

Icon: 🏆 (40pt)
Number: "#3" (32pt, bold, blue #007AFF)
Label: "Your Rank" (13pt, gray)

GENEROSITY LEVEL SECTION (White card, rounded 12pt):

Left side:

Icon: 🌱 (40pt, in light green circle)
Title: "Generosity Level" (15pt, gray)
Level: "Newbie" (24pt, bold, black)

Right side:

Score: "0 / 100" (20pt, bold, blue)

Progress Bar:

Background: #E5E5EA
Fill: Blue gradient
Height: 8pt
Corner radius: 4pt
Current: 0% (0/100)

Help text: "Send 88 more gifts to reach 'Helper' 🌿" (13pt, gray)

ACHIEVEMENTS SECTION:

Header:

Left: "Achievements" (22pt, bold, black)
Right: "View All >" (15pt, blue, tappable)

Achievement Grid: (2 columns, coming soon)

BOTTOM TAB BAR (same as Home screen)

IMPLEMENTATION:
swiftimport SwiftUI

struct ProfileView: View {
@EnvironmentObject var authManager: AuthenticationManager
@State private var showEditProfile = false

    var user: User? {
        authManager.currentUser
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

                        Text(String(user?.name.prefix(1) ?? "M").uppercased())
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "007AFF"))
                    }

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
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .padding(.horizontal, 16)

                // Stats Section
                HStack(spacing: 0) {
                    StatColumn(icon: "⭐", value: "\(user?.points ?? 500)", label: "Points")
                    StatColumn(icon: "🎁", value: "\(user?.giftsGiven ?? 0)", label: "Gifts Sent")
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

                    // Coming soon placeholder
                    Text("Coming soon...")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                }
                .padding(.horizontal, 16)

                // Bottom spacing for tab bar
                Spacer()
                    .frame(height: 80)
            }
            .padding(.top, 16)
        }
        .background(Color(hex: "F2F2F7"))
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authManager)
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

#Preview {
ProfileView()
.environmentObject(AuthenticationManager())
}
BUILD EDIT PROFILE VIEW (placeholder for now):
swiftFILE: views/Main/EditProfileView.swift

struct EditProfileView: View {
@Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Edit Profile")
                    .font(.title)

                Text("Coming soon...")
                    .foregroundColor(.gray)
                    .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

}

```

```

---

## ✅ IMPLEMENTATION CHECKLIST

**Phase 1: Fix Tab Bar (30 min)**

-  [ ] Create CustomTabBar component OR increase icon sizes
-  [ ] Test: Icons are clearly visible (26pt)
-  [ ] Test: Labels are 11pt
-  [ ] Test: Active/inactive colors work

**Phase 2: Fix HomeView (20 min)**

-  [ ] Add sample activity data
-  [ ] Create ActivityRow component
-  [ ] Update activity section to show data
-  [ ] Verify all spacing matches Figma

**Phase 3: Build ProfileView (45 min)**

-  [ ] Create ProfileView.swift
-  [ ] Build header with avatar
-  [ ] Build stats section (3 columns)
-  [ ] Build generosity level card
-  [ ] Build achievements section
-  [ ] Create EditProfileView placeholder

**Phase 4: Connect Everything (15 min)**

-  [ ] Update tab navigation to include ProfileView
-  [ ] Test navigation between all tabs
-  [ ] Verify data displays correctly

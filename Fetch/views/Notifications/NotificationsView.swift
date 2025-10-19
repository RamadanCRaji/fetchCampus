//
//  NotificationsView.swift
//  Fetch
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if notifications.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Text("🔔")
                            .font(.system(size: 80))
                        Text("No Notifications")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        Text("You're all caught up!")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification) {
                                    markAsRead(notification)
                                }
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
                
                if !notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Mark All Read") {
                            markAllAsRead()
                        }
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    func loadNotifications() {
        guard let userId = authManager.currentUser?.id else { return }
        
        isLoading = true
        
        Task {
            do {
                let fetchedNotifications = try await FirestoreService.shared.getNotifications(userId: userId, limit: 50)
                await MainActor.run {
                    notifications = fetchedNotifications
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
                print("Error loading notifications: \(error.localizedDescription)")
            }
        }
    }
    
    func markAsRead(_ notification: AppNotification) {
        guard let notificationId = notification.id, !notification.read else { return }
        
        Task {
            do {
                try await FirestoreService.shared.markNotificationRead(notificationId: notificationId)
                await MainActor.run {
                    if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                        notifications[index].read = true
                    }
                }
            } catch {
                print("Error marking notification as read: \(error.localizedDescription)")
            }
        }
    }
    
    func markAllAsRead() {
        Task {
            for notification in notifications where !notification.read {
                if let id = notification.id {
                    try? await FirestoreService.shared.markNotificationRead(notificationId: id)
                }
            }
            
            await MainActor.run {
                for index in notifications.indices {
                    notifications[index].read = true
                }
            }
        }
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var iconEmoji: String {
        switch notification.type {
        case .giftReceived: return "🎁"
        case .giftAccepted: return "✅"
        case .friendRequest: return "👋"
        case .friendAccepted: return "🤝"
        case .achievement: return "🏆"
        case .leaderboardChange: return "📊"
        case .pointsExpiring: return "⚠️"
        case .weeklyReport: return "📈"
        }
    }
    
    var iconColor: Color {
        switch notification.type {
        case .giftReceived, .giftAccepted: return Color(hex: "34C759")
        case .friendRequest, .friendAccepted: return Color(hex: "007AFF")
        case .achievement: return Color(hex: "FFD700")
        case .leaderboardChange: return Color(hex: "FF9500")
        case .pointsExpiring: return Color(hex: "FF3B30")
        case .weeklyReport: return Color(hex: "5856D6")
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text(iconEmoji)
                        .font(.system(size: 24))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.read ? .regular : .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(notification.message)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .lineLimit(2)
                    
                    Text(notification.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8E8E93"))
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
            .background(notification.read ? Color.white : Color(hex: "007AFF").opacity(0.05))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AuthenticationManager())
}


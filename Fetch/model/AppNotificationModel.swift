//
//  AppNotificationModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

struct AppNotification: Codable, Identifiable {
    @DocumentID var id: String?
    
    var userId: String              // Who receives this notification
    var type: NotificationType
    var title: String
    var message: String
    var relatedUserId: String?      // User involved (gift sender, friend requester, etc.)
    var relatedTransactionId: String?
    var relatedFriendshipId: String?
    var read: Bool
    var createdAt: Timestamp
    var readAt: Timestamp?
    var actionUrl: String?          // Optional deep link
    
    enum CodingKeys: String, CodingKey {
        case id, userId, type, title, message
        case relatedUserId, relatedTransactionId, relatedFriendshipId
        case read, createdAt, readAt, actionUrl
    }
    
    // Time ago string
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt.dateValue(), relativeTo: Date())
    }
    
    // Emoji for notification type
    var emoji: String {
        switch type {
        case .giftReceived:
            return "🎁"
        case .friendRequest:
            return "👥"
        case .friendAccepted:
            return "✅"
        case .achievementUnlocked:
            return "🏆"
        }
    }
}

enum NotificationType: String, Codable {
    case giftReceived = "gift_received"
    case friendRequest = "friend_request"
    case friendAccepted = "friend_accepted"
    case achievementUnlocked = "achievement_unlocked"
}


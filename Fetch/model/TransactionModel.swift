//
//  TransactionModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?
    
    var type: TransactionType
    var fromUserId: String?       // Sender (nil for bonuses/earned)
    var toUserId: String          // Receiver
    var amount: Int               // Points (always positive)
    var message: String?          // Optional message
    var status: TransactionStatus
    var createdAt: Timestamp
    var completedAt: Timestamp?
    
    // Cached data for performance
    var fromUserName: String?
    var toUserName: String
    var fromUsername: String?
    var toUsername: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, fromUserId, toUserId, amount, message, status
        case createdAt, completedAt
        case fromUserName, toUserName, fromUsername, toUsername
    }
    
    // Display text for activity feed
    var displayText: String {
        switch type {
        case .gift:
            if let fromName = fromUserName {
                return "\(fromName) sent you \(amount) points"
            }
            return "You sent \(amount) points to \(toUserName)"
        case .bonus:
            return message ?? "Weekly bonus earned"
        case .earned:
            return message ?? "Points earned"
        case .penalty:
            return message ?? "Points deducted"
        }
    }
    
    // Time ago string
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt.dateValue(), relativeTo: Date())
    }
    
    // Amount text with +/- prefix
    func amountText(currentUserId: String) -> String {
        let isOutgoing = fromUserId == currentUserId
        let prefix = isOutgoing ? "-" : "+"
        return "\(prefix)\(amount)"
    }
    
    // Amount color (green for incoming, gray for outgoing)
    func amountColor(currentUserId: String) -> Color {
        let isOutgoing = fromUserId == currentUserId
        return isOutgoing ? Color(hex: "8E8E93") : Color(hex: "34C759")
    }
    
    // Activity text that considers current user
    func activityText(currentUserId: String) -> String {
        switch type {
        case .gift:
            if fromUserId == currentUserId {
                // User sent gift
                return "You sent \(amount) points to \(toUserName)"
            } else {
                // User received gift
                if let fromName = fromUserName {
                    return "\(fromName) sent you points"
                }
                return "You received \(amount) points"
            }
        case .bonus:
            return message ?? "Weekly bonus earned"
        case .earned:
            return message ?? "Points earned"
        case .penalty:
            return message ?? "Points deducted"
        }
    }
}

enum TransactionType: String, Codable {
    case gift
    case bonus
    case earned
    case penalty
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}


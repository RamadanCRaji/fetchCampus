//
//  ActivityModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String  // Who sees this activity
    var type: ActivityType
    var fromUserId: String?
    var toUserId: String?
    var fromName: String?
    var toName: String?
    var amount: Int
    var message: String?
    var timestamp: Timestamp
    
    enum ActivityType: String, Codable {
        case sent
        case received
        case earned
    }
    
    // Computed property for time ago
    var timeAgo: String {
        let date = timestamp.dateValue()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


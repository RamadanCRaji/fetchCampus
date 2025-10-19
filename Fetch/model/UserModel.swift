//
//  UserModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var username: String
    var email: String
    var studentId: String
    var school: String
    var points: Int
    var giftsGiven: Int
    var rank: Int
    var createdAt: Timestamp
    var emailVerified: Bool
    var profileImageUrl: String?
    
    // Computed property for expiration
    var pointsExpirationDays: Int {
        let calendar = Calendar.current
        let createdDate = createdAt.dateValue()
        let expirationDate = calendar.date(byAdding: .day, value: 30, to: createdDate)!
        let days = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return max(0, days)
    }
}


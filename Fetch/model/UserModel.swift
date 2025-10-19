//
//  UserModel.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    
    // Profile
    var name: String
    var username: String
    var email: String
    var studentId: String
    var school: String
    
    // Points & Stats
    var points: Int
    var totalPointsEarned: Int
    var totalPointsGifted: Int
    var giftsGiven: Int
    var giftsReceived: Int
    
    // Ranking
    var rank: Int
    var generosityLevel: String
    var generosityScore: Int
    
    // Metadata
    var createdAt: Timestamp
    var emailVerified: Bool
    var profileImageUrl: String?
    var lastActive: Timestamp
    var achievements: [String]
    var isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name, username, email, studentId, school
        case points, totalPointsEarned, totalPointsGifted
        case giftsGiven, giftsReceived, rank
        case generosityLevel, generosityScore
        case createdAt, emailVerified, profileImageUrl
        case lastActive, achievements, isPrivate
    }
    
    // Computed property for expiration
    var pointsExpirationDays: Int {
        let calendar = Calendar.current
        let createdDate = createdAt.dateValue()
        let expirationDate = calendar.date(byAdding: .day, value: 30, to: createdDate)!
        let days = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return max(0, days)
    }
    
    // Custom decoding to handle optional/default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        studentId = try container.decode(String.self, forKey: .studentId)
        school = try container.decode(String.self, forKey: .school)
        points = try container.decodeIfPresent(Int.self, forKey: .points) ?? 500
        totalPointsEarned = try container.decodeIfPresent(Int.self, forKey: .totalPointsEarned) ?? 500
        totalPointsGifted = try container.decodeIfPresent(Int.self, forKey: .totalPointsGifted) ?? 0
        giftsGiven = try container.decodeIfPresent(Int.self, forKey: .giftsGiven) ?? 0
        giftsReceived = try container.decodeIfPresent(Int.self, forKey: .giftsReceived) ?? 0
        rank = try container.decodeIfPresent(Int.self, forKey: .rank) ?? 999
        generosityLevel = try container.decodeIfPresent(String.self, forKey: .generosityLevel) ?? "Newbie"
        generosityScore = try container.decodeIfPresent(Int.self, forKey: .generosityScore) ?? 0
        createdAt = try container.decode(Timestamp.self, forKey: .createdAt)
        emailVerified = try container.decode(Bool.self, forKey: .emailVerified)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        lastActive = try container.decodeIfPresent(Timestamp.self, forKey: .lastActive) ?? Timestamp()
        achievements = try container.decodeIfPresent([String].self, forKey: .achievements) ?? []
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
    }
    
    // Manual init for creating new users
    init(
        id: String? = nil,
        name: String,
        username: String,
        email: String,
        studentId: String,
        school: String,
        points: Int = 500,
        totalPointsEarned: Int = 500,
        totalPointsGifted: Int = 0,
        giftsGiven: Int = 0,
        giftsReceived: Int = 0,
        rank: Int = 999,
        generosityLevel: String = "Newbie",
        generosityScore: Int = 0,
        createdAt: Timestamp = Timestamp(),
        emailVerified: Bool = false,
        profileImageUrl: String? = nil,
        lastActive: Timestamp = Timestamp(),
        achievements: [String] = [],
        isPrivate: Bool = false
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.studentId = studentId
        self.school = school
        self.points = points
        self.totalPointsEarned = totalPointsEarned
        self.totalPointsGifted = totalPointsGifted
        self.giftsGiven = giftsGiven
        self.giftsReceived = giftsReceived
        self.rank = rank
        self.generosityLevel = generosityLevel
        self.generosityScore = generosityScore
        self.createdAt = createdAt
        self.emailVerified = emailVerified
        self.profileImageUrl = profileImageUrl
        self.lastActive = lastActive
        self.achievements = achievements
        self.isPrivate = isPrivate
    }
}

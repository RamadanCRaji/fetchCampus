//
//  FirestoreService.swift
//  Fetch
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        guard let userId = user.id else { return }
        try db.collection("users").document(userId).setData(from: user)
    }
    
    func getUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        return try document.data(as: User.self)
    }
    
    func updateUser(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(data)
    }
    
    // Check username uniqueness
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments()
        return snapshot.documents.isEmpty
    }
    
    // Check student ID uniqueness
    func isStudentIdAvailable(_ studentId: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments()
        return snapshot.documents.isEmpty
    }
    
    // MARK: - Activity Operations
    
    func createActivity(_ activity: Activity) async throws {
        try db.collection("activities").addDocument(from: activity)
    }
    
    func getActivities(for userId: String, limit: Int = 20) async throws -> [Activity] {
        let snapshot = try await db.collection("activities")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: Activity.self) }
    }
    
    // Real-time listener for user data
    func listenToUser(userId: String, completion: @escaping (User?) -> Void) -> ListenerRegistration {
        return db.collection("users").document(userId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                let user = try? snapshot.data(as: User.self)
                completion(user)
            }
    }
    
    // Real-time listener for activities
    func listenToActivities(userId: String, completion: @escaping ([Activity]) -> Void) -> ListenerRegistration {
        return db.collection("activities")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion([])
                    return
                }
                let activities = snapshot.documents.compactMap { try? $0.data(as: Activity.self) }
                completion(activities)
            }
    }
}


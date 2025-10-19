//
//  FirebaseManager.swift
//  Fetch
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        configureFirebase()
    }
    
    func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    var auth: Auth {
        return Auth.auth()
    }
    
    var firestore: Firestore {
        return Firestore.firestore()
    }
}


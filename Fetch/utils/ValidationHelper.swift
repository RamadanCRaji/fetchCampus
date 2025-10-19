//
//  ValidationHelper.swift
//  Fetch
//

import Foundation

struct ValidationHelper {
    
    // Validate email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) && email.hasSuffix(".edu")
    }
    
    // Validate username
    static func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9_]{3,}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }
    
    // Validate student ID
    static func isValidStudentId(_ id: String) -> Bool {
        return id.count >= 8 && id.count <= 10 && id.allSatisfy { $0.isNumber }
    }
    
    // Validate name
    static func isValidName(_ name: String) -> Bool {
        return name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    // Validate password
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // Generate error messages
    static func errorMessage(for field: String, error: ValidationError) -> String {
        switch error {
        case .required:
            return "\(field) is required"
        case .tooShort(let min):
            return "\(field) must be at least \(min) characters"
        case .invalidFormat:
            return "Please enter a valid \(field.lowercased())"
        case .alreadyExists:
            return "This \(field.lowercased()) is already registered"
        }
    }
}

enum ValidationError {
    case required
    case tooShort(Int)
    case invalidFormat
    case alreadyExists
}


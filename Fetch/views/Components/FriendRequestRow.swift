//
//  FriendRequestRow.swift
//  Fetch
//

import SwiftUI

struct FriendRequestRow: View {
    let friendship: Friendship
    let currentUserId: String
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    // Get the sender's info (the person who initiated the request)
    var senderName: String {
        friendship.initiatedBy == friendship.userId1 ? friendship.user1Name : friendship.user2Name
    }
    
    var senderUsername: String {
        friendship.initiatedBy == friendship.userId1 ? friendship.user1Username : friendship.user2Username
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "E5E5EA"))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(senderName.prefix(1)).uppercased())
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(senderName)
                    .font(.system(size: 17, weight: .semibold))
                
                Text("@\(senderUsername)")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "8E8E93"))
                
                Text("wants to be friends")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "34C759"))
                        .cornerRadius(6)
                }
                
                Button(action: onDecline) {
                    Text("Decline")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "F2F2F7"))
                        .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .padding(.horizontal, 16)
    }
}


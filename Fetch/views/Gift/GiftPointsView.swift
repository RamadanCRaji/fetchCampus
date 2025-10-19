//
//  GiftPointsView.swift
//  Fetch
//

import SwiftUI

struct GiftPointsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var friends: [User] = []
    @State private var selectedFriend: User?
    @State private var amount: String = ""
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    
    let presetAmounts = [50, 100, 200, 500]
    
    var currentPoints: Int {
        authManager.currentUser?.points ?? 0
    }
    
    var canSend: Bool {
        guard let amount = Int(amount),
              amount > 0,
              amount <= currentPoints,
              selectedFriend != nil else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Points Card
                        VStack(spacing: 12) {
                            Text("Your Balance")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "8E8E93"))
                            
                            Text("\(currentPoints)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("points available")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Select Friend Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Friend")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                            
                            if friends.isEmpty {
                                Text("No friends yet. Add friends to send points.")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                    .padding()
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(friends) { friend in
                                            FriendChip(
                                                friend: friend,
                                                isSelected: selectedFriend?.id == friend.id,
                                                action: { selectedFriend = friend }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // Amount Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amount")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                            
                            // Amount Input
                            HStack {
                                Text("🎁")
                                    .font(.system(size: 24))
                                
                                TextField("Enter amount", text: $amount)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                    .keyboardType(.numberPad)
                                
                                Text("pts")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal, 16)
                            
                            // Preset Amounts
                            HStack(spacing: 8) {
                                ForEach(presetAmounts, id: \.self) { preset in
                                    Button(action: {
                                        amount = String(preset)
                                    }) {
                                        Text("\(preset)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(amount == String(preset) ? .white : Color(hex: "007AFF"))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(amount == String(preset) ? Color(hex: "007AFF") : Color.white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color(hex: "007AFF"), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Message Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Message (Optional)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                            
                            TextField("Add a message...", text: $message, axis: .vertical)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                .padding(.horizontal, 16)
                                .lineLimit(3...6)
                        }
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                        }
                        
                        // Send Button
                        Button(action: sendGift) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Send Gift")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(canSend ? Color(hex: "007AFF") : Color.gray)
                        .cornerRadius(14)
                        .shadow(color: canSend ? .blue.opacity(0.3) : .clear, radius: 12, y: 4)
                        .padding(.horizontal, 16)
                        .disabled(!canSend || isLoading)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("Gift Points")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                loadFriends()
            }
            .fullScreenCover(isPresented: $showingSuccess) {
                if let friend = selectedFriend, let giftAmount = Int(amount) {
                    GiftSuccessView(
                        recipientName: friend.name,
                        amount: giftAmount,
                        onDismiss: {
                            showingSuccess = false
                            dismiss()
                        }
                    )
                }
            }
        }
    }
    
    func loadFriends() {
        guard let userId = authManager.currentUser?.id else { return }
        
        Task {
            do {
                let fetchedFriends = try await FirestoreService.shared.getFriends(userId: userId)
                await MainActor.run {
                    friends = fetchedFriends
                }
            } catch {
                print("Error loading friends: \(error.localizedDescription)")
            }
        }
    }
    
    func sendGift() {
        guard let friend = selectedFriend,
              let friendId = friend.id,
              let currentUserId = authManager.currentUser?.id,
              let giftAmount = Int(amount),
              giftAmount > 0 else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await FirestoreService.shared.sendGift(
                    from: currentUserId,
                    to: friendId,
                    amount: giftAmount,
                    message: message.isEmpty ? nil : message
                )
                
                await MainActor.run {
                    isLoading = false
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Friend Chip

struct FriendChip: View {
    let friend: User
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isSelected ? 66 : 60, height: isSelected ? 66 : 60)
                    
                    Circle()
                        .fill(Color(hex: "E3F2FD"))
                        .frame(width: isSelected ? 60 : 56, height: isSelected ? 60 : 56)
                    
                    Text(String(friend.name.prefix(1)).uppercased())
                        .font(.system(size: isSelected ? 24 : 20, weight: .bold))
                        .foregroundColor(Color(hex: "007AFF"))
                }
                
                Text(friend.name.components(separatedBy: " ").first ?? friend.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "007AFF") : .black)
                    .lineLimit(1)
            }
            .padding(12)
            .background(isSelected ? Color(hex: "007AFF").opacity(0.1) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "007AFF") : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

#Preview {
    GiftPointsView()
        .environmentObject(AuthenticationManager())
}


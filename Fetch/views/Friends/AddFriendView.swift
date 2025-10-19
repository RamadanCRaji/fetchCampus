//
//  AddFriendView.swift
//  Fetch
//

import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var sentRequests: Set<String> = [] // Track sent requests
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "8E8E93"))
                            .font(.system(size: 18))
                        
                        TextField("Search by username...", text: $searchText)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: searchText) { oldValue, newValue in
                                performSearch(query: newValue)
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "8E8E93"))
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(16)
                    
                    // Results
                    if isSearching {
                        ProgressView()
                            .padding(.top, 40)
                    } else if searchText.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Text("🔍")
                                .font(.system(size: 80))
                            Text("Search for Friends")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("Enter a username to find and add friends")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else if searchResults.isEmpty {
                        // No results
                        VStack(spacing: 20) {
                            Text("😕")
                                .font(.system(size: 80))
                            Text("No Users Found")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            Text("Try searching for a different username")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // Results list
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(searchResults) { user in
                                    UserSearchRow(
                                        user: user,
                                        currentUserId: authManager.currentUser?.id ?? "",
                                        requestSent: sentRequests.contains(user.id ?? ""),
                                        onAddFriend: {
                                            sendFriendRequest(to: user)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
        }
    }
    
    // MARK: - Search Logic
    
    func performSearch(query: String) {
        guard !query.isEmpty, query.count >= 2 else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await FirestoreService.shared.searchUsers(query: query)
                
                await MainActor.run {
                    // Filter out current user
                    searchResults = results.filter { $0.id != authManager.currentUser?.id }
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Search failed. Please try again."
                    isSearching = false
                }
            }
        }
    }
    
    func sendFriendRequest(to user: User) {
        guard let currentUserId = authManager.currentUser?.id,
              let receiverId = user.id else { return }
        
        Task {
            do {
                try await FirestoreService.shared.sendFriendRequest(from: currentUserId, to: receiverId)
                
                await MainActor.run {
                    sentRequests.insert(receiverId)
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to send request. Please try again."
                }
            }
        }
    }
}

// MARK: - User Search Row

struct UserSearchRow: View {
    let user: User
    let currentUserId: String
    let requestSent: Bool
    let onAddFriend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                
                Circle()
                    .fill(Color(hex: "E3F2FD"))
                    .frame(width: 48, height: 48)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("@\(user.username)")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "8E8E93"))
                
                Text(user.school)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            Spacer()
            
            // Add button
            if requestSent {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Sent")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "34C759"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "34C759").opacity(0.1))
                .cornerRadius(20)
            } else {
                Button(action: onAddFriend) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 14))
                        Text("Add")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(20)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    AddFriendView()
        .environmentObject(AuthenticationManager())
}


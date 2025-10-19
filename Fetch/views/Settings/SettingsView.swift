//
//  SettingsView.swift
//  Fetch
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Account Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Account")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: EditProfileView()) {
                                    SettingsRow(
                                        icon: "person.circle.fill",
                                        title: "Edit Profile",
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                NavigationLink(destination: NotificationSettingsView()) {
                                    SettingsRow(
                                        icon: "bell.fill",
                                        title: "Notifications",
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                NavigationLink(destination: PrivacySettingsView()) {
                                    SettingsRow(
                                        icon: "lock.fill",
                                        title: "Privacy",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        
                        // Support Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Support")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    // Open help center
                                }) {
                                    SettingsRow(
                                        icon: "questionmark.circle.fill",
                                        title: "Help Center",
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                Button(action: {
                                    // Open feedback
                                }) {
                                    SettingsRow(
                                        icon: "envelope.fill",
                                        title: "Send Feedback",
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                NavigationLink(destination: AboutView()) {
                                    SettingsRow(
                                        icon: "info.circle.fill",
                                        title: "About",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Danger Zone")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.red)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                Button(action: {
                                    showLogoutAlert = true
                                }) {
                                    SettingsRow(
                                        icon: "rectangle.portrait.and.arrow.right.fill",
                                        title: "Sign Out",
                                        showChevron: false,
                                        textColor: .red
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                Button(action: {
                                    showDeleteAccountAlert = true
                                }) {
                                    SettingsRow(
                                        icon: "trash.fill",
                                        title: "Delete Account",
                                        showChevron: false,
                                        textColor: .red
                                    )
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        
                        // App Version
                        Text("Version 1.0.0")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .padding(.top, 8)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authManager.logout()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // TODO: Implement account deletion
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let showChevron: Bool
    var textColor: Color = .black
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(textColor == .red ? .red : Color(hex: "007AFF"))
                .frame(width: 28, height: 28)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(textColor)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "C7C7CC"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var giftsReceived = true
    @State private var friendRequests = true
    @State private var achievements = true
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(spacing: 0) {
                            Toggle(isOn: $pushEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "007AFF"))
                                        .frame(width: 28)
                                    Text("Push Notifications")
                                        .font(.system(size: 17))
                                }
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            Toggle(isOn: $emailEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "007AFF"))
                                        .frame(width: 28)
                                    Text("Email Notifications")
                                        .font(.system(size: 17))
                                }
                            }
                            .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    
                    // Notification Types
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Notification Types")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            Toggle(isOn: $giftsReceived) {
                                Text("Gifts Received")
                                    .font(.system(size: 17))
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            Toggle(isOn: $friendRequests) {
                                Text("Friend Requests")
                                    .font(.system(size: 17))
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            Toggle(isOn: $achievements) {
                                Text("Achievements")
                                    .font(.system(size: 17))
                            }
                            .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Settings View

struct PrivacySettingsView: View {
    @State private var profilePrivate = false
    @State private var showPoints = true
    @State private var showActivity = true
    
    var body: some View {
        ZStack {
            Color(hex: "F2F2F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(spacing: 0) {
                            Toggle(isOn: $profilePrivate) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Private Profile")
                                        .font(.system(size: 17))
                                    Text("Only friends can see your profile")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                }
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            Toggle(isOn: $showPoints) {
                                Text("Show Points Balance")
                                    .font(.system(size: 17))
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            Toggle(isOn: $showActivity) {
                                Text("Show Activity")
                                    .font(.system(size: 17))
                            }
                            .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(hex: "F2F2F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon
                    VStack(spacing: 16) {
                        Text("🎁")
                            .font(.system(size: 100))
                        
                        Text("Fetch Campus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    .padding(.top, 40)
                    
                    // Description
                    Text("Gift points to friends and build your social status by being generous.")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Links
                    VStack(spacing: 0) {
                        Button(action: {
                            // Open terms
                        }) {
                            HStack {
                                Text("Terms of Service")
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            .padding(16)
                        }
                        
                        Divider()
                            .padding(.leading, 16)
                        
                        Button(action: {
                            // Open privacy
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "8E8E93"))
                            }
                            .padding(16)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    // Copyright
                    Text("© 2025 Fetch Campus. All rights reserved.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .padding(.top, 20)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
}


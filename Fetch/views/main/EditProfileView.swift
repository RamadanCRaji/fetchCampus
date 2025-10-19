import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var school: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Picture Section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 128, height: 128)
                                
                                Circle()
                                    .fill(Color(hex: "E3F2FD"))
                                    .frame(width: 120, height: 120)
                                
                                Text(String(authManager.currentUser?.name.prefix(1) ?? "M").uppercased())
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                            
                            Button(action: {
                                // Handle profile picture change
                            }) {
                                Text("Change Photo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                        }
                        .padding(.top, 24)
                        
                        // Edit Form Card
                        VStack(spacing: 0) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Name")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                TextField("Full Name", text: $name)
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                    .textContentType(.name)
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Username Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Username")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                HStack(spacing: 4) {
                                    Text("@")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    
                                    TextField("username", text: $username)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .textContentType(.username)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // School Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("School")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                TextField("School Name", text: $school)
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                            }
                            .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Info Text
                        Text("Changes to your profile will be visible to all users")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Handle save
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .onAppear {
                // Initialize with current user data
                if let user = authManager.currentUser {
                    name = user.name
                    username = user.username
                    school = user.school
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthenticationManager())
}


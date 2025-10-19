//
//  SignUpView.swift
//  Fetch
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    // Form fields
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var studentId = ""
    @State private var selectedSchool = ""
    
    // Password visibility
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // Validation states
    @State private var showErrors = false
    @State private var nameError = ""
    @State private var usernameError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @State private var studentIdError = ""
    @State private var schoolError = ""
    
    // UI states
    @State private var isLoading = false
    @State private var showingSchoolPicker = false
    @State private var navigateToVerification = false
    @State private var showSuccessAlert = false
    @State private var navigateBack = false
    
    let schools = [
        "Select your school",
        "University of Wisconsin-Madison",
        "Suffolk University",
        "Other"
    ]
    
    var body: some View {
        if navigateBack {
            WelcomeView()
                .environmentObject(authManager)
        } else {
            ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Form Card
                        VStack(spacing: 0) {
                            // Name Field
                            FormField(
                                label: "Name",
                                placeholder: "Madison Chen",
                                text: $name,
                                hasError: showErrors && !nameError.isEmpty
                            )
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Username Field
                            HStack(spacing: 8) {
                                Text("@")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                FormField(
                                    label: "Username",
                                    placeholder: "madisonc",
                                    text: $username,
                                    hasError: showErrors && !usernameError.isEmpty,
                                    showLabel: true
                                )
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            }
                            .padding(.leading, 16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Email Field
                            FormField(
                                label: "Email",
                                placeholder: "name@wisc.edu",
                                text: $email,
                                hasError: showErrors && !emailError.isEmpty
                            )
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                HStack {
                                    if showPassword {
                                        TextField("Create a password", text: $password)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Create a password", text: $password)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .textContentType(.newPassword)
                                    }
                                    
                                    Button(action: {
                                        showPassword.toggle()
                                    }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(Color(hex: "8E8E93"))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(16)
                            .overlay(
                                Group {
                                    if showErrors && !passwordError.isEmpty {
                                        Rectangle()
                                            .fill(Color(hex: "FF3B30"))
                                            .frame(width: 3)
                                            .frame(maxHeight: .infinity)
                                    }
                                },
                                alignment: .leading
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Confirm Password")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8E8E93"))
                                
                                HStack {
                                    if showConfirmPassword {
                                        TextField("Re-enter your password", text: $confirmPassword)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Re-enter your password", text: $confirmPassword)
                                            .font(.system(size: 17))
                                            .foregroundColor(.black)
                                            .textContentType(.newPassword)
                                    }
                                    
                                    Button(action: {
                                        showConfirmPassword.toggle()
                                    }) {
                                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(Color(hex: "8E8E93"))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(16)
                            .overlay(
                                Group {
                                    if showErrors && !confirmPasswordError.isEmpty {
                                        Rectangle()
                                            .fill(Color(hex: "FF3B30"))
                                            .frame(width: 3)
                                            .frame(maxHeight: .infinity)
                                    }
                                },
                                alignment: .leading
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Student ID Field
                            FormField(
                                label: "Student ID",
                                placeholder: "9081234567",
                                text: $studentId,
                                hasError: showErrors && !studentIdError.isEmpty
                            )
                            .keyboardType(.numberPad)
                            .onChange(of: studentId) { oldValue, newValue in
                                if newValue.count > 10 {
                                    studentId = String(newValue.prefix(10))
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // School Picker
                            Button(action: {
                                showingSchoolPicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("School")
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: "8E8E93"))
                                        
                                        Text(selectedSchool.isEmpty ? "Select your school" : selectedSchool)
                                            .font(.system(size: 17))
                                            .foregroundColor(selectedSchool.isEmpty ? Color(hex: "8E8E93") : .black)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                }
                                .padding(16)
                            }
                            .overlay(
                                Group {
                                    if showErrors && !schoolError.isEmpty {
                                        Rectangle()
                                            .fill(Color(hex: "FF3B30"))
                                            .frame(width: 3)
                                            .frame(maxHeight: .infinity)
                                    }
                                },
                                alignment: .leading
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        
                        // Error Messages
                        if showErrors {
                            VStack(alignment: .leading, spacing: 8) {
                                if !nameError.isEmpty {
                                    ErrorText(nameError)
                                }
                                if !usernameError.isEmpty {
                                    ErrorText(usernameError)
                                }
                                if !emailError.isEmpty {
                                    ErrorText(emailError)
                                }
                                if !passwordError.isEmpty {
                                    ErrorText(passwordError)
                                }
                                if !confirmPasswordError.isEmpty {
                                    ErrorText(confirmPasswordError)
                                }
                                if !studentIdError.isEmpty {
                                    ErrorText(studentIdError)
                                }
                                if !schoolError.isEmpty {
                                    ErrorText(schoolError)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Continue Button
                        Button(action: handleContinue) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid && !isLoading ? Color(hex: "007AFF") : Color.gray)
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "007AFF").opacity(0.2), radius: 8, y: 2)
                        .disabled(!isFormValid || isLoading)
                        
                        // Legal Text
                        Text("By continuing, you agree to our **Terms of Service** and **Privacy Policy**")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "8E8E93"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .sheet(isPresented: $showingSchoolPicker) {
                SchoolPickerView(selectedSchool: $selectedSchool, schools: schools)
            }
            .alert("Account Created!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {
                    navigateBack = true
                }
            } message: {
                Text("Please check your email (\(email)) to verify your account before logging in.")
            }
        }
    }
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !studentId.isEmpty &&
        !selectedSchool.isEmpty &&
        selectedSchool != "Select your school"
    }
    
    func validateForm() -> Bool {
        showErrors = true
        
        // Reset errors
        nameError = ""
        usernameError = ""
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
        studentIdError = ""
        schoolError = ""
        
        var isValid = true
        
        // Validate name
        if name.isEmpty {
            nameError = "Name is required"
            isValid = false
        } else if !ValidationHelper.isValidName(name) {
            nameError = "Name must be at least 2 characters"
            isValid = false
        }
        
        // Validate username
        if username.isEmpty {
            usernameError = "Username is required"
            isValid = false
        } else if !ValidationHelper.isValidUsername(username) {
            usernameError = "Username must be at least 3 characters (alphanumeric and underscore only)"
            isValid = false
        }
        
        // Validate email
        if email.isEmpty {
            emailError = "Email is required"
            isValid = false
        } else if !ValidationHelper.isValidEmail(email) {
            emailError = "Please use a valid .edu email"
            isValid = false
        }
        
        // Validate password
        if password.isEmpty {
            passwordError = "Password is required"
            isValid = false
        } else if !validatePassword(password) {
            passwordError = "Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 number"
            isValid = false
        }
        
        // Validate confirm password
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
            isValid = false
        }
        
        // Validate student ID
        if studentId.isEmpty {
            studentIdError = "Student ID is required"
            isValid = false
        } else if !ValidationHelper.isValidStudentId(studentId) {
            studentIdError = "Student ID must be 8-10 digits"
            isValid = false
        }
        
        // Validate school
        if selectedSchool.isEmpty || selectedSchool == "Select your school" {
            schoolError = "Please select your school"
            isValid = false
        }
        
        return isValid
    }
    
    // Password validation function
    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // MARK: - Actions
    
    func handleContinue() {
        guard validateForm() else { return }
        
        isLoading = true
        
        Task {
            do {
                // Check username uniqueness
                let usernameAvailable = try await FirestoreService.shared.isUsernameAvailable(username)
                if !usernameAvailable {
                    await MainActor.run {
                        usernameError = "Username already taken"
                        isLoading = false
                    }
                    return
                }
                
                // Check student ID uniqueness
                let studentIdAvailable = try await FirestoreService.shared.isStudentIdAvailable(studentId)
                if !studentIdAvailable {
                    await MainActor.run {
                        studentIdError = "This Student ID is already registered"
                        isLoading = false
                    }
                    return
                }
                
                // Create user data
                let userData: [String: Any] = [
                    "name": name,
                    "username": username.lowercased(),
                    "email": email,
                    "studentId": studentId,
                    "school": selectedSchool
                ]
                
                // Sign up with actual password
                try await authManager.signUp(email: email, password: password, userData: userData)
                
                await MainActor.run {
                    isLoading = false
                    // Don't show alert or navigate back
                    // FetchApp will automatically show VerificationRequiredView
                    // because isAuthenticated = true and isEmailVerified = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    emailError = authManager.errorMessage ?? "Something went wrong"
                }
            }
        }
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false
    var showLabel: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8E8E93"))
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .foregroundColor(.black)
        }
        .padding(16)
        .overlay(
            Group {
                if hasError {
                    Rectangle()
                        .fill(Color(hex: "FF3B30"))
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                }
            },
            alignment: .leading
        )
    }
}

// MARK: - Error Text Component

struct ErrorText: View {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(Color(hex: "FF3B30"))
    }
}

// MARK: - School Picker View

struct SchoolPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedSchool: String
    let schools: [String]
    
    var body: some View {
        NavigationView {
            List(schools, id: \.self) { school in
                Button(action: {
                    if school != "Select your school" {
                        selectedSchool = school
                    }
                    dismiss()
                }) {
                    HStack {
                        Text(school)
                            .foregroundColor(school == "Select your school" ? Color(hex: "8E8E93") : .black)
                        Spacer()
                        if school == selectedSchool {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "007AFF"))
                        }
                    }
                }
            }
            .navigationTitle("Select School")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationManager())
}


**Problem:** After successful signup, the Create Account screen stays visible instead of navigating away.

**Solution:** Navigate back to WelcomeView with success alert after signup.

---

### FIX REQUIRED IN: `views/Auth/SignUpView.swift`

**Step 1:** Add navigation state variable

Add this at the top with other @State variables:

```swift
@State private var showSuccessAlert = false
@State private var navigateBack = false
```

**Step 2:** Update handleContinue() function

After successful signup (after `try await authManager.signUp(...)`), add:

```swift
// Inside the do block, after successful signup:
isLoading = false
showSuccessAlert = true

// Dismiss after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    navigateBack = true
}
```

**Step 3:** Update body to handle navigation

Wrap the entire view body with this check:

```swift
var body: some View {
    if navigateBack {
        WelcomeView()
            .environmentObject(authManager)
    } else {
        // ... existing NavigationStack code ...
    }
}
```

**Step 4:** Add success alert

Add this modifier to the NavigationStack:

```swift
.alert("Account Created!", isPresented: $showSuccessAlert) {
    Button("OK", role: .cancel) {
        navigateBack = true
    }
} message: {
    Text("Please check your email (\(email)) to verify your account before logging in.")
}
```

---

### EXPECTED BEHAVIOR AFTER FIX:

1. User fills signup form
2. Taps Continue
3. Loading spinner shows
4. Alert appears: "Account Created! Please check your email (user@wisc.edu) to verify your account before logging in."
5. After tapping OK or 2 seconds, navigates back to Welcome screen
6. User can then tap "I Have an Account" → Login → After email verification, login works

---

### COMPLETE CODE STRUCTURE:

```swift
struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss

    // ... existing @State variables ...
    @State private var showSuccessAlert = false
    @State private var navigateBack = false

    var body: some View {
        if navigateBack {
            WelcomeView()
                .environmentObject(authManager)
        } else {
            NavigationStack {
                ScrollView {
                    // ... existing form UI ...
                }
                .navigationTitle("Create Account")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(Color(hex: "007AFF"))
                        }
                    }
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
    }

    func handleContinue() {
        validateForm()

        if errors.isEmpty {
            isLoading = true

            Task {
                do {
                    // Generate password or use form password
                    let password = self.password.isEmpty ? generateSecurePassword() : self.password

                    // Sign up
                    try await authManager.signUp(
                        email: email,
                        password: password,
                        userData: [
                            "name": name,
                            "username": username,
                            "email": email,
                            "studentId": studentId,
                            "school": school,
                            "totalPointsEarned": 500,
                            "totalPointsGifted": 0,
                            "giftsGiven": 0,
                            "giftsReceived": 0,
                            "rank": 999,
                            "generosityLevel": "Newbie",
                            "generosityScore": 0,
                            "lastActive": Timestamp(),
                            "achievements": [],
                            "isPrivate": false
                        ]
                    )

                    // SUCCESS!
                    isLoading = false
                    showSuccessAlert = true

                    // Auto-dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navigateBack = true
                    }

                } catch {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func generateSecurePassword() -> String {
        // Generate random secure password
        let length = 12
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
        return String((0..<length).map{ _ in characters.randomElement()! })
    }
}
```

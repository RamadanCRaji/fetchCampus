## 🔴 BUG FIX: Email Verification Link Expires or Shows "Already Used" Error

**Problem Statement:**
After creating an account, when clicking the email verification link, Firebase shows error: "Try verifying your email again - Your request to verify your email has expired or the link has already been used."

**Root Causes:**

1. User clicks verification link multiple times
2. Verification link expires (Firebase default: 1 hour)
3. Email verification action URL not properly configured
4. User tries to verify after link is consumed

**Required Fix:**
Improve the verification flow to handle edge cases and provide better user experience.

---

### IMPLEMENTATION FIX 1: Update Email Verification Settings in Firebase Console

**Manual Steps in Firebase Console:**

1. Go to Firebase Console → Authentication → Templates
2. Click "Email address verification"
3. Update the action URL to your app's URL
4. Set verification link to not expire (or set longer expiration)

**Current Issue:** The default Firebase verification link settings may be too restrictive.

---

### IMPLEMENTATION FIX 2: Improve Verification Link Generation

**File:** `services/AuthenticationManager.swift`

**Update the `signUp()` function** to use custom action code settings:

**Find this code:**

```swift
// Send verification email
try await authResult.user.sendEmailVerification()
```

**Replace with:**

```swift
// Send verification email with custom settings
let actionCodeSettings = ActionCodeSettings()
actionCodeSettings.url = URL(string: "https://fetchcampus.page.link/verify")! // Your app URL
actionCodeSettings.handleCodeInApp = true
actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.fetchcampus.app")

do {
    try await authResult.user.sendEmailVerification(with: actionCodeSettings)
} catch {
    // Fallback to simple verification if custom settings fail
    try await authResult.user.sendEmailVerification()
}
```

---

### IMPLEMENTATION FIX 3: Improve Resend Verification Flow

**File:** `services/AuthenticationManager.swift`

**Update the `resendVerificationEmail()` function:**

**Current code:**

```swift
func resendVerificationEmail() async throws {
    guard let user = Auth.auth().currentUser else {
        throw AuthError.noUser
    }

    // Reload user to get latest verification status
    try await user.reload()

    // Check if already verified
    if user.isEmailVerified {
        throw AuthError.alreadyVerified
    }

    // Send verification email
    try await user.sendEmailVerification()
}
```

**Replace with:**

```swift
func resendVerificationEmail() async throws {
    guard let user = Auth.auth().currentUser else {
        throw AuthError.noUser
    }

    // Reload user to get latest verification status
    try await user.reload()

    // Check if already verified
    if user.isEmailVerified {
        // If already verified, update Firestore and authenticate
        try? await Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .updateData(["emailVerified": true])

        await MainActor.run {
            self.isEmailVerified = true
            self.isAuthenticated = true
        }

        await fetchUserData(userId: user.uid)
        throw AuthError.alreadyVerified
    }

    // Send new verification email with longer expiration
    let actionCodeSettings = ActionCodeSettings()
    actionCodeSettings.url = URL(string: "https://fetchcampus.page.link/verify")!
    actionCodeSettings.handleCodeInApp = true
    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.fetchcampus.app")

    do {
        try await user.sendEmailVerification(with: actionCodeSettings)
    } catch {
        // Fallback to simple verification
        try await user.sendEmailVerification()
    }
}
```

---

### IMPLEMENTATION FIX 4: Better Error Handling in VerificationRequiredView

**File:** `views/Auth/VerificationRequiredView.swift` (if it exists)

**Add better error messaging:**

```swift
@State private var verificationError: String?
@State private var isCheckingVerification = false

// In the resend button action:
Button(action: {
    Task {
        do {
            try await authManager.resendVerificationEmail()
            // Reset countdown
            secondsRemaining = 60
            canResend = false
        } catch AuthError.alreadyVerified {
            // User is already verified! Navigate to home
            verificationError = nil
            // Trigger navigation to home
        } catch {
            // Show user-friendly error
            if error.localizedDescription.contains("expired") ||
               error.localizedDescription.contains("already been used") {
                verificationError = "Previous link expired. We've sent you a new verification email. Please check your inbox."
            } else {
                verificationError = "Failed to send email. Please try again."
            }
        }
    }
}) {
    Text("Resend Email")
}

// Display error if exists
if let error = verificationError {
    Text(error)
        .font(.system(size: 13))
        .foregroundColor(.red)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
}
```

---

### IMPLEMENTATION FIX 5: Add Manual "I've Verified" Check Button

**File:** `views/Auth/VerificationRequiredView.swift`

**Add a prominent button to manually check verification status:**

```swift
VStack(spacing: 16) {
    // ... existing verification UI ...

    // Manual check button
    Button(action: {
        isCheckingVerification = true
        Task {
            await authManager.checkEmailVerificationStatus()

            // Give it a moment to update
            try? await Task.sleep(nanoseconds: 500_000_000)

            isCheckingVerification = false

            // If still not verified, show message
            if !authManager.isEmailVerified {
                verificationError = "Email not verified yet. Please click the link in your email first, then try again."
            }
        }
    }) {
        HStack {
            if isCheckingVerification {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }
            Text(isCheckingVerification ? "Checking..." : "I've Verified My Email")
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color(hex: "007AFF"))
        .cornerRadius(12)
    }
    .disabled(isCheckingVerification)
    .padding(.horizontal, 32)

    // Resend button below
    if canResend {
        Button(action: resendEmail) {
            Text("Resend Verification Email")
        }
    } else {
        Text("Resend in \(secondsRemaining)s")
            .foregroundColor(.gray)
    }
}
```

---

### QUICK WORKAROUND FOR TESTING

**If you need to test right now and keep getting the error:**

1. **Delete the user from Firebase:**

   -  Firebase Console → Authentication → Users
   -  Find your email, click trash icon
   -  Also delete from Firestore → users collection

2. **Create account again:**

   -  Fresh signup will generate new verification link
   -  Click link within 1 hour
   -  Should work

3. **Or manually verify in Firebase Console:**
   -  Firebase Console → Authentication → Users
   -  Find your user
   -  Click the three dots → "Edit user"
   -  Check "Email verified"
   -  Save

---

### ROOT CAUSE EXPLANATION

Firebase verification links are **single-use** and expire by default. The error happens when:

1. **Link already clicked:** User clicked once, it worked, but trying again
2. **Link expired:** Default 1 hour expiration
3. **Multiple links sent:** Old link invalidated when new one sent

**The fixes above:**

-  ✅ Generate fresh links with custom settings
-  ✅ Handle "already verified" case gracefully
-  ✅ Give users manual check button
-  ✅ Better error messages
-  ✅ Auto-detect when already verified

---

### CURSOR EXECUTION COMMAND

Tell Cursor AI:

```
Fix the email verification link expiration issue in AuthenticationManager.swift

Make these changes from instructions.md "Email Verification Link Expires" section:

1. Update signUp() to use ActionCodeSettings for verification email
2. Update resendVerificationEmail() to:
   - Check if already verified and handle gracefully
   - Use ActionCodeSettings with fallback
3. Add better error handling for expired/used links

Also update VerificationRequiredView.swift to:
- Add manual "I've Verified My Email" check button
- Show user-friendly error messages
- Handle already-verified case

Import ActionCodeSettings from FirebaseAuth if needed.
```

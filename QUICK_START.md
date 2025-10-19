# 🚀 Quick Start Guide - 3 Steps to Launch

## ✅ Your App Is Built! Now Configure Firebase:

### Step 1: Firebase Console (10 min)

1. Go to **[console.firebase.google.com](https://console.firebase.google.com)**
2. Click **"Add project"** → Name: "Fetch Campus"
3. Click iOS icon → Bundle ID: `com.yourname.Fetch`
4. **Download `GoogleService-Info.plist`**
5. Enable **Authentication** → Email/Password
6. Create **Firestore Database** → Test mode

### Step 2: Add Firebase to Xcode (5 min)

1. **Drag `GoogleService-Info.plist` into Xcode**

   -  Place next to `FetchApp.swift`
   -  ✅ Check "Copy items if needed"

2. **Add Firebase SDK:**
   -  File → Add Package Dependencies
   -  URL: `https://github.com/firebase/firebase-ios-sdk`
   -  Select:
      -  ✅ FirebaseAuth
      -  ✅ FirebaseFirestore
      -  ✅ FirebaseFirestoreSwift

### Step 3: Build & Run! (2 min)

1. **Cmd + B** (Build)
2. **Cmd + R** (Run)
3. **Test the flow:**
   -  Splash → Welcome → Sign Up
   -  Create account → Check Firebase Console
   -  Login → Home screen with real-time data!

---

## 🎯 That's It!

✅ **14 files created**  
✅ **Complete authentication system**  
✅ **Real-time Firebase integration**  
✅ **Beautiful UI matching Figma**

**Need detailed help?** See `FIREBASE_SETUP.md`

---

## 📱 Test Your App

**Sign Up Test:**

-  Name: `Test User`
-  Username: `testuser`
-  Email: `test@wisc.edu`
-  Student ID: `1234567890`
-  School: Select from list

**Check Firebase:**

-  Authentication → User appears
-  Firestore → User document created

**Login & Enjoy!** 🎉

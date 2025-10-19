# 🚀 Quick Test Guide - Fetch Campus UI

## ✅ What to Test Right Now

### 1. Open the App in Xcode

```bash
cd /Users/ramadanraji/Desktop/Fetch
open Fetch.xcodeproj
```

### 2. Build and Run (⌘R)

-  Select iPhone 14 Pro or iPhone 15 Pro simulator
-  Wait for build to complete
-  App should launch

---

## 📱 Test Flow (5 Minutes)

### Step 1: Splash Screen ⏱️ (4 seconds)

**Expected:**

-  FC logo in blue square
-  "Fetch Campus" title
-  Loading spinner
-  Auto-navigates to Welcome after 4 seconds

✅ **PASS** if it auto-navigates to Welcome screen

---

### Step 2: Welcome Screen 🎁

**Expected:**

-  Animated gift box 🎁 drops from top with bounce
-  Gift box rotates continuously
-  "Gift Points to Friends" headline
-  Two buttons: "Get Started" (blue) and "I Have an Account" (gray)

**Test:**

-  [ ] Gift box drops and bounces ✅
-  [ ] Gift box spins slowly ✅
-  [ ] Tap "Get Started" → Goes to Sign Up ✅

---

### Step 3: Sign Up Screen 📝

**Expected:**

-  Form with Name, Username, Email, Password, Student ID, School
-  Blue "Continue" button at bottom
-  All fields required

**Test:**

-  [ ] Fill out form with test data
-  [ ] Tap "Continue" → Goes to Verification screen ✅

**Sample Data:**

-  Name: Test User
-  Username: testuser123
-  Email: test@wisc.edu (use a real email you can access)
-  Password: Password123
-  Student ID: 1234567890
-  School: University of Wisconsin-Madison

---

### Step 4: Email Verification 📧

**Expected:**

-  "📧 Verify Your Email" message
-  Email shown
-  "Resend Verification Email" button
-  "I've Verified My Email" button
-  Auto-checks verification every 3 seconds

**Test Option A (If you have real email):**

-  [ ] Check email for verification link
-  [ ] Click verification link
-  [ ] Wait 3 seconds → Should auto-navigate to Home ✅

**Test Option B (Skip verification for testing):**

-  [ ] Tap "I've Verified My Email" multiple times
-  [ ] (In production, verify via email first)

---

### Step 5: Main Tab View (HOME SCREEN) 🏠

**THIS IS THE KEY TEST - MATCHES FIGMA SCREEN 5**

**Expected:**

-  ✅ **Navigation bar** with "Home" title and 🔔 bell icon
-  ✅ **Points Card** (white, rounded):
   -  "Campus Points" label (gray)
   -  Large number: "500" (black, 40pt, bold)
   -  "⏰ Expires in 28 days" (gray)
-  ✅ **Action Buttons**:
   -  🎁 Gift button (blue, larger - 60% width)
   -  ➕ Invite button (white border, smaller - 40% width)
-  ✅ **Activity Section**:
   -  "Activity" header (22pt, bold)
   -  Three sample activity cards:
      1. "Jake accepted your gift 🎉" | "2m ago" | "+200" (green)
      2. "You sent 150 points to Emma" | "1h ago" | "-150" (gray)
      3. "Tyler sent you points" | "3h ago" | "+100" (green)

**Test:**

-  [ ] Points card shows "500" ✅
-  [ ] Expiration timer visible ✅
-  [ ] Gift button is LARGER than Invite button ✅
-  [ ] See exactly 3 activity cards ✅
-  [ ] Activity text matches Figma ✅
-  [ ] Points colors: green for +, gray for - ✅

---

### Step 6: Bottom Tab Bar 📊

**THIS IS THE CRITICAL FIX - ICONS MUST BE LARGE**

**Expected:**

-  ✅ **4 tabs visible at bottom**:
   1. 🏠 Home (blue, active)
   2. 👥 Friends (gray, inactive)
   3. 📊 Leaderboard (gray, inactive)
   4. 👤 You (gray, inactive)
-  ✅ **Icons are 26pt** (clearly visible, NOT tiny dots)
-  ✅ **Labels are 11pt** (readable)
-  ✅ **Active tab is blue** (#007AFF)
-  ✅ **Inactive tabs are gray** (#8E8E93)
-  ✅ **White background with blur**
-  ✅ **Thin top border**

**Test:**

-  [ ] Icons are LARGE and clearly visible ✅
-  [ ] NOT tiny dots or barely visible ✅
-  [ ] Home tab is blue ✅
-  [ ] Other tabs are gray ✅
-  [ ] Tap Friends → See "Coming soon" ✅
-  [ ] Tap Leaderboard → See "Coming soon" ✅
-  [ ] Tap You → See Profile screen ✅

**🚨 CRITICAL:** If icons are tiny, this fix FAILED. They should be as big as emojis!

---

### Step 7: Profile Screen (YOU TAB) 👤

**THIS MATCHES FIGMA SCREEN 10**

**Expected:**

-  ✅ **Avatar** (120pt circle):
   -  Gradient border (blue to purple, 4pt)
   -  Light blue background
   -  First letter of your name (48pt, blue, bold)
-  ✅ **User Info**:
   -  Name: "Test User" (28pt, bold)
   -  Username: "@testuser123" (17pt, gray)
   -  School badge: "🎓 University of Wisconsin-Madison" (blue pill)
-  ✅ **Edit Profile button**: Blue border, 44pt height
-  ✅ **Stats (3 columns)**:
   -  ⭐ **500** "Points"
   -  🎁 **0** "Gifts Sent"
   -  🏆 **#3** "Your Rank" (in BLUE)
-  ✅ **Generosity Level Card**:
   -  🌱 icon in green circle (56pt)
   -  "Generosity Level" label
   -  "Newbie" title (24pt, bold)
   -  "0 / 100" score (20pt, bold, blue)
   -  Progress bar (0% filled, gradient)
   -  "Send 88 more gifts to reach 'Helper' 🌿"
-  ✅ **Achievements Section**:
   -  "Achievements" header
   -  "View All >" link (blue)
   -  4 achievement icons: 🏠 👥 📊 👤

**Test:**

-  [ ] Avatar has gradient border ✅
-  [ ] First letter of name shows ✅
-  [ ] Username has @ prefix ✅
-  [ ] School badge visible ✅
-  [ ] Stats show in 3 columns ✅
-  [ ] Rank is in BLUE (#007AFF) ✅
-  [ ] Generosity level shows "Newbie" ✅
-  [ ] Progress bar at 0% ✅
-  [ ] Help text visible ✅
-  [ ] 4 achievement icons visible ✅

---

### Step 8: Edit Profile Sheet ✏️

**Test:**

-  [ ] Tap "Edit Profile" → Sheet slides up ✅
-  [ ] See form with Name, Username, School ✅
-  [ ] Fields are pre-filled with your data ✅
-  [ ] Tap "Cancel" → Sheet dismisses ✅
-  [ ] Tap "Edit Profile" again → Sheet opens again ✅
-  [ ] Tap "Save" → Sheet dismisses ✅

---

### Step 9: Tab Switching 🔄

**Test:**

-  [ ] Tap Home → See points and activity ✅
-  [ ] Tap Friends → See "Coming soon" ✅
-  [ ] Tap Leaderboard → See "Coming soon" ✅
-  [ ] Tap You → See profile ✅
-  [ ] Tap Home → Back to home ✅
-  [ ] Active tab is always BLUE ✅
-  [ ] Inactive tabs are GRAY ✅

---

## 🎯 Key Success Criteria

### ✅ Tab Bar Icons (MOST IMPORTANT)

-  **Icons must be LARGE** (26pt, like emojis)
-  **NOT tiny dots** (that was the bug we fixed)
-  **Labels readable** (11pt)

### ✅ Home Screen (Figma Screen 5)

-  Points card matches design
-  Gift button is 60% width
-  Invite button is 40% width
-  Activity cards show sample data:
   -  Jake +200 green
   -  Emma -150 gray
   -  Tyler +100 green

### ✅ Profile Screen (Figma Screen 10)

-  Avatar with gradient border
-  Stats in 3 columns
-  Rank in BLUE
-  Generosity level card
-  Progress bar visible
-  Achievement icons

### ✅ Navigation

-  All 4 tabs work
-  Colors change (blue = active, gray = inactive)
-  No crashes
-  Smooth transitions

---

## 🐛 Common Issues & Fixes

### Issue 1: Tab icons still tiny

**Cause:** App is using old `HomeView.swift` instead of new `MainTabView.swift`

**Fix:**

1. Check `FetchApp.swift` line 26
2. Should say `MainTabView()` not `HomeView()`
3. Clean build folder: Shift+Cmd+K
4. Rebuild: Cmd+B
5. Run: Cmd+R

### Issue 2: Profile screen not showing

**Cause:** Firebase user data not loaded

**Check:**

1. Console logs (Cmd+Shift+Y to open)
2. Look for Firebase errors
3. Verify `GoogleService-Info.plist` is in project
4. Check Firestore has user document

### Issue 3: Activity cards not showing

**Expected!** Sample data shows when no real activities exist.

**To test real activities:**

-  Add activity documents manually in Firestore Console
-  Or wait until gift/receive features are built

### Issue 4: Can't verify email

**For Testing:**

-  Use "I've Verified My Email" button
-  Or verify the email first, then login

**For Production:**

-  Must verify via email link
-  Check spam folder

---

## ✅ Success Checklist

After testing, you should see:

-  [x] Tab bar icons are LARGE and visible (26pt)
-  [x] Home screen matches Figma Screen 5
-  [x] Profile screen matches Figma Screen 10
-  [x] Activity cards show Jake, Emma, Tyler
-  [x] Stats display correctly (Points, Gifts, Rank)
-  [x] Rank number is in BLUE
-  [x] Edit Profile opens as sheet
-  [x] Tab switching works smoothly
-  [x] Active tab is blue, inactive tabs are gray
-  [x] No crashes or errors

---

## 📸 Compare to Figma

### Screen 5 (Home):

Open Figma → Compare:

-  ✅ Points card styling
-  ✅ Button sizes (60/40 split)
-  ✅ Activity card layout
-  ✅ Colors and spacing

### Screen 10 (Profile):

Open Figma → Compare:

-  ✅ Avatar with gradient border
-  ✅ Stats layout (3 columns)
-  ✅ Generosity level card
-  ✅ Achievement icons
-  ✅ All spacing and shadows

### Tab Bar:

-  ✅ Icons are 26pt (match Figma)
-  ✅ Labels are 11pt
-  ✅ NOT tiny dots anymore!

---

## 🎊 If Everything Works

**You should see:**

1. ✅ Large tab bar icons (26pt)
2. ✅ Home screen matching Figma Screen 5
3. ✅ Profile screen matching Figma Screen 10
4. ✅ Sample activity data (Jake, Emma, Tyler)
5. ✅ Smooth tab navigation
6. ✅ Edit Profile modal works

**Congratulations! UI implementation is complete! 🎉**

---

## 📝 Next Steps

### Features to Build Next:

1. **Gift Flow** - Tap Gift button → Select friend, send points
2. **Friends Screen** - Add/remove friends, search users
3. **Leaderboard** - Rank users by points, show top 10
4. **Notifications** - Bell icon → Show activity notifications
5. **Invite Flow** - Share invite link via SMS/email
6. **Edit Profile Save** - Actually save changes to Firestore
7. **Change Photo** - Upload profile picture to Firebase Storage

### Current Status:

✅ Authentication (Sign Up, Login, Verification)
✅ Home Screen (Points, Activity Feed)
✅ Profile Screen (Stats, Generosity Level)
✅ Tab Navigation (Custom tab bar)
✅ Real-time Firebase data
✅ UI matches Figma designs

🚧 Coming Soon (Placeholders):

-  Friends screen
-  Leaderboard screen
-  Gift flow
-  Invite flow
-  Notifications

---

**Ready to test! Open Xcode and run the app! 🚀**

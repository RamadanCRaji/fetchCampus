# 🔥 Firestore Database Setup - Required Indexes

## ⚠️ IMPORTANT: Complete These Steps Before Using The App

The app requires specific Firestore indexes to function properly. Without these indexes, queries will fail.

---

## 📋 Step-by-Step Setup

### 1. Access Firebase Console

1. Go to https://console.firebase.google.com/
2. Select your project: **"Fetch Campus"**
3. Click **"Firestore Database"** in the left sidebar
4. Click **"Indexes"** tab at the top

---

## 🔍 Required Indexes

### **Collection: `users`**

Create these single-field indexes:

#### Index 1: Username (for search & uniqueness)
- **Collection:** `users`
- **Field:** `username`
- **Order:** Ascending
- **Query scope:** Collection

#### Index 2: Student ID (for uniqueness check)
- **Collection:** `users`
- **Field:** `studentId`
- **Order:** Ascending
- **Query scope:** Collection

#### Index 3: Points (for leaderboard)
- **Collection:** `users`
- **Field:** `points`
- **Order:** Descending
- **Query scope:** Collection

#### Index 4: Total Points Gifted (for ranking)
- **Collection:** `users`
- **Field:** `totalPointsGifted`
- **Order:** Descending
- **Query scope:** Collection

---

### **Collection: `friendships`**

Create these composite indexes:

#### Index 5: User1 + Status
- **Collection:** `friendships`
- **Fields:**
  - `userId1` - Ascending
  - `status` - Ascending
- **Query scope:** Collection

#### Index 6: User2 + Status
- **Collection:** `friendships`
- **Fields:**
  - `userId2` - Ascending
  - `status` - Ascending
- **Query scope:** Collection

---

### **Collection: `transactions`**

Create these indexes:

#### Index 7: ToUserId + CreatedAt
- **Collection:** `transactions`
- **Fields:**
  - `toUserId` - Ascending
  - `createdAt` - Descending
- **Query scope:** Collection

#### Index 8: FromUserId + CreatedAt
- **Collection:** `transactions`
- **Fields:**
  - `fromUserId` - Ascending
  - `createdAt` - Descending
- **Query scope:** Collection

#### Index 9: CreatedAt (global feed)
- **Collection:** `transactions`
- **Field:** `createdAt`
- **Order:** Descending
- **Query scope:** Collection

---

### **Collection: `notifications`**

Create this composite index:

#### Index 10: UserId + Read + CreatedAt
- **Collection:** `notifications`
- **Fields:**
  - `userId` - Ascending
  - `read` - Ascending
  - `createdAt` - Descending
- **Query scope:** Collection

---

## 🛠️ How to Create Indexes

### Method 1: Manual Creation (Firebase Console)

1. Click **"Create Index"** button
2. Select collection (e.g., `users`)
3. Click **"Add Field"**
4. Choose field name (e.g., `username`)
5. Choose sort order (Ascending/Descending)
6. For composite indexes, click **"Add Field"** again
7. Click **"Create Index"**
8. Wait for status to change to **"Enabled"** (1-10 minutes)

### Method 2: Auto-Create via App

Indexes will be auto-created when you run queries that need them:

1. Run the app
2. Try to load friends, leaderboard, or activity feed
3. Check Xcode console for Firebase error messages
4. Firebase will provide a direct link to create the required index
5. Click the link, it will open Firebase Console with pre-filled index settings
6. Click **"Create Index"**
7. Wait for it to enable

**Note:** This method is slower but ensures you only create indexes you actually use.

---

## ✅ Verification

After creating all indexes, verify they're enabled:

1. Go to Firebase Console → Firestore → Indexes
2. Check **"Status"** column for each index
3. All should show **"Enabled"** (green checkmark)
4. If any show **"Building"**, wait a few minutes
5. If any show **"Error"**, delete and recreate

### Index List Should Show:

```
✅ users - username (Ascending)
✅ users - studentId (Ascending)
✅ users - points (Descending)
✅ users - totalPointsGifted (Descending)
✅ friendships - userId1 (Asc), status (Asc)
✅ friendships - userId2 (Asc), status (Asc)
✅ transactions - toUserId (Asc), createdAt (Desc)
✅ transactions - fromUserId (Asc), createdAt (Desc)
✅ transactions - createdAt (Descending)
✅ notifications - userId (Asc), read (Asc), createdAt (Desc)
```

---

## 🚨 Common Issues

### Issue: Index Creation Failed
**Solution:** Delete the failed index and recreate it. Make sure field names match exactly (case-sensitive).

### Issue: Query Still Fails After Index Created
**Solution:** 
1. Check index status is "Enabled" not "Building"
2. Wait 1-2 minutes after enabling
3. Restart the app
4. Clear app data and re-login

### Issue: "Missing Index" Error in Console
**Solution:** 
1. Copy the error message
2. It will contain a direct link to create the index
3. Click the link and confirm creation

### Issue: Too Many Indexes (Cost Concern)
**Solution:** These are the minimal required indexes. Each costs ~$0.01-0.02/month for small apps.

---

## 📊 Why These Indexes Are Needed

### users/username
- **Used by:** Friend search, uniqueness check during sign-up
- **Query:** `whereField("username", isEqualTo: ...)`

### users/studentId
- **Used by:** Uniqueness validation during registration
- **Query:** `whereField("studentId", isEqualTo: ...)`

### users/points
- **Used by:** Leaderboard ranking (by current points)
- **Query:** `order(by: "points", descending: true)`

### users/totalPointsGifted
- **Used by:** Leaderboard ranking (by generosity)
- **Query:** `order(by: "totalPointsGifted", descending: true)`

### friendships/userId1 + status
- **Used by:** Fetching user's friend list
- **Query:** `whereField("userId1", isEqualTo: ...).whereField("status", isEqualTo: "accepted")`

### friendships/userId2 + status
- **Used by:** Fetching user's friend list (reverse lookup)
- **Query:** `whereField("userId2", isEqualTo: ...).whereField("status", isEqualTo: "accepted")`

### transactions/toUserId + createdAt
- **Used by:** Activity feed (received gifts)
- **Query:** `whereField("toUserId", isEqualTo: ...).order(by: "createdAt", descending: true)`

### transactions/fromUserId + createdAt
- **Used by:** Activity feed (sent gifts)
- **Query:** `whereField("fromUserId", isEqualTo: ...).order(by: "createdAt", descending: true)`

### transactions/createdAt
- **Used by:** Global activity feed (admin/future feature)
- **Query:** `order(by: "createdAt", descending: true)`

### notifications/userId + read + createdAt
- **Used by:** Notification center (unread notifications first)
- **Query:** `whereField("userId", isEqualTo: ...).whereField("read", isEqualTo: false).order(by: "createdAt", descending: true)`

---

## 🎯 Quick Setup Checklist

- [ ] Access Firebase Console
- [ ] Navigate to Firestore → Indexes
- [ ] Create 4 indexes for `users` collection
- [ ] Create 2 indexes for `friendships` collection
- [ ] Create 3 indexes for `transactions` collection
- [ ] Create 1 index for `notifications` collection
- [ ] Verify all 10 indexes show "Enabled" status
- [ ] Test app - friends, leaderboard, activity should load
- [ ] No "missing index" errors in console

---

## 📞 Need Help?

If indexes fail to create or queries still don't work:

1. Check Firestore Rules (see `FIREBASE_SETUP.md`)
2. Verify collections exist (check Firestore Data tab)
3. Check console logs for specific error messages
4. Firebase error messages include direct links to fix indexing issues

**Once all indexes are enabled, the app will work at full speed! 🚀**


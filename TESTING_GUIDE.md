# 🧪 Fetch Campus - Testing Guide

## End-to-End Testing Checklist

### Authentication Flow
- [ ] **Sign Up**
  - [ ] Create account with valid credentials
  - [ ] Validation: Empty fields show errors
  - [ ] Validation: Invalid email format shows error
  - [ ] Validation: Weak password shows error
  - [ ] Validation: Password mismatch shows error
  - [ ] Validation: Duplicate username rejected
  - [ ] Validation: Duplicate student ID rejected
  - [ ] Email verification sent successfully
  
- [ ] **Email Verification**
  - [ ] VerificationRequiredView shows for unverified users
  - [ ] Resend button works with cooldown
  - [ ] "I've Verified" button checks status
  - [ ] Auto-navigates to Home after verification
  
- [ ] **Login**
  - [ ] Login with valid credentials succeeds
  - [ ] Login with invalid credentials shows error
  - [ ] Login with non-existent user shows error
  - [ ] Unverified email shows verification screen
  - [ ] Forgot password link works (when implemented)
  
- [ ] **Logout**
  - [ ] Sign out from ProfileView works
  - [ ] Sign out from SettingsView works
  - [ ] Returns to SplashView/WelcomeView

### Home Screen
- [ ] **Points Display**
  - [ ] Current points shown correctly
  - [ ] Points update after transactions
  - [ ] Expiration warning when applicable
  
- [ ] **Activity Feed**
  - [ ] Real transactions displayed
  - [ ] Sample data shown when no transactions
  - [ ] Transaction type (sent/received) colored correctly
  - [ ] Time ago displays correctly
  - [ ] Real-time updates work
  
- [ ] **Navigation**
  - [ ] Gift button opens GiftPointsView
  - [ ] Invite button works (when implemented)
  - [ ] Bell icon shows unread count badge
  - [ ] Bell icon opens NotificationsView

### Friends Flow
- [ ] **Friends List**
  - [ ] Shows all accepted friends
  - [ ] Empty state when no friends
  - [ ] Real-time updates
  
- [ ] **Add Friend**
  - [ ] Search works with partial usernames
  - [ ] Search results filter out current user
  - [ ] Add button sends friend request
  - [ ] "Sent" state shows after request
  - [ ] Empty results state works
  
- [ ] **Friend Requests**
  - [ ] Incoming requests shown (when implemented)
  - [ ] Accept/Decline works (when implemented)
  - [ ] Real-time updates

### Gift Flow
- [ ] **Select Friend**
  - [ ] Friends list loads correctly
  - [ ] Horizontal scroll works
  - [ ] Selection highlights friend
  - [ ] Empty state when no friends
  
- [ ] **Enter Amount**
  - [ ] Manual input works
  - [ ] Preset buttons (50, 100, 200, 500) work
  - [ ] Validation: Cannot exceed balance
  - [ ] Validation: Cannot send 0 or negative
  
- [ ] **Optional Message**
  - [ ] Message field accepts text
  - [ ] Works without message
  
- [ ] **Send Gift**
  - [ ] Button disabled when invalid
  - [ ] Loading state shows
  - [ ] Success screen appears
  - [ ] Confetti animation plays
  - [ ] Balance updates
  - [ ] Transaction appears in activity
  - [ ] Returns to Home after "Done"

### Leaderboard
- [ ] **Display**
  - [ ] Top 3 podium shows correctly
  - [ ] Medals (🥇🥈🥉) display
  - [ ] Rest of list shows below podium
  - [ ] Current user highlighted
  - [ ] Rank numbers correct
  
- [ ] **Filters**
  - [ ] Weekly filter works
  - [ ] All Time filter works
  - [ ] Data updates on filter change
  
- [ ] **Empty State**
  - [ ] Shows when no data

### Profile Screen
- [ ] **Display**
  - [ ] Avatar shows first letter
  - [ ] Name and username correct
  - [ ] School badge shows
  - [ ] Edit Profile button works
  - [ ] Stats (Points, Gifts, Rank) accurate
  - [ ] Generosity level correct
  - [ ] Progress bar accurate
  - [ ] Achievements section shows
  
- [ ] **Settings**
  - [ ] Gear icon opens SettingsView
  
- [ ] **Sign Out**
  - [ ] Red button at bottom works
  - [ ] Confirmation dialog (when implemented)

### Settings
- [ ] **Account Settings**
  - [ ] Edit Profile link works
  - [ ] Notifications link opens
  - [ ] Privacy link opens
  
- [ ] **Notification Settings**
  - [ ] Push toggle works
  - [ ] Email toggle works
  - [ ] Individual notification types toggle
  
- [ ] **Privacy Settings**
  - [ ] Private profile toggle works
  - [ ] Show points toggle works
  - [ ] Show activity toggle works
  
- [ ] **Danger Zone**
  - [ ] Sign out shows confirmation
  - [ ] Delete account shows confirmation
  - [ ] Delete account warning clear
  
- [ ] **About**
  - [ ] Version displays
  - [ ] Terms link works
  - [ ] Privacy Policy link works

### Notifications
- [ ] **Display**
  - [ ] Unread badge shows count
  - [ ] Badge updates in real-time
  - [ ] Notifications list loads
  - [ ] Unread notifications highlighted
  - [ ] Correct icons per type
  - [ ] Time ago displays correctly
  
- [ ] **Interactions**
  - [ ] Tap notification marks as read
  - [ ] Mark All Read works
  - [ ] Badge clears when all read
  - [ ] Empty state shows when none

### UI/UX Testing
- [ ] **Tab Bar**
  - [ ] Icons properly sized (26pt)
  - [ ] Labels properly sized (11pt)
  - [ ] Active/inactive colors work
  - [ ] All 4 tabs functional
  
- [ ] **Navigation**
  - [ ] Back buttons work
  - [ ] No double back buttons
  - [ ] Sheet presentations work
  - [ ] Full screen covers work
  
- [ ] **Animations**
  - [ ] Splash screen animations smooth
  - [ ] Welcome screen gift drop works
  - [ ] Welcome screen rotation works
  - [ ] Gift success confetti works
  - [ ] Spring animations feel natural
  
- [ ] **Loading States**
  - [ ] Progress indicators show during loads
  - [ ] Skeleton screens (when implemented)
  - [ ] No blank screens during loading
  
- [ ] **Error Handling**
  - [ ] Network errors show messages
  - [ ] Firestore errors handled gracefully
  - [ ] Auth errors show user-friendly messages
  - [ ] Validation errors clear and helpful

### Data Integrity
- [ ] **Firestore**
  - [ ] User documents created correctly
  - [ ] Transactions recorded accurately
  - [ ] Friendships stored properly
  - [ ] Notifications created
  - [ ] Real-time listeners work
  
- [ ] **Points System**
  - [ ] Starting points: 500
  - [ ] Points deducted when sent
  - [ ] Points added when received
  - [ ] Cannot go negative
  - [ ] Total points tracked
  
- [ ] **Ranking**
  - [ ] New users start at rank 0
  - [ ] Rank updates based on gifts sent
  - [ ] Leaderboard order correct

### Device Testing (B-016)
- [ ] **iPhone Models**
  - [ ] iPhone 15 Pro Max (large)
  - [ ] iPhone 15 Pro (regular)
  - [ ] iPhone SE (small)
  
- [ ] **iPad**
  - [ ] iPad Pro layout
  - [ ] iPad Air layout
  
- [ ] **Orientations**
  - [ ] Portrait mode
  - [ ] Landscape mode (if supported)

### Performance (B-018)
- [ ] **Load Times**
  - [ ] App launches quickly
  - [ ] Screens render fast
  - [ ] Transitions smooth
  
- [ ] **Memory**
  - [ ] No memory leaks
  - [ ] Listeners cleaned up properly
  - [ ] Images optimized
  
- [ ] **Network**
  - [ ] Minimal unnecessary requests
  - [ ] Proper caching
  - [ ] Offline handling (when implemented)

### Dark Mode (B-017)
- [ ] All screens support dark mode
- [ ] Colors adapt properly
- [ ] Text remains readable
- [ ] Icons visible in both modes
- [ ] Shadows/borders work in dark mode

## Testing Commands

### Build
```bash
# Build for testing
xcodebuild -scheme Fetch -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### Run Tests (when implemented)
```bash
# Unit tests
xcodebuild test -scheme Fetch -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# UI tests
xcodebuild test -scheme FetchUITests -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Simulator Testing
```bash
# Open simulator
open -a Simulator

# Install on simulator
xcrun simctl install booted /path/to/Fetch.app
```

## Known Issues to Test For

1. **Email Verification Loop**: Ensure user doesn't get stuck in verification screen
2. **Double Back Buttons**: Fixed, but verify it stays fixed
3. **Three Dots**: Fixed, but verify no pagination indicators appear
4. **API Keys**: Ensure GoogleService-Info.plist is gitignored
5. **Points Balance**: Ensure cannot send more than available
6. **Duplicate Requests**: Ensure cannot spam friend requests

## Test Data

### Test Users
Create these test accounts for comprehensive testing:
- User 1: Standard user with friends and points
- User 2: New user with 0 activity
- User 3: Power user with max achievements
- User 4: User with expiring points

### Test Scenarios
1. **New User Journey**: Sign up → Verify → Add friend → Send gift
2. **Power User**: Multiple friends, high rank, many transactions
3. **Edge Cases**: 0 points, 0 friends, maximum values

## Automation Recommendations

### Unit Tests to Implement
- `ValidationHelper` functions
- `UserModel` computed properties
- `Transaction` display logic
- Date/time formatting utilities

### UI Tests to Implement
- Complete sign up flow
- Complete gift flow
- Navigation flow
- Search functionality

## Success Criteria

✅ All core flows work end-to-end
✅ No crashes or freezes
✅ Data persists correctly
✅ Real-time updates work
✅ UI matches Figma designs
✅ Performance is smooth (60fps)
✅ No console errors or warnings
✅ Firebase rules enforced
✅ API keys secure

## Testing Sign-Off

- [ ] Developer testing complete
- [ ] QA testing complete (if applicable)
- [ ] Beta testing complete (if applicable)
- [ ] Production deployment approved

---

**Last Updated**: 2025-10-19
**Version**: 1.0.0
**Tester**: [Your Name]


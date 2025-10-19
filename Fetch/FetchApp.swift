
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FetchApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Authentication manager (we'll create this next)
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    // User is logged in and verified - show main app
                    MainTabView()
                        .environmentObject(authManager)
                } else if !authManager.isEmailVerified {
                    // User logged in but email not verified
                    VerificationRequiredView(userEmail: authManager.userEmail ?? "")
                        .environmentObject(authManager)
                } else {
                    // User not logged in - show welcome flow
                    SplashView()
                        .environmentObject(authManager)
                }
            }
        }
    }
}
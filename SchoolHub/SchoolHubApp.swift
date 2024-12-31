//
//  SchoolHubApp.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 12.10.2024.
//

#if canImport(ActivityKit)
import ActivityKit
#endif
import Alamofire
import SwiftData
import SwiftUI
import Toasts
import WidgetKit

#if canImport(ActivityKit)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        LiveActivityManager.shared.getPushToStartToken()
        observeActivityPushTokenAndState()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print(granted, error ?? "")
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        
        let keychain = KeychainSwift()
        keychain.set(deviceTokenString, forKey: "deviceToken")
        
        let deviceTokenSent = UserDefaults.standard.bool(forKey: "deviceTokenSent")
        
        print("Device token keychain: \(keychain.get("deviceToken") ?? "nil")")
        
        if !deviceTokenSent {
            AF.request(TimetableRouter.deviceToken).responseString { response in
                switch response.result {
                case .success:
                    UserDefaults.standard.set(true, forKey: "deviceTokenSent")
                case .failure(let error):
                    print(error)
                }
            }
        }
        print("APNs device token: \(deviceTokenString)")
    }

    //    func applicationDidFinishLaunching(_ application: UIApplication) {
    //
    //    }
}

extension AppDelegate {
    func observeActivityPushTokenAndState() {
        Task {
            // 1. First, observe existing activities
            for await activity in Activity<TimetableAttributes>.activityUpdates {
                print("Observing activity with ID: \(activity.id)")
                
                print("Activity State: \(activity.activityState)")
                print("Activity Content: \(activity.content)")
                print("Activity Stale Date: \(String(describing: activity.content.staleDate))")
                    
                Task {
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") {
                            $0 + String(format: "%02x", $1)
                        }
                        print(
                            "✅ Received push token for activity \(activity.id): \(pushTokenString)"
                        )
                        AF.request(TimetableRouter.updateToken(token: pushTokenString)).responseString { response in
                            print(response.result)
                        }
                    }
                }
                    
                Task {
                    for await state in activity.activityStateUpdates {
                        switch state {
                        case .active:
                            print("📱 Activity is now active")
                        case .dismissed:
                            print("🚫 Activity was dismissed")
                        case .ended:
                            print("🏁 Activity has ended")
                        case .stale:
                            print("⚠️ Activity is stale")
                        @unknown default:
                            print("Unknown state: \(state)")
                        }
                    }
                }
            }
        }
    }
}
#endif

@main
struct SchoolHubApp: App {
    #if canImport(ActivityKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Subject.self, Quiz.self])
                .installToast(position: .bottom)
                .onAppear {
                    #if targetEnvironment(macCatalyst)
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
                    #endif
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}

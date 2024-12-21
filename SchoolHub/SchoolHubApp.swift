//
//  SchoolHubApp.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 12.10.2024.
//

import ActivityKit
import Alamofire
import SwiftData
import SwiftUI
import WidgetKit

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
        
        Task {
            do {
                let _ = try await AF.request(
                    API.shared.baseURL.appendingPathComponent("device-token"),
                    method: .post,
                    parameters: [
                        "token": deviceTokenString
                    ],
                    encoding: JSONEncoding.default
                ).serializingData().value
            } catch {
                print(error)
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
                    
                // 2. Create separate task for token updates
                Task {
                    // 3. Explicitly wait for token updates
                    for await pushToken in activity.pushTokenUpdates {
                        let pushTokenString = pushToken.reduce("") {
                            $0 + String(format: "%02x", $1)
                        }
                        print(
                            "✅ Received push token for activity \(activity.id): \(pushTokenString)"
                        )
                        
                        let keychain = KeychainSwift()
                        let deviceToken = keychain.get("deviceToken") ?? ""
                        
                        do {
                            let _ = try await AF.request(
                                API.shared.baseURL.appendingPathComponent("update-token"),
                                method: .post,
                                parameters: [
                                    "token": pushTokenString
                                ],
                                encoding: JSONEncoding.default,
                                headers: .init([.authorization(bearerToken: deviceToken)])
                            ).serializingData().value
                        } catch {
                            print(error)
                        }
                                
                        // 4. Here you should send the token to your server
                        // await sendTokenToServer(activityId: activity.id, token: token)
                    }
                }
                    
                // 5. Monitor state changes
                Task {
                    for await state in activity.activityStateUpdates {
//                            print("State updated for activity \(activity.id): \(state.rawValue)")
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

@main
struct SchoolHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Subject.self])
                .onAppear {
                    #if targetEnvironment(macCatalyst)
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
                    #endif
                    
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}

//
//  LiveActivityManager.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

#if canImport(ActivityKit)
import ActivityKit
import Alamofire
import Foundation
import os.log
import UIKit

class LiveActivityManager: NSObject, ObservableObject {
    public static let shared: LiveActivityManager = .init()
    
    private var currentActivity: Activity<TimetableAttributes>? = nil
        
    override init() {
        super.init()
    }
       
    func getPushToStartToken() {
        if #available(iOS 17.2, *) {
            Task {
                for await data in Activity<TimetableAttributes>.pushToStartTokenUpdates {
                    let token = data.map { String(format: "%02x", $0) }.joined()
                    
                    AF.request(TimetableRouter.startToken(token: token)).responseString { response in
                        print(response.result)
                        print(response.request?.allHTTPHeaderFields)
                    }
                    
                    /* do {
                         let _ = try await AF.request(
                             API.shared.baseURL.appendingPathComponent("auth/start-token"),
                             method: .post,
                             parameters: [
                                 "token": token
                             ],
                             encoding: JSONEncoding.default,
                             headers: .init([.authorization(bearerToken: deviceToken)])
                         ).serializingData().value
                     } catch {
                         print(error)
                     } */
                    
                    print("Activity PushToStart Token: \(token)")
//                        Logger.liveactivity.info("Activity PushToStart Token: \(token, privacy: .public)")
                    // send this token to your notification server
                }
            }
        }
    }
    
    /* func startLiveActivityWithToken() {
             startActivityWith(pushType: .token)
         }
    
         func startLiveActivityWithChannel(channelId: String) {
             if #available(iOS 18.0, *){
                 startActivityWith(pushType: .channel(channelId))
             }
         }
    
         func startActivityWith(pushType: PushType) {
             guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                 print("You can't start live activity.")
                 return
             }
        
             do {
                 let atttribute = LiveActivityAttributes(name:"APNsPush")
                 let initialState = LiveActivityAttributes.ContentState(emoji: "😇")
                 let staleDate = Date(timeIntervalSinceNow: 10)
                 let activity = try Activity<LiveActivityAttributes>.request(
                     attributes: atttribute,
                     content: .init(state:initialState , staleDate: staleDate),
                     pushType: pushType
                 )
                 self.currentActivity = activity
            
     //            let pushToken = activity.pushToken // Returns nil.

                 Task {
                
                     for await pushToken in activity.pushTokenUpdates {
                         let pushTokenString = pushToken.reduce("") {
                             $0 + String(format: "%02x", $1)
                         }
                         print("Activity:\(activity.id) push token: \(pushTokenString)")
                         Logger.liveactivity.info("Activity:\(activity.id,privacy: .public) push token: \(pushTokenString,privacy: .public)")
                         //send this token to your notification server
                     }
                 }
             } catch {
                 print("start Activity From App:\(error)")
                 Logger.liveactivity.info("start Activity From App:\(error,privacy: .public)")
             }
         }
        
         func updateActivity(delay:Double, alert:Bool) {
             // register background task
             var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
             backgroundTask = UIApplication.shared.beginBackgroundTask {
                 UIApplication.shared.endBackgroundTask(backgroundTask)
                 backgroundTask = UIBackgroundTaskIdentifier.invalid
             }
        
             DispatchQueue.main.asyncAfter(deadline: .now()+delay) { [weak self] in
                 UIApplication.shared.endBackgroundTask(backgroundTask)
                 self?.updateActivity(alert: alert)
            
             }

         }
    
         func updateActivity(alert:Bool) {
             Task {
                 guard let activity = currentActivity else {
                     return
                 }
            
                 var alertConfig: AlertConfiguration? = nil
                 let contentState: LiveActivityAttributes.ContentState = LiveActivityAttributes.ContentState(emoji: "🥰")
            
                 if alert {
                     alertConfig = AlertConfiguration(title: "Emoji Changed", body: "Open the app to check", sound: .default)
                 }
            
                 await activity.update(ActivityContent(state: contentState, staleDate: Date.now + 15, relevanceScore: alert ? 100 : 50), alertConfiguration: alertConfig)
             }
         }
    
         func endActivity(dismissTimeInterval: Double?) {
             Task {
                 guard let activity = currentActivity else {
                     return
                 }
                 let finalState = LiveActivityAttributes.ContentState(emoji: "✋✋")
                 let dismissalPolicy: ActivityUIDismissalPolicy
                 if let dismissTimeInterval = dismissTimeInterval {
                     if dismissTimeInterval <= 0 {
                         dismissalPolicy = .immediate
                     } else {
                         dismissalPolicy = .after(.now + dismissTimeInterval)
                     }
                 } else {
                     dismissalPolicy = .default
                 }
            
                 await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
             }
         }
    
         static func endActivity(activity:Activity<LiveActivityAttributes>, dismissTimeInterval: Double?) {
             Task {
                 let finalState = LiveActivityAttributes.ContentState(emoji: "✋✋")
                 let dismissalPolicy: ActivityUIDismissalPolicy
                 if let dismissTimeInterval = dismissTimeInterval {
                     if dismissTimeInterval <= 0 {
                         dismissalPolicy = .immediate
                     } else {
                         dismissalPolicy = .after(.now + dismissTimeInterval)
                     }
                 } else {
                     dismissalPolicy = .default
                 }
            
                 await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
             }
         } */
}

#endif

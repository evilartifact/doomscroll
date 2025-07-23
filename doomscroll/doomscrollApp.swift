//
//  doomscrollApp.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import UserNotifications

@main
struct doomscrollApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var levelManager = LevelManager.shared
    @StateObject private var taskManager = DailyTaskManager.shared
    @StateObject private var learningManager = LearningManager.shared
    @StateObject private var soundManager = SoundManager.shared
    @StateObject private var notificationDelegate = NotificationDelegate()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                HiddenActivityCollector() // Renders DeviceActivityReport to trigger data collection
            }
            .preferredColorScheme(.dark)
                .environmentObject(screenTimeManager)
                .environmentObject(notificationManager)
                .environmentObject(levelManager)
                .environmentObject(taskManager)
                .environmentObject(learningManager)
                .environmentObject(soundManager)
                .environmentObject(notificationDelegate)
                .task {
                                    // Request both notification and screen time permissions on launch
                                    await notificationManager.requestAuthorization()
                                    await screenTimeManager.requestAuthorization()
                                    
                                    // Set up your notification delegate
                                    UNUserNotificationCenter.current().delegate = notificationDelegate
                                }
        }
    }
    
    private func requestPermissions() async {
        // Request Screen Time authorization
        await screenTimeManager.requestAuthorization()
        
        // Request notification authorization
        await notificationManager.requestAuthorization()
    }
    
    private func setupNotifications() {
        // Set up notification categories
        notificationManager.setupNotificationCategories()
        
        // Schedule daily reminders if authorized
        if notificationManager.isAuthorized {
            notificationManager.scheduleDailyMoodReminders()
            notificationManager.scheduleMotivationalMessage()
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var showingUnblockDecision = false
    @Published var requestedAppName = ""
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Handle blocking notification actions
        switch response.actionIdentifier {
        case "CONTINUE_ACTION":
            // Handle "Continue" - send push notification flow
            handleContinueAction()
        case "CHANGE_MIND_ACTION":
            // Handle "Change My Mind" - show reward screen
            handleChangeMindAction()
        default:
            // Handle legacy unblock decision flow
            if let appName = userInfo["appName"] as? String,
               let action = userInfo["action"] as? String,
               action == "unblock_decision" {
                
                DispatchQueue.main.async {
                    self.requestedAppName = appName
                    self.showingUnblockDecision = true
                }
            }
        }
        
        completionHandler()
    }
    
    private func handleContinueAction() {
        // Schedule a push notification after a short delay
        let content = UNMutableNotificationContent()
        content.title = "🔔 Notification Sent"
        content.body = "Check your notifications to continue or open DoomScroll to change your mind for gems!"
        content.sound = .default
        content.categoryIdentifier = "CONTINUE_FLOW"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "continue_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func handleChangeMindAction() {
        // Award gems and show reward
        DispatchQueue.main.async {
            let rewardAmount = Int.random(in: 10...30)
            LevelManager.shared.addGems(rewardAmount, reason: "Changed mind about blocking")
            
            // You could show a reward sheet here or just send a notification
            let content = UNMutableNotificationContent()
            content.title = "💎 Gems Earned!"
            content.body = "Great choice! You earned \(rewardAmount) gems for changing your mind."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: "gems_reward", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
}

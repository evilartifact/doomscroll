//
//  AppBlockingHelpers.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import UserNotifications

// MARK: - App Blocking Helper Functions

struct AppBlockingHelpers {
    
    static func sendAppAccessNotification(appName: String) {
        // Schedule push notification that will open the app
        let content = UNMutableNotificationContent()
        content.title = "App Access Request"
        content.body = "You requested access to \(appName). Tap to decide."
        content.sound = .default
        content.categoryIdentifier = "APP_ACCESS_REQUEST"
        content.userInfo = ["appName": appName, "action": "unblock_decision"]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "app_access_request_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func awardGemsForChangingMind(context: String) {
        // Calculate reward based on daily frequency
        let dailyChanges = getDailyChangeMindCount()
        let rewardAmount: Int
        
        switch dailyChanges {
        case 0...2:
            rewardAmount = Int.random(in: 25...30)
        case 3...5:
            rewardAmount = Int.random(in: 20...25)
        case 6...8:
            rewardAmount = Int.random(in: 15...20)
        default:
            rewardAmount = Int.random(in: 10...15)
        }
        
        // Store the reward to be processed by the main app
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        let pendingRewards = userDefaults?.array(forKey: "pendingGemRewards") as? [[String: Any]] ?? []
        let newReward: [String: Any] = [
            "amount": rewardAmount,
            "reason": "Changed mind: \(context)",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        var updatedRewards = pendingRewards
        updatedRewards.append(newReward)
        userDefaults?.set(updatedRewards, forKey: "pendingGemRewards")
        
        // Increment daily change count
        incrementDailyChangeMindCount()
        
        // Send notification about reward
        let content = UNMutableNotificationContent()
        content.title = "Great Choice! 💎"
        content.body = "You earned \(rewardAmount) gems for changing your mind!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "gem_reward_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private static func getDailyChangeMindCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        return userDefaults?.integer(forKey: key) ?? 0
    }
    
    private static func incrementDailyChangeMindCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        let current = userDefaults?.integer(forKey: key) ?? 0
        userDefaults?.set(current + 1, forKey: key)
    }
} 
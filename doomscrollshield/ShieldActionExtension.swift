//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Rabin on 7/5/25.
//

import ManagedSettings
import ManagedSettingsUI
import FamilyControls
import DeviceActivity
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Handle "Continue" button - start push notification flow
            handleContinueAction(for: "App")
            completionHandler(.close)
        case .secondaryButtonPressed:
            // Handle "Change My Mind" button - show reward screen
            handleChangeMindAction(for: "App")
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            handleContinueAction(for: "App Category")
            completionHandler(.close)
        case .secondaryButtonPressed:
            handleChangeMindAction(for: "App Category")
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            handleContinueAction(for: "Website")
            completionHandler(.close)
        case .secondaryButtonPressed:
            handleChangeMindAction(for: "Website")
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    private func handleContinueAction(for appName: String) {
        // Send push notification for app access request
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
    
    private func handleChangeMindAction(for appName: String) {
        // Award gems for changing mind
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
            "reason": "Changed mind: \(appName)",
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
    
    private func getDailyChangeMindCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        return userDefaults?.integer(forKey: key) ?? 0
    }
    
    private func incrementDailyChangeMindCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        let current = userDefaults?.integer(forKey: key) ?? 0
        userDefaults?.set(current + 1, forKey: key)
    }
} 

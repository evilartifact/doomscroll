//
//  LevelManager.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import SwiftUI

@MainActor
class LevelManager: ObservableObject {
    static let shared = LevelManager()
    
    @Published var currentGems: Int = 0
    @Published var currentLevel: Int = 1
    @Published var lastSocialMediaUse: Date?
    @Published var streakStartDate: Date?
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadData()
        processPendingGemRewards()
    }
    
    // MARK: - Level System
    
    var currentLevelInfo: LevelInfo {
        return LevelInfo.getLevelInfo(for: currentLevel)
    }
    
    var nextLevelInfo: LevelInfo {
        return LevelInfo.getLevelInfo(for: currentLevel + 1)
    }
    
    var progressToNextLevel: Double {
        let currentLevelGems = LevelInfo.getXPRequiredForLevel(currentLevel)
        let nextLevelGems = LevelInfo.getXPRequiredForLevel(currentLevel + 1)
        let progress = Double(currentGems - currentLevelGems) / Double(nextLevelGems - currentLevelGems)
        return max(0, min(1, progress))
    }
    
    var gemsToNextLevel: Int {
        return LevelInfo.getXPRequiredForLevel(currentLevel + 1) - currentGems
    }
    
    // MARK: - Streak System
    
    var currentStreak: Int {
        guard let startDate = streakStartDate else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    var timeSavedToday: TimeInterval {
        // Calculate time saved based on average social media usage (3 hours per day)
        // and how long since last use
        let averageDailyUsage: TimeInterval = 3 * 3600 // 3 hours in seconds
        let timeSinceLastUse = timeSinceLastSocialMedia
        
        if timeSinceLastUse > 86400 { // More than 24 hours
            return averageDailyUsage
        } else if timeSinceLastUse > 3600 { // More than 1 hour
            return timeSinceLastUse * 0.8 // 80% of time since last use
        } else {
            return 0
        }
    }
    
    // MARK: - Gems System
    
    func addGems(_ amount: Int, reason: String) {
        currentGems += amount
        checkLevelUp()
        saveData()
        
        // Show notification for gems gain
        NotificationManager.shared.scheduleEmergencyReminder(
            message: "+\(amount) Gems: \(reason)",
            after: 1
        )
    }
    
    func deductGems(_ amount: Int, reason: String) {
        currentGems = max(0, currentGems - amount)
        saveData()
        
        // Show notification for gems loss
        NotificationManager.shared.scheduleEmergencyReminder(
            message: "-\(amount) Gems: \(reason)",
            after: 1
        )
    }
    
    func removeGems(_ amount: Int, reason: String) {
        // Remove gems without showing notification (for resets)
        currentGems = max(0, currentGems - amount)
        
        // Check if level should decrease
        let newLevel = LevelInfo.getLevelForXP(currentGems)
        if newLevel < currentLevel {
            currentLevel = newLevel
        }
        
        saveData()
    }
    
    private func checkLevelUp() {
        let newLevel = LevelInfo.getLevelForXP(currentGems)
        if newLevel > currentLevel {
            let _ = currentLevel
            currentLevel = newLevel
            
            // Celebrate level up
            NotificationManager.shared.scheduleStreakCelebration(streak: currentLevel)
        }
    }
    
    // MARK: - Social Media Tracking
    
    func recordSocialMediaUse() {
        lastSocialMediaUse = Date()
        deductGems(10, reason: "Social media use")
        // Reset streak if it's been going for more than a day
        if let startDate = streakStartDate, Date().timeIntervalSince(startDate) > 86400 {
            streakStartDate = nil
        }
        saveData()
    }
    
    func startStreak() {
        if streakStartDate == nil {
            streakStartDate = Date()
            saveData()
        }
    }
    
    var timeSinceLastSocialMedia: TimeInterval {
        guard let lastUse = lastSocialMediaUse else {
            return 0 // Never used or no record
        }
        return Date().timeIntervalSince(lastUse)
    }
    
    var timeSinceLastSocialMediaString: String {
        let interval = timeSinceLastSocialMedia
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    // MARK: - Daily Tasks
    
    func completeTask(_ task: DailyTask) {
        guard !task.isCompletedToday else { return }
        
        task.complete()
        addGems(task.gemsPerCompletion, reason: task.title)
        saveData()
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        userDefaults.set(currentGems, forKey: "currentGems")
        userDefaults.set(currentLevel, forKey: "currentLevel")
        
        if let lastUse = lastSocialMediaUse {
            userDefaults.set(lastUse, forKey: "lastSocialMediaUse")
        }
        
        if let streakStart = streakStartDate {
            userDefaults.set(streakStart, forKey: "streakStartDate")
        }
    }
    
    private func loadData() {
        currentGems = userDefaults.integer(forKey: "currentGems")
        currentLevel = max(1, userDefaults.integer(forKey: "currentLevel"))
        
        if currentLevel == 0 {
            currentLevel = 1
        }
        
        lastSocialMediaUse = userDefaults.object(forKey: "lastSocialMediaUse") as? Date
        streakStartDate = userDefaults.object(forKey: "streakStartDate") as? Date
        
        // Start streak if this is the first time
        if streakStartDate == nil && lastSocialMediaUse == nil {
            startStreak()
        }
    }
    
    // MARK: - Pending Rewards Processing
    
    private func processPendingGemRewards() {
        let userDefaults = UserDefaults(suiteName: "group.llc.doomscroll")
        guard let pendingRewards = userDefaults?.array(forKey: "pendingGemRewards") as? [[String: Any]] else {
            return
        }
        
        for reward in pendingRewards {
            if let amount = reward["amount"] as? Int,
               let reason = reward["reason"] as? String {
                addGems(amount, reason: reason)
            }
        }
        
        // Clear processed rewards
        userDefaults?.removeObject(forKey: "pendingGemRewards")
    }
}

// MARK: - Level Info

struct LevelInfo {
    let level: Int
    let title: String
    let imageName: String
    let xpRequired: Int
    let meshGradient: [Color]
    
    static func getLevelInfo(for level: Int) -> LevelInfo {
        let clampedLevel = max(1, min(9, level))
        
        let titles = [
            "Beginner", "Focused", "Determined", "Disciplined", 
            "Mindful", "Balanced", "Enlightened", "Master", "Zen"
        ]
        
        let gradients: [[Color]] = [
            [.red, .orange], // Level 1
            [.orange, .yellow], // Level 2
            [.yellow, .green], // Level 3
            [.green, .mint], // Level 4
            [.mint, .teal], // Level 5
            [.teal, .cyan], // Level 6
            [.cyan, .blue], // Level 7
            [.blue, .purple], // Level 8
            [.purple, .pink] // Level 9
        ]
        
        return LevelInfo(
            level: clampedLevel,
            title: titles[clampedLevel - 1],
            imageName: "\(clampedLevel)",
            xpRequired: getXPRequiredForLevel(clampedLevel),
            meshGradient: gradients[clampedLevel - 1]
        )
    }
    
    static func getXPRequiredForLevel(_ level: Int) -> Int {
        // Exponential XP curve: 100, 250, 500, 1000, 2000, 4000, 8000, 16000, 32000
        if level <= 1 { return 0 }
        return Int(100 * pow(2.0, Double(level - 2)))
    }
    
    static func getLevelForXP(_ xp: Int) -> Int {
        for level in 1...9 {
            if xp < getXPRequiredForLevel(level + 1) {
                return level
            }
        }
        return 9 // Max level
    }
} 

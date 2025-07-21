//
//  LearningManager.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import SwiftUI

@MainActor
class LearningManager: ObservableObject {
    static let shared = LearningManager()
    
    @Published var chapters: [LearningChapter] = []
    @Published var dailyCompletionDates: [UUID: Date] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let chaptersKey = "learningChapters"
    private let dailyCompletionKey = "dailyChapterCompletions"
    
    private init() {
        loadChapters()
        loadDailyCompletions()
    }
    
    // MARK: - Daily Completion Tracking
    
    private func canCompleteChapterToday(_ chapterId: UUID) -> Bool {
        let today = Date()
        let calendar = Calendar.current
        
        print("🔍 Checking if can complete chapter \(chapterId) today:")
        print("🔍   Today's date: \(today)")
        print("🔍   Current dailyCompletionDates count: \(dailyCompletionDates.count)")
        
        // Check if this specific chapter was completed today
        if let completionDate = dailyCompletionDates[chapterId] {
            let isSameDay = calendar.isDate(completionDate, inSameDayAs: today)
            print("🔍   Chapter \(chapterId) completion date: \(completionDate)")
            print("🔍   Is same day as today? \(isSameDay)")
            if isSameDay {
                print("🔍   ❌ Cannot complete - this chapter was already completed today")
                return false
            }
        } else {
            print("🔍   Chapter \(chapterId) has no completion date - can complete")
        }
        
        // Check if ANY chapter was completed today (daily limit)
        let hasCompletedAnyChapterToday = dailyCompletionDates.values.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: today)
        }
        
        print("🔍   Has completed any chapter today? \(hasCompletedAnyChapterToday)")
        
        if hasCompletedAnyChapterToday {
            print("🔍   ❌ Cannot complete - already completed a chapter today (daily limit)")
            return false
        }
        
        print("🔍   ✅ Can complete chapter - no completions today")
        return true
    }
    

    
    func canAccessChapter(_ chapterId: UUID) -> Bool {
        // Force reload daily completions to ensure we have latest data
        loadDailyCompletions()
        
        // First check if chapter is unlocked
        guard let chapter = chapters.first(where: { $0.id == chapterId }) else { 
            print("🔍 Chapter \(chapterId) not found")
            return false 
        }
        
        if !chapter.isUnlocked {
            print("🔍 Chapter \(chapterId) is locked")
            return false
        }
        
        // If chapter is already completed, allow access for review
        if chapter.isCompleted {
            print("🔍 Chapter \(chapterId) is completed - allowing review access")
            return true
        }
        
        // For incomplete chapters, check if we can complete a chapter today
        let today = Date()
        print("🔍 Checking daily completions for today: \(today)")
        print("🔍 Current dailyCompletionDates count: \(dailyCompletionDates.count)")
        
        for (id, date) in dailyCompletionDates {
            let isSameDay = Calendar.current.isDate(date, inSameDayAs: today)
            print("🔍   Chapter \(id): \(date) - same day as today? \(isSameDay)")
        }
        
        let hasCompletedChapterToday = dailyCompletionDates.values.contains { completionDate in
            Calendar.current.isDate(completionDate, inSameDayAs: today)
        }
        
        print("🔍 Has completed chapter today? \(hasCompletedChapterToday)")
        
        if hasCompletedChapterToday {
            print("🔍 ❌ Cannot access chapter - already completed one today")
            return false // Already completed a chapter today
        }
        
        print("🔍 ✅ Can access chapter - no completions today")
        return true
    }
    
    private func saveDailyCompletions() {
        do {
            // Convert UUID keys to String keys for proper dictionary encoding
            let stringKeyedDict = dailyCompletionDates.reduce(into: [String: TimeInterval]()) { result, pair in
                result[pair.key.uuidString] = pair.value.timeIntervalSince1970
            }
            
            let data = try JSONEncoder().encode(stringKeyedDict)
            userDefaults.set(data, forKey: dailyCompletionKey)
            
            // Force synchronize to ensure data is written to disk immediately
            let success = userDefaults.synchronize()
            print("💾 Successfully saved daily completions to UserDefaults (sync: \(success)):")
            for (chapterId, date) in dailyCompletionDates {
                print("💾   Chapter \(chapterId): \(date)")
            }
        } catch {
            print("❌ Failed to save daily completions: \(error)")
        }
    }
    
    private func loadDailyCompletions() {
        guard let data = userDefaults.data(forKey: dailyCompletionKey) else {
            print("🔍 No daily completion data found in UserDefaults")
            dailyCompletionDates = [:]
            return
        }
        
        do {
            // Decode as [String: TimeInterval] and convert back to [UUID: Date]
            let stringKeyedDict = try JSONDecoder().decode([String: TimeInterval].self, from: data)
            dailyCompletionDates = Dictionary(uniqueKeysWithValues: 
                stringKeyedDict.compactMap { (stringKey, timeInterval) in
                    guard let uuid = UUID(uuidString: stringKey) else { return nil }
                    return (uuid, Date(timeIntervalSince1970: timeInterval))
                }
            )
            print("🔍 Loaded daily completions from UserDefaults:")
            for (chapterId, date) in dailyCompletionDates {
                print("🔍   Chapter \(chapterId): completed on \(date)")
            }
        } catch {
            print("Failed to load daily completions: \(error)")
            print("🔍 Clearing corrupted daily completion data")
            // Clear the corrupted data and start fresh
            userDefaults.removeObject(forKey: dailyCompletionKey)
            dailyCompletionDates = [:]
            
            // Force synchronize after clearing corrupted data
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Chapter Management
    
    func unlockNextChapter() {
        // Find the chapter that was just completed
        guard let lastCompletedIndex = chapters.lastIndex(where: { $0.isCompleted }) else { return }
        
        // Unlock the next sequential chapter
        let nextChapterIndex = lastCompletedIndex + 1
        if nextChapterIndex < chapters.count && !chapters[nextChapterIndex].isUnlocked {
            chapters[nextChapterIndex].isUnlocked = true
            print("✅ Unlocked chapter \(nextChapterIndex + 1): \(chapters[nextChapterIndex].title)")
        }
    }
    
    func completeChapter(_ chapterId: UUID) {
        guard let index = chapters.firstIndex(where: { $0.id == chapterId }) else { 
            print("❌ Chapter \(chapterId) not found")
            return 
        }
        
        print("🎯 Attempting to complete chapter: \(chapters[index].title)")
        print("🎯   Chapter ID: \(chapterId)")
        print("🎯   Already completed: \(chapters[index].isCompleted)")
        
        // Check if we can complete chapter today (daily limit)
        if !canCompleteChapterToday(chapterId) {
            print("⚠️ Cannot complete chapter today - daily limit reached or already completed")
            return
        }
        
        // Only update if not already completed to avoid unnecessary notifications
        if !chapters[index].isCompleted {
            chapters[index].isCompleted = true
            
            // Track daily completion
            dailyCompletionDates[chapterId] = Date()
            print("💎 Adding daily completion for chapter: \(chapters[index].title) on \(Date())")
            
            // Award gems for chapter completion
            let gemsAwarded = chapters[index].gemsReward
            LevelManager.shared.addGems(gemsAwarded, reason: "Chapter completed: \(chapters[index].title)")
            print("💎 Awarded \(gemsAwarded) gems for completing: \(chapters[index].title)")
            
            // Unlock next chapter immediately
            unlockNextChapter()
            
            // Save changes synchronously to ensure persistence
            saveChapters()
            saveDailyCompletions()
            
            print("✅ Chapter completed: \(chapters[index].title)")
            print("💾 Daily completion data saved synchronously")
        } else {
            print("⚠️ Chapter \(chapters[index].title) was already completed")
        }
    }
    
    func isChapterUnlocked(_ chapterId: UUID) -> Bool {
        guard let chapter = chapters.first(where: { $0.id == chapterId }) else { return false }
        return chapter.isUnlocked
    }
    
    // MARK: - Debug and Reset Methods
    
    func resetProgress() {
        userDefaults.removeObject(forKey: chaptersKey)
        setupInitialChapters()
        print("✅ Chapter progress reset - only first chapter unlocked")
        print("📊 Total chapters loaded: \(chapters.count)")
    }
    
    func resetDailyCompletions() {
        dailyCompletionDates.removeAll()
        userDefaults.removeObject(forKey: dailyCompletionKey)
        print("🔄 Daily completion tracking reset")
    }
    
    func debugChapterStatus() {
        print("🔍 Chapter Status Debug:")
        print("📊 Total chapters: \(chapters.count)")
        for (index, chapter) in chapters.enumerated() {
            print("Chapter \(index + 1): \(chapter.title)")
            print("  - Is Unlocked: \(chapter.isUnlocked)")
            print("  - Is Completed: \(chapter.isCompleted)")
            print("  - Gems Reward: \(chapter.gemsReward)")
        }
    }
    
    func forceReloadChapters() {
        print("🔄 Force reloading chapters...")
        setupInitialChapters()
        print("✅ Chapters reloaded: \(chapters.count) total")
        debugChapterStatus()
    }
    
    // MARK: - Data Persistence
    
    private func saveChapters() {
        do {
            let data = try JSONEncoder().encode(chapters)
            userDefaults.set(data, forKey: chaptersKey)
        } catch {
            print("Failed to save chapters: \(error)")
        }
    }
    
    private func loadChapters() {
        if let data = userDefaults.data(forKey: chaptersKey) {
            do {
                chapters = try JSONDecoder().decode([LearningChapter].self, from: data)
                print("✅ Loaded \(chapters.count) chapters from storage")
                
                // If we loaded 0 chapters, the stored data is invalid - reset
                if chapters.isEmpty {
                    print("⚠️ Loaded empty chapters array, resetting to initial state")
                    setupInitialChapters()
                } else {
                    debugChapterStatus()
                }
            } catch {
                print("Failed to load chapters: \(error)")
                setupInitialChapters()
            }
        } else {
            print("📱 No saved chapters found, setting up initial chapters")
            setupInitialChapters()
        }
    }
    
    private func setupInitialChapters() {
        // Load chapters directly from JSON - synchronous approach
        guard let url = Bundle.main.url(forResource: "chapters", withExtension: "json") else {
            print("❌ Could not find chapters.json file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let chaptersResponse = try decoder.decode(ChaptersResponse.self, from: data)
            
            chapters = chaptersResponse.chapters.map { $0.toLearningChapter() }
            print("✅ Loaded \(chapters.count) chapters directly from JSON")
            
            // Unlock first chapter only
            if !chapters.isEmpty {
                chapters[0].isUnlocked = true
                
                // Ensure all other chapters are locked
                for i in 1..<chapters.count {
                    chapters[i].isUnlocked = false
                    chapters[i].isCompleted = false
                }
            }
            
            saveChapters()
            print("✅ Initial chapters setup complete")
            debugChapterStatus()
            
        } catch {
            print("❌ Error loading chapters in LearningManager: \(error)")
        }
    }
    
    // MARK: - Progress Tracking
    
    var totalProgress: Double {
        guard !chapters.isEmpty else { return 0 }
        return Double(completedChaptersCount) / Double(chapters.count)
    }
    
    var completedChaptersCount: Int {
        chapters.lazy.filter { $0.isCompleted }.count
    }
    
    var totalChaptersCount: Int {
        chapters.count
    }
    
    var totalGemsEarned: Int {
        chapters.filter { $0.isCompleted }.reduce(0) { $0 + $1.gemsReward }
    }
    
    var unlockedChaptersCount: Int {
        chapters.filter { $0.isUnlocked }.count
    }
} 
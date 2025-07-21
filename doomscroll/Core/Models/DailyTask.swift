//
//  DailyTask.swift -> HabitTracker.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import SwiftUI

// MARK: - Habit Model
class Habit: ObservableObject, Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let category: HabitCategory
    let frequency: HabitFrequency
    let unit: HabitUnit
    let targetAmount: Int
    let gemsPerCompletion: Int
    
    @Published var totalProgress: Int = 0 // Total accumulated (e.g., 150 minutes read)
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var completedDates: [Date] = []
    @Published var lastCompletedDate: Date?
    @Published var isActiveToday: Bool = true
    
    init(title: String, emoji: String, category: HabitCategory, frequency: HabitFrequency, unit: HabitUnit, targetAmount: Int, gemsPerCompletion: Int) {
        self.title = title
        self.emoji = emoji
        self.category = category
        self.frequency = frequency
        self.unit = unit
        self.targetAmount = targetAmount
        self.gemsPerCompletion = gemsPerCompletion
    }
    
    // Get milestones for this habit
    var milestones: [HabitMilestone] {
        return HabitMilestone.getMilestones(for: self)
    }
    
    // Get next uncompleted milestone
    var nextMilestone: HabitMilestone? {
        return milestones.first { $0.targetAmount > totalProgress }
    }
    
    // Get completed milestones
    var completedMilestones: [HabitMilestone] {
        return milestones.filter { $0.targetAmount <= totalProgress }
    }
    
    // Progress to next milestone (0.0 to 1.0)
    var progressToNextMilestone: Double {
        guard let next = nextMilestone else { return 1.0 }
        let previous = milestones.filter { $0.targetAmount <= totalProgress }.last?.targetAmount ?? 0
        let range = next.targetAmount - previous
        let current = totalProgress - previous
        return range > 0 ? Double(current) / Double(range) : 0.0
    }
    
    // Check if habit should be active today
    func shouldBeActiveToday() -> Bool {
        let today = Date()
        let calendar = Calendar.current
        
        switch frequency {
        case .daily:
            return true
        case .weekdays:
            let weekday = calendar.component(.weekday, from: today)
            return weekday >= 2 && weekday <= 6 // Monday to Friday
        case .weekends:
            let weekday = calendar.component(.weekday, from: today)
            return weekday == 1 || weekday == 7 // Saturday or Sunday
        case .weekly:
            // Check if it's been a week since last completion
            guard let lastDate = lastCompletedDate else { return true }
            return calendar.dateInterval(of: .weekOfYear, for: lastDate) != calendar.dateInterval(of: .weekOfYear, for: today)
        case .custom(let daysInterval):
            guard let lastDate = lastCompletedDate else { return true }
            let daysSince = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            return daysSince >= daysInterval
        }
    }
    
    // Check if completed today
    var isCompletedToday: Bool {
        guard let lastDate = lastCompletedDate else { return false }
        return Calendar.current.isDate(lastDate, inSameDayAs: Date())
    }
    
    // Complete the habit
    func complete(amount: Int = 1) {
        let today = Date()
        let calendar = Calendar.current
        
        // Add to total progress
        totalProgress += (amount * targetAmount)
        
        // Update completion tracking
        if !isCompletedToday {
            completedDates.append(today)
            lastCompletedDate = today
            
            // Update streak
            if let previousDate = completedDates.dropLast().last {
                let daysBetween = calendar.dateComponents([.day], from: previousDate, to: today).day ?? 0
                if daysBetween == 1 || (frequency == .weekdays && isValidWeekdayStreak(from: previousDate, to: today)) {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            bestStreak = max(bestStreak, currentStreak)
        }
    }
    
    private func isValidWeekdayStreak(from: Date, to: Date) -> Bool {
        let calendar = Calendar.current
        let fromWeekday = calendar.component(.weekday, from: from)
        let toWeekday = calendar.component(.weekday, from: to)
        
        // Valid weekday streak patterns
        if fromWeekday == 6 && toWeekday == 2 { // Friday to Monday
            return calendar.dateComponents([.day], from: from, to: to).day == 3
        }
        return calendar.dateComponents([.day], from: from, to: to).day == 1
    }
}

// MARK: - Habit Enums
enum HabitCategory: String, CaseIterable {
    case health = "health"
    case mind = "mind"
    case creativity = "creativity"
    case social = "social"
    case learning = "learning"
    case productivity = "productivity"
    
    var color: Color {
        switch self {
        case .health: return .green
        case .mind: return .blue
        case .creativity: return .purple
        case .social: return .orange
        case .learning: return .cyan
        case .productivity: return .indigo
        }
    }
    
    var name: String {
        switch self {
        case .health: return "Health"
        case .mind: return "Mind"
        case .creativity: return "Creativity"
        case .social: return "Social"
        case .learning: return "Learning"
        case .productivity: return "Productivity"
        }
    }
}

enum HabitFrequency: Equatable {
    case daily
    case weekdays // Monday to Friday
    case weekends // Saturday and Sunday
    case weekly
    case custom(days: Int) // Every X days
    
    var description: String {
        switch self {
        case .daily: return "Daily"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .weekly: return "Weekly"
        case .custom(let days): return "Every \(days) days"
        }
    }
}

enum HabitUnit: String, CaseIterable {
    case minutes = "minutes"
    case pages = "pages"
    case exercises = "exercises"
    case times = "times"
    case hours = "hours"
    case words = "words"
    
    var singular: String {
        switch self {
        case .minutes: return "minute"
        case .pages: return "page"
        case .exercises: return "exercise"
        case .times: return "time"
        case .hours: return "hour"
        case .words: return "word"
        }
    }
}

// MARK: - Habit Milestones
struct HabitMilestone {
    let id = UUID()
    let targetAmount: Int
    let title: String
    let description: String
    let gemReward: Int
    let unit: HabitUnit
    
    static func getMilestones(for habit: Habit) -> [HabitMilestone] {
        switch habit.unit {
        case .minutes:
            return [
                HabitMilestone(targetAmount: 60, title: "First Hour", description: "Completed 1 hour total", gemReward: 50, unit: .minutes),
                HabitMilestone(targetAmount: 180, title: "Getting Started", description: "Completed 3 hours total", gemReward: 100, unit: .minutes),
                HabitMilestone(targetAmount: 300, title: "Building Momentum", description: "Completed 5 hours total", gemReward: 150, unit: .minutes),
                HabitMilestone(targetAmount: 600, title: "Dedicated", description: "Completed 10 hours total", gemReward: 250, unit: .minutes),
                HabitMilestone(targetAmount: 1200, title: "Committed", description: "Completed 20 hours total", gemReward: 500, unit: .minutes),
                HabitMilestone(targetAmount: 3000, title: "Expert", description: "Completed 50 hours total", gemReward: 1000, unit: .minutes)
            ]
        case .pages:
            return [
                HabitMilestone(targetAmount: 50, title: "First Chapter", description: "Read 50 pages total", gemReward: 50, unit: .pages),
                HabitMilestone(targetAmount: 150, title: "Getting into it", description: "Read 150 pages total", gemReward: 100, unit: .pages),
                HabitMilestone(targetAmount: 300, title: "Bookworm", description: "Read 300 pages total", gemReward: 200, unit: .pages),
                HabitMilestone(targetAmount: 600, title: "Avid Reader", description: "Read 600 pages total", gemReward: 400, unit: .pages),
                HabitMilestone(targetAmount: 1000, title: "Scholar", description: "Read 1000 pages total", gemReward: 750, unit: .pages),
                HabitMilestone(targetAmount: 2000, title: "Literary Master", description: "Read 2000 pages total", gemReward: 1500, unit: .pages)
            ]
        case .exercises:
            return [
                HabitMilestone(targetAmount: 10, title: "Getting Started", description: "Completed 10 exercises", gemReward: 30, unit: .exercises),
                HabitMilestone(targetAmount: 25, title: "Building Strength", description: "Completed 25 exercises", gemReward: 75, unit: .exercises),
                HabitMilestone(targetAmount: 50, title: "Strong Foundation", description: "Completed 50 exercises", gemReward: 150, unit: .exercises),
                HabitMilestone(targetAmount: 100, title: "Fitness Enthusiast", description: "Completed 100 exercises", gemReward: 300, unit: .exercises),
                HabitMilestone(targetAmount: 250, title: "Athletic", description: "Completed 250 exercises", gemReward: 750, unit: .exercises),
                HabitMilestone(targetAmount: 500, title: "Fitness Master", description: "Completed 500 exercises", gemReward: 1500, unit: .exercises)
            ]
        case .times:
            return [
                HabitMilestone(targetAmount: 7, title: "First Week", description: "Completed 7 times", gemReward: 50, unit: .times),
                HabitMilestone(targetAmount: 21, title: "Habit Forming", description: "Completed 21 times", gemReward: 150, unit: .times),
                HabitMilestone(targetAmount: 50, title: "Consistent", description: "Completed 50 times", gemReward: 300, unit: .times),
                HabitMilestone(targetAmount: 100, title: "Dedicated", description: "Completed 100 times", gemReward: 600, unit: .times),
                HabitMilestone(targetAmount: 200, title: "Mastery", description: "Completed 200 times", gemReward: 1200, unit: .times),
                HabitMilestone(targetAmount: 365, title: "Life Changer", description: "Completed 365 times", gemReward: 2500, unit: .times)
            ]
        case .hours:
            return [
                HabitMilestone(targetAmount: 5, title: "Getting Started", description: "Completed 5 hours total", gemReward: 100, unit: .hours),
                HabitMilestone(targetAmount: 20, title: "Committed", description: "Completed 20 hours total", gemReward: 300, unit: .hours),
                HabitMilestone(targetAmount: 50, title: "Dedicated", description: "Completed 50 hours total", gemReward: 750, unit: .hours),
                HabitMilestone(targetAmount: 100, title: "Expert Level", description: "Completed 100 hours total", gemReward: 1500, unit: .hours),
                HabitMilestone(targetAmount: 250, title: "Master", description: "Completed 250 hours total", gemReward: 3000, unit: .hours),
                HabitMilestone(targetAmount: 500, title: "Life Transformer", description: "Completed 500 hours total", gemReward: 6000, unit: .hours)
            ]
        case .words:
            return [
                HabitMilestone(targetAmount: 1000, title: "First Thousand", description: "Written 1,000 words", gemReward: 50, unit: .words),
                HabitMilestone(targetAmount: 5000, title: "Getting Fluent", description: "Written 5,000 words", gemReward: 200, unit: .words),
                HabitMilestone(targetAmount: 10000, title: "Prolific", description: "Written 10,000 words", gemReward: 400, unit: .words),
                HabitMilestone(targetAmount: 25000, title: "Author", description: "Written 25,000 words", gemReward: 1000, unit: .words),
                HabitMilestone(targetAmount: 50000, title: "Novelist", description: "Written 50,000 words", gemReward: 2000, unit: .words),
                HabitMilestone(targetAmount: 100000, title: "Writing Master", description: "Written 100,000 words", gemReward: 5000, unit: .words)
            ]
        }
    }
}

// MARK: - Habit Templates
struct HabitTemplate {
    let title: String
    let emoji: String
    let category: HabitCategory
    let frequency: HabitFrequency
    let unit: HabitUnit
    let targetAmount: Int
    let gemsPerCompletion: Int
    let description: String
    let minLevel: Int
}

// MARK: - Master Habit Collection
struct MasterHabitCollection {
    static let allHabits: [HabitTemplate] = [
        // HEALTH HABITS
        HabitTemplate(title: "Daily Walk", emoji: "🚶‍♂️", category: .health, frequency: .daily, unit: .minutes, targetAmount: 15, gemsPerCompletion: 20, description: "Walk for 15 minutes to stay active", minLevel: 1),
        HabitTemplate(title: "Morning Exercise", emoji: "💪", category: .health, frequency: .daily, unit: .exercises, targetAmount: 1, gemsPerCompletion: 25, description: "Do basic exercises to build strength", minLevel: 3),
        HabitTemplate(title: "Drink Water", emoji: "💧", category: .health, frequency: .daily, unit: .times, targetAmount: 1, gemsPerCompletion: 10, description: "Stay hydrated throughout the day", minLevel: 1),
        HabitTemplate(title: "Workout Session", emoji: "🏋️‍♀️", category: .health, frequency: .custom(days: 2), unit: .minutes, targetAmount: 30, gemsPerCompletion: 50, description: "Intense workout", minLevel: 8),
        HabitTemplate(title: "Yoga Practice", emoji: "🧘", category: .health, frequency: .weekdays, unit: .minutes, targetAmount: 20, gemsPerCompletion: 30, description: "Mindful movement and flexibility", minLevel: 5),
        
        // MIND HABITS  
        HabitTemplate(title: "Daily Meditation", emoji: "🧠", category: .mind, frequency: .daily, unit: .minutes, targetAmount: 10, gemsPerCompletion: 25, description: "Quiet your mind and find peace", minLevel: 2),
        HabitTemplate(title: "Gratitude Journal", emoji: "🙏", category: .mind, frequency: .daily, unit: .times, targetAmount: 1, gemsPerCompletion: 15, description: "Write 3 things you're grateful for", minLevel: 1),
        HabitTemplate(title: "Deep Reflection", emoji: "🤔", category: .mind, frequency: .weekly, unit: .minutes, targetAmount: 30, gemsPerCompletion: 40, description: "Weekly self-reflection session", minLevel: 6),
        HabitTemplate(title: "Mindful Breathing", emoji: "🫁", category: .mind, frequency: .daily, unit: .minutes, targetAmount: 5, gemsPerCompletion: 15, description: "Practice conscious breathing", minLevel: 1),
        
        // CREATIVITY HABITS
        HabitTemplate(title: "Creative Writing", emoji: "✍️", category: .creativity, frequency: .daily, unit: .words, targetAmount: 250, gemsPerCompletion: 30, description: "Express yourself through writing", minLevel: 4),
        HabitTemplate(title: "Draw or Sketch", emoji: "🎨", category: .creativity, frequency: .weekdays, unit: .minutes, targetAmount: 20, gemsPerCompletion: 25, description: "Practice visual art skills", minLevel: 3),
        HabitTemplate(title: "Music Practice", emoji: "🎵", category: .creativity, frequency: .custom(days: 2), unit: .minutes, targetAmount: 30, gemsPerCompletion: 35, description: "Learn and practice music", minLevel: 7),
        HabitTemplate(title: "Photography", emoji: "📸", category: .creativity, frequency: .weekends, unit: .times, targetAmount: 1, gemsPerCompletion: 20, description: "Capture beautiful moments", minLevel: 5),
        
        // SOCIAL HABITS
        HabitTemplate(title: "Connect with Friends", emoji: "💬", category: .social, frequency: .custom(days: 3), unit: .times, targetAmount: 1, gemsPerCompletion: 25, description: "Meaningful conversation with friends", minLevel: 2),
        HabitTemplate(title: "Family Time", emoji: "👨‍👩‍👧‍👦", category: .social, frequency: .daily, unit: .minutes, targetAmount: 30, gemsPerCompletion: 20, description: "Quality time with family", minLevel: 1),
        HabitTemplate(title: "Acts of Kindness", emoji: "😊", category: .social, frequency: .weekdays, unit: .times, targetAmount: 1, gemsPerCompletion: 30, description: "Help others and spread positivity", minLevel: 4),
        HabitTemplate(title: "Community Involvement", emoji: "🤝", category: .social, frequency: .weekly, unit: .hours, targetAmount: 2, gemsPerCompletion: 75, description: "Volunteer or help your community", minLevel: 10),
        
        // LEARNING HABITS
        HabitTemplate(title: "Daily Reading", emoji: "📚", category: .learning, frequency: .daily, unit: .pages, targetAmount: 10, gemsPerCompletion: 25, description: "Expand your knowledge through books", minLevel: 1),
        HabitTemplate(title: "Language Learning", emoji: "🗣️", category: .learning, frequency: .weekdays, unit: .minutes, targetAmount: 15, gemsPerCompletion: 30, description: "Learn a new language", minLevel: 6),
        HabitTemplate(title: "Online Course", emoji: "💻", category: .learning, frequency: .custom(days: 2), unit: .minutes, targetAmount: 45, gemsPerCompletion: 50, description: "Complete course modules", minLevel: 8),
        HabitTemplate(title: "Skill Practice", emoji: "🛠️", category: .learning, frequency: .weekdays, unit: .minutes, targetAmount: 25, gemsPerCompletion: 35, description: "Practice a specific skill", minLevel: 5),
        HabitTemplate(title: "Educational Podcast", emoji: "🎧", category: .learning, frequency: .custom(days: 3), unit: .minutes, targetAmount: 30, gemsPerCompletion: 25, description: "Learn while listening", minLevel: 3),
        
        // PRODUCTIVITY HABITS
        HabitTemplate(title: "Daily Planning", emoji: "📅", category: .productivity, frequency: .daily, unit: .minutes, targetAmount: 10, gemsPerCompletion: 15, description: "Plan your day for success", minLevel: 2),
        HabitTemplate(title: "Focused Work", emoji: "⏰", category: .productivity, frequency: .weekdays, unit: .minutes, targetAmount: 50, gemsPerCompletion: 40, description: "Deep focus work session", minLevel: 7),
        HabitTemplate(title: "Organize Space", emoji: "🗂️", category: .productivity, frequency: .weekly, unit: .times, targetAmount: 1, gemsPerCompletion: 30, description: "Keep your environment clean", minLevel: 3),
        HabitTemplate(title: "Goal Review", emoji: "🎯", category: .productivity, frequency: .weekly, unit: .minutes, targetAmount: 20, gemsPerCompletion: 35, description: "Review and adjust your goals", minLevel: 9),
        HabitTemplate(title: "Time Tracking", emoji: "⌚", category: .productivity, frequency: .weekdays, unit: .times, targetAmount: 1, gemsPerCompletion: 20, description: "Be conscious of how you spend time", minLevel: 12)
    ]
    
    static func getHabitsForLevel(_ level: Int) -> [HabitTemplate] {
        return allHabits.filter { $0.minLevel <= level }
    }
    
    static func getStarterHabits() -> [HabitTemplate] {
        // Select 4-6 foundational habits for new users
        return [
            allHabits.first { $0.title == "Daily Walk" }!,
            allHabits.first { $0.title == "Daily Reading" }!,
            allHabits.first { $0.title == "Gratitude Journal" }!,
            allHabits.first { $0.title == "Mindful Breathing" }!,
            allHabits.first { $0.title == "Family Time" }!
        ]
    }
}

// MARK: - Habit Manager
@MainActor
class HabitManager: ObservableObject {
    static let shared = HabitManager()
    
    @Published var userHabits: [Habit] = []
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadHabits()
        if userHabits.isEmpty {
            initializeStarterHabits()
        }
        updateTodayStatus()
    }
    
    private func initializeStarterHabits() {
        let starterTemplates = MasterHabitCollection.getStarterHabits()
        userHabits = starterTemplates.map { template in
            Habit(
                title: template.title,
                emoji: template.emoji,
                category: template.category,
                frequency: template.frequency,
                unit: template.unit,
                targetAmount: template.targetAmount,
                gemsPerCompletion: template.gemsPerCompletion
            )
        }
        saveHabits()
    }
    
    func updateTodayStatus() {
        for habit in userHabits {
            habit.isActiveToday = habit.shouldBeActiveToday()
        }
    }
    
    var todaysHabits: [Habit] {
        return userHabits.filter { $0.isActiveToday }
    }
    
    func completeHabit(_ habit: Habit) {
        guard !habit.isCompletedToday else { return }
        
        habit.complete()
        LevelManager.shared.addGems(habit.gemsPerCompletion, reason: "Completed: \(habit.title)")
        
        // Check for milestone completion
        if let milestone = habit.completedMilestones.last,
           milestone.targetAmount == habit.totalProgress - habit.targetAmount {
            LevelManager.shared.addGems(milestone.gemReward, reason: "Milestone: \(milestone.title)")
        }
        
        // Force UI update
        objectWillChange.send()
        
        saveHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        userHabits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func saveData() {
        saveHabits()
    }
    
    private func saveHabits() {
        let habitData = userHabits.map { habit in
            [
                "id": habit.id.uuidString,
                "title": habit.title,
                "emoji": habit.emoji,
                "category": habit.category.rawValue,
                "frequency": encodeFrequency(habit.frequency),
                "unit": habit.unit.rawValue,
                "targetAmount": habit.targetAmount,
                "gemsPerCompletion": habit.gemsPerCompletion,
                "totalProgress": habit.totalProgress,
                "currentStreak": habit.currentStreak,
                "bestStreak": habit.bestStreak,
                "completedDates": habit.completedDates.map { $0.timeIntervalSince1970 },
                "lastCompletedDate": habit.lastCompletedDate?.timeIntervalSince1970 ?? 0
            ]
        }
        
        userDefaults.set(habitData, forKey: "userHabits")
    }
    
    private func loadHabits() {
        guard let habitData = userDefaults.array(forKey: "userHabits") as? [[String: Any]] else {
            return
        }
        
        userHabits = habitData.compactMap { data in
                    guard let idString = data["id"] as? String,
              let _ = UUID(uuidString: idString),
                  let title = data["title"] as? String,
                  let emoji = data["emoji"] as? String,
                  let categoryString = data["category"] as? String,
                  let category = HabitCategory(rawValue: categoryString),
                  let frequencyData = data["frequency"] as? [String: Any],
                  let frequency = decodeFrequency(frequencyData),
                  let unitString = data["unit"] as? String,
                  let unit = HabitUnit(rawValue: unitString),
                  let targetAmount = data["targetAmount"] as? Int,
                  let gemsPerCompletion = data["gemsPerCompletion"] as? Int else {
                return nil
            }
            
            let habit = Habit(
                title: title,
                emoji: emoji,
                category: category,
                frequency: frequency,
                unit: unit,
                targetAmount: targetAmount,
                gemsPerCompletion: gemsPerCompletion
            )
            
            // Restore progress data
            habit.totalProgress = data["totalProgress"] as? Int ?? 0
            habit.currentStreak = data["currentStreak"] as? Int ?? 0
            habit.bestStreak = data["bestStreak"] as? Int ?? 0
            
            if let completedTimestamps = data["completedDates"] as? [TimeInterval] {
                habit.completedDates = completedTimestamps.map { Date(timeIntervalSince1970: $0) }
            }
            
            if let lastCompletedTimestamp = data["lastCompletedDate"] as? TimeInterval, lastCompletedTimestamp > 0 {
                habit.lastCompletedDate = Date(timeIntervalSince1970: lastCompletedTimestamp)
            }
            
            return habit
        }
    }
    
    private func encodeFrequency(_ frequency: HabitFrequency) -> [String: Any] {
        switch frequency {
        case .daily:
            return ["type": "daily"]
        case .weekdays:
            return ["type": "weekdays"]
        case .weekends:
            return ["type": "weekends"]
        case .weekly:
            return ["type": "weekly"]
        case .custom(let days):
            return ["type": "custom", "days": days]
        }
    }
    
    private func decodeFrequency(_ data: [String: Any]) -> HabitFrequency? {
        guard let type = data["type"] as? String else { return nil }
        
        switch type {
        case "daily": return .daily
        case "weekdays": return .weekdays
        case "weekends": return .weekends
        case "weekly": return .weekly
        case "custom":
            guard let days = data["days"] as? Int else { return nil }
            return .custom(days: days)
        default: return nil
        }
    }
}

// MARK: - Legacy Compatibility
typealias DailyTask = Habit
typealias DailyTaskManager = HabitManager 

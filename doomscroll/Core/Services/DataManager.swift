//
//  DataManager.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var moodEntries: [MoodEntry] = []
    @Published var urgeEntries: [UrgeEntry] = []
    @Published var blockingRules: [AppBlockingRule] = []
    @Published var journalEntries: [JournalEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for UserDefaults
    private let moodEntriesKey = "mood_entries"
    private let urgeEntriesKey = "urge_entries"
    private let blockingRulesKey = "blocking_rules"
    private let journalEntriesKey = "journal_entries"
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadMoodEntries()
        loadUrgeEntries()
        loadBlockingRules()
        loadJournalEntries()
    }
    
    private func loadMoodEntries() {
        if let data = userDefaults.data(forKey: moodEntriesKey),
           let entries = try? decoder.decode([MoodEntry].self, from: data) {
            moodEntries = entries
        } else {
            moodEntries = []
        }
    }
    
    private func loadUrgeEntries() {
        if let data = userDefaults.data(forKey: urgeEntriesKey),
           let entries = try? decoder.decode([UrgeEntry].self, from: data) {
            urgeEntries = entries
        } else {
            urgeEntries = []
        }
    }
    
    private func loadBlockingRules() {
        if let data = userDefaults.data(forKey: blockingRulesKey),
           let rules = try? decoder.decode([AppBlockingRule].self, from: data) {
            blockingRules = rules
        } else {
            blockingRules = []
        }
    }
    
    private func loadJournalEntries() {
        if let data = userDefaults.data(forKey: journalEntriesKey),
           let entries = try? decoder.decode([JournalEntry].self, from: data) {
            journalEntries = entries
        } else {
            journalEntries = []
        }
    }
    
    // MARK: - Data Saving
    private func saveMoodEntries() {
        if let data = try? encoder.encode(moodEntries) {
            userDefaults.set(data, forKey: moodEntriesKey)
        }
    }
    
    private func saveUrgeEntries() {
        if let data = try? encoder.encode(urgeEntries) {
            userDefaults.set(data, forKey: urgeEntriesKey)
        }
    }
    
    private func saveBlockingRules() {
        if let data = try? encoder.encode(blockingRules) {
            userDefaults.set(data, forKey: blockingRulesKey)
        }
    }
    
    private func saveJournalEntries() {
        if let data = try? encoder.encode(journalEntries) {
            userDefaults.set(data, forKey: journalEntriesKey)
        }
    }
    
    // MARK: - Mood Entry Methods
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        moodEntries.sort { $0.date > $1.date }
        saveMoodEntries()
    }
    
    func deleteMoodEntry(_ entry: MoodEntry) {
        moodEntries.removeAll { $0.id == entry.id }
        saveMoodEntries()
    }
    
    func getMoodEntries(for date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        return moodEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getAverageMood(for period: TimePeriod) -> Double {
        let entries = getMoodEntries(for: period)
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.mood.rawValue }
        return Double(total) / Double(entries.count)
    }
    
    // MARK: - Urge Entry Methods
    func addUrgeEntry(_ entry: UrgeEntry) {
        urgeEntries.append(entry)
        urgeEntries.sort { $0.date > $1.date }
        saveUrgeEntries()
    }
    
    func deleteUrgeEntry(_ entry: UrgeEntry) {
        urgeEntries.removeAll { $0.id == entry.id }
        saveUrgeEntries()
    }
    
    func getUrgeEntries(for period: TimePeriod) -> [UrgeEntry] {
        let dateRange = period.dateRange
        return urgeEntries.filter { entry in
            entry.date >= dateRange.start && entry.date <= dateRange.end
        }
    }
    
    func getUrgeResistanceRate(for period: TimePeriod) -> Double {
        let entries = getUrgeEntries(for: period)
        guard !entries.isEmpty else { return 0 }
        let positiveOutcomes = entries.filter { $0.outcome.isPositive }.count
        return Double(positiveOutcomes) / Double(entries.count)
    }
    
    // MARK: - Blocking Rule Methods
    func addBlockingRule(_ rule: AppBlockingRule) {
        blockingRules.append(rule)
        saveBlockingRules()
    }
    
    func updateBlockingRule(_ rule: AppBlockingRule) {
        if let index = blockingRules.firstIndex(where: { $0.id == rule.id }) {
            var updatedRule = rule
            updatedRule.lastModified = Date()
            blockingRules[index] = updatedRule
            saveBlockingRules()
        }
    }
    
    func deleteBlockingRule(_ rule: AppBlockingRule) {
        blockingRules.removeAll { $0.id == rule.id }
        saveBlockingRules()
    }
    
    func getActiveBlockingRules() -> [AppBlockingRule] {
        return blockingRules.filter { $0.isEnabled }
    }
    
    // MARK: - Journal Entry Methods
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        journalEntries.sort { $0.date > $1.date }
        saveJournalEntries()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            journalEntries.sort { $0.date > $1.date }
            saveJournalEntries()
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournalEntries()
    }
    
    func getJournalEntries(for date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return journalEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getJournalEntries(for period: TimePeriod) -> [JournalEntry] {
        let dateRange = period.dateRange
        return journalEntries.filter { entry in
            entry.date >= dateRange.start && entry.date <= dateRange.end
        }
    }
    
    // MARK: - Helper Methods
    private func getMoodEntries(for period: TimePeriod) -> [MoodEntry] {
        let dateRange = period.dateRange
        return moodEntries.filter { entry in
            entry.date >= dateRange.start && entry.date <= dateRange.end
        }
    }
}

// MARK: - Time Period Helper
enum TimePeriod {
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case custom(start: Date, end: Date)
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return (start, end)
            
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            let start = calendar.startOfDay(for: yesterday)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return (start, end)
            
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (start, end)
            
        case .lastWeek:
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            let start = calendar.dateInterval(of: .weekOfYear, for: lastWeek)?.start ?? now
            let end = calendar.dateInterval(of: .weekOfYear, for: lastWeek)?.end ?? now
            return (start, end)
            
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (start, end)
            
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let start = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
            let end = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
            return (start, end)
            
        case .custom(let start, let end):
            return (start, end)
        }
    }
} 
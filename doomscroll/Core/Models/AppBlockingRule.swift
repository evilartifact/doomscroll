//
//  AppBlockingRule.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation

struct AppBlockingRule: Identifiable, Codable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var blockedApps: [String] // Bundle identifiers
    var schedule: BlockingSchedule
    var difficultyLevel: DifficultyLevel
    var createdDate: Date
    var lastModified: Date
    
    init(name: String, isEnabled: Bool, blockedApps: [String], schedule: BlockingSchedule, difficultyLevel: DifficultyLevel, createdDate: Date, lastModified: Date) {
        self.id = UUID()
        self.name = name
        self.isEnabled = isEnabled
        self.blockedApps = blockedApps
        self.schedule = schedule
        self.difficultyLevel = difficultyLevel
        self.createdDate = createdDate
        self.lastModified = lastModified
    }
    
    struct TimeOfDay: Codable, Hashable {
        let hour: Int
        let minute: Int
    }
    
    struct TimeRange: Codable, Hashable {
        let start: TimeOfDay
        let end: TimeOfDay
    }
    
    enum BlockingSchedule: Codable, Hashable {
        case always
        case timeRange(start: Date, end: Date)
        case dailyTimeRange(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)
        case weekdays([Weekday])
        case custom(days: [Weekday], timeRanges: [TimeRange])
        
        enum Weekday: Int, CaseIterable, Codable {
            case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
            
            var name: String {
                switch self {
                case .sunday: return "Sunday"
                case .monday: return "Monday"
                case .tuesday: return "Tuesday"
                case .wednesday: return "Wednesday"
                case .thursday: return "Thursday"
                case .friday: return "Friday"
                case .saturday: return "Saturday"
                }
            }
            
            var shortName: String {
                switch self {
                case .sunday: return "Sun"
                case .monday: return "Mon"
                case .tuesday: return "Tue"
                case .wednesday: return "Wed"
                case .thursday: return "Thu"
                case .friday: return "Fri"
                case .saturday: return "Sat"
                }
            }
        }
        
        // Custom Codable implementation
        private enum CodingKeys: String, CodingKey {
            case type, start, end, startHour, startMinute, endHour, endMinute, weekdays, days, timeRanges
        }
        
        private enum ScheduleType: String, Codable {
            case always, timeRange, dailyTimeRange, weekdays, custom
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(ScheduleType.self, forKey: .type)
            
            switch type {
            case .always:
                self = .always
            case .timeRange:
                let start = try container.decode(Date.self, forKey: .start)
                let end = try container.decode(Date.self, forKey: .end)
                self = .timeRange(start: start, end: end)
            case .dailyTimeRange:
                let startHour = try container.decode(Int.self, forKey: .startHour)
                let startMinute = try container.decode(Int.self, forKey: .startMinute)
                let endHour = try container.decode(Int.self, forKey: .endHour)
                let endMinute = try container.decode(Int.self, forKey: .endMinute)
                self = .dailyTimeRange(startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute)
            case .weekdays:
                let weekdays = try container.decode([Weekday].self, forKey: .weekdays)
                self = .weekdays(weekdays)
            case .custom:
                let days = try container.decode([Weekday].self, forKey: .days)
                let timeRanges = try container.decode([TimeRange].self, forKey: .timeRanges)
                self = .custom(days: days, timeRanges: timeRanges)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .always:
                try container.encode(ScheduleType.always, forKey: .type)
            case .timeRange(let start, let end):
                try container.encode(ScheduleType.timeRange, forKey: .type)
                try container.encode(start, forKey: .start)
                try container.encode(end, forKey: .end)
            case .dailyTimeRange(let startHour, let startMinute, let endHour, let endMinute):
                try container.encode(ScheduleType.dailyTimeRange, forKey: .type)
                try container.encode(startHour, forKey: .startHour)
                try container.encode(startMinute, forKey: .startMinute)
                try container.encode(endHour, forKey: .endHour)
                try container.encode(endMinute, forKey: .endMinute)
            case .weekdays(let weekdays):
                try container.encode(ScheduleType.weekdays, forKey: .type)
                try container.encode(weekdays, forKey: .weekdays)
            case .custom(let days, let timeRanges):
                try container.encode(ScheduleType.custom, forKey: .type)
                try container.encode(days, forKey: .days)
                try container.encode(timeRanges, forKey: .timeRanges)
            }
        }
    }
    
    enum DifficultyLevel: Int, CaseIterable, Codable {
        case gentle = 1
        case moderate = 2
        case strict = 3
        case nuclear = 4
        
        var name: String {
            switch self {
            case .gentle: return "Gentle"
            case .moderate: return "Moderate"
            case .strict: return "Strict"
            case .nuclear: return "Nuclear"
            }
        }
        
        var description: String {
            switch self {
            case .gentle: return "Shows a reminder, easy to bypass"
            case .moderate: return "Requires confirmation to bypass"
            case .strict: return "Requires waiting period to bypass"
            case .nuclear: return "Cannot be bypassed without payment"
            }
        }
        
        var emoji: String {
            switch self {
            case .gentle: return "🌸"
            case .moderate: return "⚡"
            case .strict: return "🔒"
            case .nuclear: return "💣"
            }
        }
        
        var bypassCost: Double {
            switch self {
            case .gentle: return 0.0
            case .moderate: return 0.0
            case .strict: return 0.0
            case .nuclear: return 0.99
            }
        }
        
        var waitTime: TimeInterval {
            switch self {
            case .gentle: return 0
            case .moderate: return 30
            case .strict: return 300 // 5 minutes
            case .nuclear: return 0 // Cannot bypass
            }
        }
    }
}

 

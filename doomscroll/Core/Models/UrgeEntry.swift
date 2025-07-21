//
//  UrgeEntry.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation

struct UrgeEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let intensity: Int // 1-10 scale
    let trigger: UrgeTrigger
    let duration: TimeInterval? // How long the urge lasted
    let outcome: UrgeOutcome
    let notes: String
    
    init(date: Date, intensity: Int, trigger: UrgeTrigger, duration: TimeInterval?, outcome: UrgeOutcome, notes: String) {
        self.id = UUID()
        self.date = date
        self.intensity = intensity
        self.trigger = trigger
        self.duration = duration
        self.outcome = outcome
        self.notes = notes
    }
    
    enum UrgeTrigger: String, CaseIterable, Codable {
        case boredom = "boredom"
        case anxiety = "anxiety"
        case habit = "habit"
        case notification = "notification"
        case fomo = "fomo"
        case procrastination = "procrastination"
        case loneliness = "loneliness"
        case stress = "stress"
        case other = "other"
        
        var emoji: String {
            switch self {
            case .boredom: return "😴"
            case .anxiety: return "😰"
            case .habit: return "🔄"
            case .notification: return "📱"
            case .fomo: return "😨"
            case .procrastination: return "⏰"
            case .loneliness: return "😔"
            case .stress: return "😤"
            case .other: return "❓"
            }
        }
        
        var description: String {
            switch self {
            case .boredom: return "Boredom"
            case .anxiety: return "Anxiety"
            case .habit: return "Habit"
            case .notification: return "Notification"
            case .fomo: return "FOMO"
            case .procrastination: return "Procrastination"
            case .loneliness: return "Loneliness"
            case .stress: return "Stress"
            case .other: return "Other"
            }
        }
    }
    
    enum UrgeOutcome: String, CaseIterable, Codable {
        case resisted = "resisted"
        case gavein = "gave_in"
        case redirected = "redirected"
        case delayed = "delayed"
        
        var emoji: String {
            switch self {
            case .resisted: return "💪"
            case .gavein: return "😞"
            case .redirected: return "🔄"
            case .delayed: return "⏸️"
            }
        }
        
        var description: String {
            switch self {
            case .resisted: return "Resisted"
            case .gavein: return "Gave In"
            case .redirected: return "Redirected"
            case .delayed: return "Delayed"
            }
        }
        
        var isPositive: Bool {
            switch self {
            case .resisted, .redirected, .delayed: return true
            case .gavein: return false
            }
        }
    }
}

 
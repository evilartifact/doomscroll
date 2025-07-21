//
//  MoodEntry.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: MoodLevel
    let energy: EnergyLevel
    let context: MoodContext
    let notes: String
    
    init(date: Date, mood: MoodLevel, energy: EnergyLevel, context: MoodContext, notes: String) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.energy = energy
        self.context = context
        self.notes = notes
    }
    
    enum MoodLevel: Int, CaseIterable, Codable {
        case terrible = 1
        case bad = 2
        case okay = 3
        case good = 4
        case excellent = 5
        
        var emoji: String {
            switch self {
            case .terrible: return "😭"
            case .bad: return "😞"
            case .okay: return "😐"
            case .good: return "😊"
            case .excellent: return "😄"
            }
        }
        
        var description: String {
            switch self {
            case .terrible: return "Terrible"
            case .bad: return "Bad"
            case .okay: return "Okay"
            case .good: return "Good"
            case .excellent: return "Excellent"
            }
        }
    }
    
    enum EnergyLevel: Int, CaseIterable, Codable {
        case exhausted = 1
        case low = 2
        case moderate = 3
        case high = 4
        case energized = 5
        
        var emoji: String {
            switch self {
            case .exhausted: return "🔋"
            case .low: return "🪫"
            case .moderate: return "🔋"
            case .high: return "⚡"
            case .energized: return "⚡"
            }
        }
        
        var description: String {
            switch self {
            case .exhausted: return "Exhausted"
            case .low: return "Low"
            case .moderate: return "Moderate"
            case .high: return "High"
            case .energized: return "Energized"
            }
        }
    }
    
    enum MoodContext: String, CaseIterable, Codable {
        case beforePhone = "before_phone"
        case afterPhone = "after_phone"
        case general = "general"
        case urge = "urge"
        
        var description: String {
            switch self {
            case .beforePhone: return "Before Phone Use"
            case .afterPhone: return "After Phone Use"
            case .general: return "General Check-in"
            case .urge: return "Urge to Scroll"
            }
        }
    }
}

 
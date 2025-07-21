//
//  JournalEntry.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import SwiftUI

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let content: String
    let mood: MoodLevel?
    let tags: [String]
    let isCompleted: Bool
    
    init(date: Date, title: String, content: String, mood: MoodLevel? = nil, tags: [String] = [], isCompleted: Bool = true) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
        self.isCompleted = isCompleted
    }
    
    init(id: UUID, title: String, content: String, mood: MoodLevel? = nil, tags: [String] = [], date: Date) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
        self.isCompleted = true
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
        
        var color: Color {
            switch self {
            case .terrible: return .red
            case .bad: return .orange
            case .okay: return .yellow
            case .good: return .green
            case .excellent: return .blue
            }
        }
    }
}

extension JournalEntry {
    static let example = JournalEntry(
        date: Date(),
        title: "Morning Reflection",
        content: "Started the day with some meditation and journaling. Feeling grateful for the opportunities ahead and excited to tackle today's challenges. The weather is beautiful and I'm in a positive mindset.",
        mood: .good,
        tags: ["gratitude", "meditation", "morning"]
    )
}
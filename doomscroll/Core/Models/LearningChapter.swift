//
//  LearningChapter.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import SwiftUI

enum ChapterColor: String, CaseIterable, Codable {
    case blue = "blue"
    case purple = "purple"
    case teal = "teal"
    case green = "green"
    case orange = "orange"
    case red = "red"
    case pink = "pink"
    case yellow = "yellow"
    
    var swiftUIColor: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .teal: return .teal
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .yellow: return .yellow
        }
    }
}

struct LearningChapter: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let color: ChapterColor
    let systemIcon: String
    let part: Int
    let content: String
    let readTime: Int
    let keyPoints: [String]
    let actionItems: [String]
    let gemsReward: Int
    let chapter: Int
    let image: String
    var isCompleted: Bool = false
    var isUnlocked: Bool = false
    var flashcards: [Flashcard] = []
    var quizQuestion: QuizQuestion?
    
    init(title: String, description: String, color: ChapterColor, systemIcon: String, part: Int, content: String, readTime: Int, keyPoints: [String], actionItems: [String], gemsReward: Int, chapter: Int, image: String, flashcards: [Flashcard] = [], quizQuestion: QuizQuestion? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.color = color
        self.systemIcon = systemIcon
        self.part = part
        self.content = content
        self.readTime = readTime
        self.keyPoints = keyPoints
        self.actionItems = actionItems
        self.gemsReward = gemsReward
        self.chapter = chapter
        self.image = image
        self.flashcards = flashcards
        self.quizQuestion = quizQuestion
    }
    
    var progress: Double {
        return isCompleted ? 1.0 : 0.0
    }
    
    var partColor: Color {
        switch part {
        case 1: return DesignSystem.Colors.primary // Blue
        case 2: return .green
        case 3: return .purple
        case 4: return .orange
        case 5: return .red
        default: return DesignSystem.Colors.primary
        }
    }
    

}

struct Flashcard: Identifiable, Codable {
    let id: UUID
    let front: String
    let back: String
    let emoji: String
    let type: FlashcardType
    
    init(front: String, back: String, emoji: String, type: FlashcardType) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.emoji = emoji
        self.type = type
    }
    
    enum FlashcardType: String, CaseIterable, Codable {
        case concept = "concept"
        case fact = "fact"
        case tip = "tip"
        case question = "question"
        case science = "science"
        case harsh = "harsh"
        case action = "action"
        case truth = "truth"
        case impact = "impact"
        case lifestyle = "lifestyle"
        case habit = "habit"
        
        var color: Color {
            switch self {
            case .concept: return .blue
            case .fact: return .green
            case .tip: return .orange
            case .question: return .purple
            case .science: return .cyan
            case .harsh: return .red
            case .action: return .mint
            case .truth: return .indigo
            case .impact: return .pink
            case .lifestyle: return .yellow
            case .habit: return .teal
            }
        }
        
        var icon: String {
            switch self {
            case .concept: return "lightbulb.fill"
            case .fact: return "info.circle.fill"
            case .tip: return "star.fill"
            case .question: return "questionmark.circle.fill"
            case .science: return "atom"
            case .harsh: return "exclamationmark.triangle.fill"
            case .action: return "arrow.right.circle.fill"
            case .truth: return "eye.fill"
            case .impact: return "heart.fill"
            case .lifestyle: return "house.fill"
            case .habit: return "repeat.circle.fill"
            }
        }
    }
}

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let question: String
    let correctAnswer: String
    let wrongAnswer: String
    let explanation: String
    let gemsReward: Int
    
    init(question: String, correctAnswer: String, wrongAnswer: String, explanation: String, gemsReward: Int = 5) {
        self.id = UUID()
        self.question = question
        self.correctAnswer = correctAnswer
        self.wrongAnswer = wrongAnswer
        self.explanation = explanation
        self.gemsReward = gemsReward
    }
} 

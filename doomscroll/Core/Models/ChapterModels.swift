import Foundation
import SwiftUI

// MARK: - JSON Response Models
struct ChaptersResponse: Codable {
    let chapters: [JSONChapter]
}

struct JSONChapter: Codable {
    let title: String
    let description: String
    let color: String
    let systemIcon: String
    let part: Int
    let content: String
    let readTime: Int
    let keyPoints: [String]
    let actionItems: [String]
    let gemsReward: Int
    let chapter: Int
    let image: String
    let flashcards: [JSONFlashcard]
    let quizQuestion: JSONQuizQuestion?
}

struct JSONFlashcard: Codable {
    let front: String
    let back: String
    let emoji: String
    let type: String
}

struct JSONQuizQuestion: Codable {
    let question: String
    let correctAnswer: String
    let wrongAnswer: String
    let explanation: String
}

// MARK: - Conversion Extensions
extension JSONChapter {
    func toLearningChapter() -> LearningChapter {
        return LearningChapter(
            title: self.title,
            description: self.description,
            color: colorFromString(self.color),
            systemIcon: self.systemIcon,
            part: self.part,
            content: self.content,
            readTime: self.readTime,
            keyPoints: self.keyPoints,
            actionItems: self.actionItems,
            gemsReward: self.gemsReward,
            chapter: self.chapter,
            image: self.image,
            flashcards: self.flashcards.map { $0.toFlashcard() },
            quizQuestion: self.quizQuestion?.toQuizQuestion()
        )
    }
    
    private func colorFromString(_ colorString: String) -> ChapterColor {
        switch colorString.lowercased() {
        case "blue": return .blue
        case "purple": return .purple
        case "teal": return .teal
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

extension JSONFlashcard {
    func toFlashcard() -> Flashcard {
        return Flashcard(
            front: self.front,
            back: self.back,
            emoji: self.emoji,
            type: flashcardTypeFromString(self.type)
        )
    }
    
    private func flashcardTypeFromString(_ typeString: String) -> Flashcard.FlashcardType {
        switch typeString.lowercased() {
        case "concept": return .concept
        case "fact": return .fact
        case "science": return .science
        case "harsh": return .harsh
        case "action": return .action
        case "truth": return .truth
        case "habit": return .habit
        case "lifestyle": return .lifestyle
        case "impact": return .impact
        case "memey": return .tip  // Map memey to tip since it doesn't exist
        case "myth": return .concept  // Map myth to concept since it doesn't exist
        default: return .concept
        }
    }
}

extension JSONQuizQuestion {
    func toQuizQuestion() -> QuizQuestion {
        return QuizQuestion(
            question: self.question,
            correctAnswer: self.correctAnswer,
            wrongAnswer: self.wrongAnswer,
            explanation: self.explanation
        )
    }
} 